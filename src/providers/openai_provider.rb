require 'faraday'
require 'openai'
require_relative '../string'
require_relative './provider'
require_relative '../message'

require 'debug'


class OpenaiProvider < Provider
  def initialize(host, model, api_key: nil)
    @host = host
    @model = model
    @api_key = api_key
  end

  def chat(messages, tools: [])
    available_tools = (tools || []).map { |tool| format_tool(tool) }
    formatted_messages = messages.map { |msg| format_message(msg) }
  
    res = connection.post 'chat/completions', {
      'model' => @model,
      'messages' => formatted_messages,
      'stream' => false,
      'tools' => available_tools
    }

    # TODO: stop reason and act appropriately
    # TODO: check if there are any choices and act appropriately
    # 
    debugger

    puts res.body
    choice = res.body.fetch('choices', []).first
    message = choice.fetch('message', {})


    content = case choice['finish_reason']
    when 'tool_calls'
      [
        "Tool Calls:",
        *message['tool_calls'].map { |tc| tc.dig('function', 'name')}
      ].join("\n  *")
    when 'stop'
      message['content']
    end
    

    Message.new(
      message.fetch('role'),
      content,
      tool_calls: message.fetch('tool_calls', []).map { |tool_call| convert_tool_call(tool_call) }
    )
  end

  private

  def connection
    Faraday.new @host do |f|
      f.request :json
      f.response :json

      unless @api_key.nil? || @api_key.strip == ''
        f.request :authorization, 'Bearer', @api_key
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
              'arguments' => JSON.generate(tc[:arugments])
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
