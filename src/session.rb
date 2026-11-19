require 'json'
require 'securerandom'
require_relative "message"

Usage = Struct.new(:sent, :received, :total)

class Session
  attr_reader :history, :id, :tools

  def initialize(provider, tools: [], history: [], id: nil)
    @id = if id
            id
          else
            SecureRandom.uuid
          end
    @history = history || []
    @provider = provider
    @tools = tools.each_with_object({}) do |tool, obj|
      obj[tool.name] = tool
    end
    @tokens_sent = 0
    @tokens_received = 0
  end

  def chat(content)
    # TODO: track context window use
    user_message = Message.new("user", content)
    response = @provider.chat([*history, user_message], tools: tools.values) # TODO send tools as dict
    @history.append(user_message, response)
    @tokens_sent += response.prompt_tokens
    @tokens_received += response.completion_tokens

    yield response if block_given?

    while response.tool_calls.any?
      tool_responses = response.tool_calls.map do |tool_call|
        # NOTE: consider fanout
        tool_response(tool_call)
      end
      
      tool_responses.each do |tool_response|
        yield tool_response if block_given?
      end

      response = @provider.chat([*history, *tool_responses], tools: tools.values)
      yield response if block_given?

      @history.append(*tool_responses, response)
      @tokens_sent += response.prompt_tokens
      @tokens_received += response.completion_tokens
    end

    response
  end

  def usage
    Usage.new(@tokens_sent, @tokens_received, @tokens_sent + @tokens_received)
  end

  def clear
    @history.clear
    @tokens_sent = 0
    @tokens_received = 0
  end

  def save
    # WARNING: Currently rewrites the entire file
    open("#{id}.jsonl", "w") do |f|
      @history.each do |msg|
        f.puts(JSON.dump(msg.to_h))
      end
    end
  end

  private

  def tool_response(tool_call)
    arguments = tool_call.arguments.transform_keys(&:to_sym)

    begin
      response = tools[tool_call.name].execute(**arguments)
    rescue ArgumentError => e
      response = JSON.pretty_generate({
          "error" => "Tool call failed - #{e.class.name}: #{e.message}"
        })
    end

  
    Message.new(
      "tool",
      response,
      tool_call_id: tool_call.id
    )
  end
end

