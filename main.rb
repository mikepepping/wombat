require_relative 'src/providers/ollama_provider'
require_relative 'src/session'

provider = OllamaProvider.new("http://localhost:11434", "qwen2.5-coder:1.5b")
session = Session.new(provider)

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
    session.chat(content)
    print_message(session.history.last)
  end
end

puts "Finished"
  
