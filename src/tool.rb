ToolParam = Struct.new(:name, :type, :description, :required)
class Tool
  class << self
    attr_reader :name, :description, :parameters

    def inherited(subclass)
      subclass.instance_variable_set(:@parameters, [])
    end

    def name(value = nil)
      @name = value if value
      @name
    end

    def description(value = nil)
      @description = value if value
      @description
    end

    def parameter(name, type, description, required: false)
      @parameters ||= []

      @parameters << ToolParam.new(
        name,
        type,
        description,
        required
      )
    end

    def parameters
      @parameters ||= []
    end
  end

  def name
    self.class.name.freeze
  end

  def description
    self.class.description.freeze
  end

  def parameters
    self.class.parameters.freeze
  end

  def execute(**kwargs)
    raise NotImplementedError, 'execute is not implemented on base tool class'
  end
end
