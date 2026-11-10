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
