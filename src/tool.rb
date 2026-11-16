ToolParam = Struct.new(:name, :type, :description, :required)

class Tool
  class << self
    def name(tool_name)
      @@name = tool_name
    end

    def description(desc)
      @@description = desc
    end

    def parameter(name, type, description, required: false)
      ToolParam.new(name, type, description, required).tap do |param|
        @@parameters ||= []
        @@parameters << param
      end
    end
  end

  def name
    @@name.freeze
  end

  def description
    @@description.freeze
  end

  def parameters
    @@parameters.freeze
  end

  def execute(**kwargs)
    raise NotImplementedError, 'execute is not implemented on base tool class'
  end
end
