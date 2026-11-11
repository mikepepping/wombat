require_relative "message"

class Session
  attr_reader :history, :id, :tools

  def initialize(provider, tools: [], history: [], id: nil)
    @id = if id
            id
          else
            SecureRandom.uuid
          end
    @history = history || []
    @provider = provider
    @tools = tools || []
  end

  def chat(content)
    # TODO: track context window use
    user_message = Message.new("user", content)
    @provider.chat([*history, user_message], tools:).tap do |response|
      @history.push(user_message, response)
    end
  end
end
