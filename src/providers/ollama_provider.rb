require 'faraday'
require_relative './provider'


class OllamaProvider < Provider
  def initialize(host, model, api_key: nil)
    @host = host
    @model = model
    @api_key = api_key
  end

  def chat(messages, tools: [])
    call_provider messages, tools, false
  end

  def schat(messages, tools: [])
    call_provider messages, tools, true
  end

  private

  def connection
    Faraday.new @host do |f|
      f.request :json

      unless @api_key.nil? || @api_key.strip == ''
        f.request :authorization, 'Bearer', @api_key
      end
    end
  end

  def call_provider(messages, tools, stream_response)
    connection.post 'api/chat', {
      'model' => @model,
      'messages' => messages,
      'stream' => stream_response
    }
  end
end
