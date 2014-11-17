require "generate_method/version"

module GenerateMethod
  module Generator
    def generate_method(method_name, overrider: nil, &block)
      include generate_method_module(method_name, overrider: overrider, &block)
    end
    def generate_singleton_method(method_name, overrider: nil, &block)
      extend generate_method_module(method_name, overrider: overrider, &block)
    end

    def generate_methods(overrider: nil, &block)
      include generate_block_module(overrider: overrider, &block)
    end
    def generate_singleton_methods(overrider: nil, &block)
      extend generate_block_module(overrider: overrider, &block)
    end

    private

    def generate_method_module(method_name, overrider: nil, &block)
      m = Module.new do
        define_method(method_name, &block)
      end
      alias_generated_method(method_name, overrider: overrider, m: m)
      m
    end

    def generate_block_module(overrider: nil, &block)
      m = Module.new(&block)
      m.instance_methods.each do |method_name|
        alias_generated_method(method_name, overrider: overrider, m: m)
      end
      m
    end

    def alias_generated_method(method_name, overrider: nil, m: nil)
      return if overrider.nil?

      method_name_s, override_name_s = method_name.to_s, overrider.to_s
      # pushing one of [?=!] to the end of the _without_ method
      if method_name_s =~ /[\=\?\!]$/
        override_name_s.concat method_name_s[-1]
        method_name_s.chop!
      end
      override_method_name = :"#{method_name_s}_without_#{override_name_s}"

      begin
        alias_method :"_#{override_method_name}", method_name
      rescue NameError # method does not exist
      else
        m.instance_eval do
          define_method(override_method_name) do |*args, &block|
            send(:"_#{override_method_name}", *args, &block)
          end
        end
      end
    end
  end
end

class Module
  include GenerateMethod::Generator
end
