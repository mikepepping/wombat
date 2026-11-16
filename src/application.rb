require_relative 'session'

class Application
  COMMANDS = {
    "/exit" => :handle_exit,
    "/clear" => :handle_clear
  }.freeze

  def initialize(provider, tools: [])
    @session = Session.new(provider, tools:)
    @continue = true
  end

  def run
    @session.history.each do |message|
      print_message(message)
    end

    while @continue
      print_separator('user')
      content = gets&.strip
      break unless content
      next if content.empty?

      if COMMANDS.key?(content)
        send(COMMANDS[content])
      else
        @session.chat(content) do |msg|
          print_message(msg)
        end
      end
    end
  end

  private

  def print_separator(role)
    puts [role, '-' * 10].join(':')
  end

  def print_message(message)
    print_separator(message.role)
    puts message.content
    puts ""
  end

  def handle_clear
    @session.clear
    puts "\n[Session cleared]\n\n"
  end

  def handle_exit
    @continue = false
  end
end
