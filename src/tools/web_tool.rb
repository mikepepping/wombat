require 'faraday'
require_relative '../tool'

class WebTool < Tool
  name 'get_url'
  description 'Access a url/webpage as `http GET`'
  parameter :url, :string, 'the url of the site/page you want to read from the internet', required: true

  def execute(url:)
    res = cached(url)

    JSON.pretty_generate(
      {
        'response' => {
          'url' => url,
          'headers' => res.headers,
          'status' => res.status,
          'body' => res.body
        }
      }
    )
  rescue Faraday::Error =>e
    JSON.pretty_generate(
      {
        'error' => e.message
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

  def display_detail(arguments)
    arguments['url'] || arguments[:url]
  end
end

