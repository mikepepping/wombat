ToolCall = Struct.new(:id, :name, :arguments, :extra)

class Message
  attr_accessor :role, :content, :tool_calls, :tool_call_id, :prompt_tokens, :completion_tokens, :total_tokens

  def initialize(role, content, tool_calls: nil, tool_call_id: nil, prompt_tokens: nil, completion_tokens: nil, total_tokens: nil)
    @role = role
    @content = content
    @tool_calls = tool_calls
    @tool_call_id = tool_call_id
    @prompt_tokens = prompt_tokens
    @completion_tokens = completion_tokens
    @total_tokens = total_tokens
  end

  def append(message)
    raise ArgumentError, 'message is not the same role' unless message.role == role

    content << message.content
  end

  def to_h
    {
      'role' => @role,
      'content' => @content
    }.tap do |h|
      h['tool_calls'] = @tool_calls.map(&:to_h) if @tool_calls
      h['tool_call_id'] = @tool_call_id if @tool_call_id
    end
  end
end
