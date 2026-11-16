require_relative 'src/providers/openai_provider'
require_relative 'src/tools/bash_tool'
require_relative 'src/tools/web_tool'
require_relative 'src/application'

require 'dotenv'
Dotenv.load

tools = [
  BashTool.new,
  WebTool.new
]

def get_api_key
  ENV['WOMBAT_OPENAI_API_KEY']
end

# provider = OllamaProvider.new("http://localhost:11434", "qwen3:4b")
provider = OpenaiProvider.new(
  'https://generativelanguage.googleapis.com/v1beta/openai',
  'gemini-3.5-flash-lite',
  api_key_accessor: method(:get_api_key)
)

app = Application.new(provider, tools:)
app.run

puts "Finished"
