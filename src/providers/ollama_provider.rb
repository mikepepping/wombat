require 'faraday'
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
      'stream' => false
    }

    # TODO: Check done and done_reason before proceeding
    # raise StandardError, "message incomplete" unless res['done'] && res['done_reason'] == 'finished'
    # raise StandardError, "message missing" unless res.body['message']

    Message.new(res.body.dig('message', 'role'), res.body.dig('message', 'content')) # TODO: validate role and content exist
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
end
