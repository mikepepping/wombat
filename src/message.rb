class Message
  attr_accessor :role, :content

  def initialize(role, content)
    @role = role
    @content = content
  end

  def append(message)
    raise ArgumentError, "message is not the same role" unless message.role == role

    content << messsage.content
  end

  def to_h
    {
      "role" => @role,
      "content" => @content
    }
  end
end
