class Message
  attr_accessor :role, :content, :thinking, :tool_calls, :name

  def initialize(role, content, thinking: nil, tool_calls: nil, name: nil)
    @role = role
    @content = content
    @thinking = thinking
    @tool_calls = tool_calls
    @name = name
  end

  def append(message)
    raise ArgumentError, "message is not the same role" unless message.role == role

    content << messsage.content
  end

  def to_h
    {
      "role" => @role,
      "content" => @content
    }.tap do |h|
      h["tool_calls"] = @tool_calls if @tool_calls
      h["thinking"] = @thinking if @thinking
      h["name"] = @name if @name
    end
  end
end

