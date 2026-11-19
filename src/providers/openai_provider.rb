require 'faraday'
require 'openai'
require_relative '../string'
require_relative './provider'
require_relative '../message'


class OpenaiProvider < Provider
  MAX_RETRIES = 5

  def initialize(host, model, api_key_accessor: nil)
    @host = host
    @model = model
    @api_key_accessor = api_key_accessor
  end

  def chat(messages, tools: [])
    available_tools = (tools || []).map { |tool| format_tool(tool) }
    formatted_messages = messages.map { |msg| format_message(msg) }
  

    # TODO: stop reason and act appropriately
    # TODO: check if there are any choices and act appropriately
    # 
    
    retries = 0
    response = nil
    loop do
      # TODO: consider faraday-retry middleware
      begin
        response = connection.post 'chat/completions', {
          'model' => @model,
          'messages' => formatted_messages,
          'stream' => false,
          'tools' => available_tools
        }
      rescue Faraday::ConnectionError, Faraday::TimeoutError => e
        raise if retries >= MAX_RETRIES
      end

      break unless RETRY_STATUS_CODES.include?(response.status)

      if retries >= MAX_RETRIES
        raise Provider::RetryFailed, "Failed to receive chat response after #{retries} retries"
      end

      sleep(2**retries)
      retries += 1
    end
    


    choice = response.body.fetch('choices', []).first
    message = choice.fetch('message', {})
    usage_data = response.body['usage'] || {}


    content = if choice['finish_reason'] == 'tool_calls'
      [
        "Tool Calls:",
        *message['tool_calls'].map { |tc| tc.dig('function', 'name')}
      ].join("\n  *")
    else
      message['content']
    end
    

    Message.new(
      message.fetch('role'),
      content,
      tool_calls: message.fetch('tool_calls', []).map { |tool_call| convert_tool_call(tool_call) },
      prompt_tokens: usage_data['prompt_tokens'],
      completion_tokens: usage_data['completion_tokens'],
      total_tokens: usage_data['total_tokens']
    )
  end

  private

  RETRY_STATUS_CODES = [420, 429, 503].freeze

  def connection
    Faraday.new @host do |f|
      f.request :json
      f.response :json

      if @api_key_accessor
        f.request :authorization, 'Bearer', @api_key_accessor.call
      end
    end
  end

  def convert_tool_call(tool_call)
    function = tool_call.fetch('function', {})
    ToolCall.new(
      tool_call['id'],
      function['name'],
      JSON.parse(tool_call.dig('function', 'arguments')),
      tool_call['extra_content']
    )
  end

  def format_message(message)
    message.to_h.tap do |formatted|
      if formatted['tool_calls']
        formatted['tool_calls'] = formatted['tool_calls'].map do |tc|
          {
            'id' => tc[:id],
            'type' => 'function',
            'function' => {
              'name' => tc[:name],
              'arguments' => JSON.generate(tc[:arguments])
            },
            'extra_content' => tc[:extra]
          }
        end
      end
    end
  end

  def format_tool(tool)
    {
      'type' => 'function',
      'function' => {
        'name' => tool.name,
        'description' => tool.description,
        'parameters' => {
          'type' => 'object',
          'properties' => tool.parameters.each_with_object({}) do |param, obj|
            obj[param.name] = {
              'type' => param.type,
              'description' => param.description
            }
          end,
          'required' => tool.parameters.filter(&:required).map(&:name)
        },
      }
    }
  end
end
