require 'faraday'
require_relative '../string'
require_relative './provider'
require_relative '../message'


class OllamaProvider < Provider
  def initialize(host, model, api_key: nil)
    @host = host
    @model = model
    @api_key = api_key
  end

  def chat(messages, tools: [])
  
    res = connection.post 'api/chat', {
      'model' => @model,
      'messages' => messages.map(&:to_h),
      'stream' => false,
      'tools' => (tools || []).map { |tool| format_tool(tool) }
    }

    # TODO: Check done and done_reason before proceeding
    # raise StandardError, "message incomplete" unless res['done'] && res['done_reason'] == 'finished'
    # raise StandardError, "message missing" unless res.body['message']

    message = res.body.fetch('message', {})

    Message.new(
      message.fetch('role', 'assistant'),
      message.fetch('content', ''),
      thinking: message.fetch('thinking', ''),
      tool_calls: message.fetch('tool_calls', [])
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

  def format_tool(tool)
    {
      'type' => 'function',
      'function' => {
        'name' =>snake_case(tool.class.name),
        'description' => tool.description,
        'parameters' => {
          'type' => 'object',
          'properties' => tool.parameters.each_with_object({}) do |param, obj|
            obj[param.name] = {
              'type' => param.type,
              'description' => param.description
            }
          end
        },
        'required' => tool.parameters.filter(&:required).map(&:name)
      }
    }
  end
end
