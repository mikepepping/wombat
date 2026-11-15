require 'faraday'
require_relative '../tool'

class WebTool < Tool
  description "Access the web using only GET methods."
  parameter :url, :string, 'the url of the site/page you want to read from the web', required: true

  def execute(url:)
    res = cached(url)

    JSON.pretty_generate(
      {
        "response" => {
          "url" => url,
          "headers" => res.headers,
          "status" => res.status,
          "body" => res.body
        }
      }
    )
  rescue Faraday::Error =>e
    JSON.pretty_generate(
      {
        "error" => e.message
      }
    )
  end

  private

  def connection
    Faraday.new do |c|
      c.headers
    end
  end

  def cached(url)
    @@cached ||= {}
    @@cached[url] ||= Faraday.get(url)
  end
end

