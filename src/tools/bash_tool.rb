require 'shellwords'
require 'open3'
require_relative '../tool'

class BashTool < Tool
  description "execute a bash command"
  parameter :command, :string, 'the full command to run including arguments', required: true

  def execute(command:)
    captured = Open3.capture3('bash', '-c', command)

    JSON.pretty_generate(
      {
        "stdout" => captured.first,
        "stderr" => captured[1],
        "exited" => captured.last.exitstatus
      }
    )
  end
end

