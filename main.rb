require_relative 'src/providers/openai_provider'
require_relative 'src/session'
require_relative 'src/tools/bash_tool'
require_relative 'src/tools/web_tool'

require 'dotenv'
Dotenv.load

tools = [
  BashTool.new,
  WebTool.new
]

def get_api_key
  ENV['WOMBAT_OPENAI_API_KEY']
end

#provider = OllamaProvider.new("http://localhost:11434", "qwen3:4b")
provider = OpenaiProvider.new(
  'https://generativelanguage.googleapis.com/v1beta/openai',
  'gemini-3.5-flash-lite',
  api_key_accessor: method(:get_api_key)
)
session = Session.new(provider, tools:)


def print_seperator(role)
  puts [role, '-' * 10].join(':')
end

def print_message(message)
  print_seperator(message.role)
  puts message.content
  puts ""
end

session.history.each do |message|
  print_message(message)
end

COMMANDS = {
  "/exit" => Proc.new { exit(0) },
  "/clear" => Proc.new { session.clear }
}

while true
  print_seperator('user')
  content = gets.strip

  if content in COMMANDS
    COMMANDS[content].call
  else
    session.chat(content) do |msg|
      print_message(msg)
    end
  end
end

puts "Finished"
  
