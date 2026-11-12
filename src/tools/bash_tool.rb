require 'shellwords'
require_relative '../tool'

class BashTool < Tool
  description "execute a bash command"
  parameter :command, :string, 'the full command to run including arguments', required: true

  def execute(command:)
    escaped = Shellwords.escape(command)
    `bash -c '#{escaped}'`
  end
end
