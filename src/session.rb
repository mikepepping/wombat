require 'json'
require_relative 'string'
require_relative "message"

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
      obj[snake_case(tool.class.name)] = tool
    end
  end

  def chat(content)
    # TODO: track context window use
    user_message = Message.new("user", content)
    response = @provider.chat([*history, user_message], tools: tools.values) # TODO send tools as dict
    @history.append(user_message, response)

    yield response if block_given?

    while response.tool_calls.any?
      tool_responses = response.tool_calls
                               .sort { |a, b| a.dig('function', 'index') <=> b.dig('function', 'index') }
                               .map { |tool_call| tool_response(tool_call) } # NOTE: consider fanout
      
      tool_responses.each do |tool_response|
        yield tool_response if block_given?
      end

      response = @provider.chat([*history, *tool_responses], tools: tools.values)
      yield response if block_given?

      @history.append(*tool_responses, response)
    end

    response
  end

  def save
    # WARNING: Currently rewrites the entire file
    open("#{id}.jsonl", "w") do |f|
      @history.each do |msg|
        file.puts(JSON.dump(msg.to_h))
      end
    end
  end

  private

  def tool_response(tool_call)
    tool_name = tool_call.dig('function', 'name')
    tool_args = tool_call.dig('function', 'arguments')
    Message.new(
      "tool",
      tools[tool_name].execute(**tool_args.transform_keys { |k| k.to_sym }),
      name: tool_name
    )
  end
end

