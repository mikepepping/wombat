ToolCall = Struct.new(:name, :arguments)

class ProviderError < StandardError
end

class RetryFailed < ProviderError
end

class Provider
  def initialize
    raise NotImplementedError, "Cannot instantiate base class"
  end

  def chat(messages, tools: [])
    raise NotImplementedError
  end

  def schat(messages, tools: [])
    raise NotImplementedError
  end
end
