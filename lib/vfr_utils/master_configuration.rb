module VfrUtils
  class MasterConfiguration

    def initialize(defaults={})
      @defaults = defaults
      @modules = {}
    end

    def method_missing(method_name, *args, &blk)
      unless @modules[method_name]
        @modules[method_name] = Configuration.new @defaults
        self.class.class_exec do
          define_method(method_name) { @modules[method_name] }
        end
        send(method_name, *args, &blk)
      end
    end

    def global(values)
      @defaults.merge! values
      @modules.each_value do |m|
        values.each_pair do |k,v|
          key = "#{k}=".to_sym
          m.send(key, v)
        end
      end
    end

  end
end
