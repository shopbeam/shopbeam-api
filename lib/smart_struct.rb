module SmartStruct
  extend self

  def keyword(*attributes)
    Struct.new(*attributes) do
      SmartStruct.underscorize(attributes, self)
      def initialize(**args)
        args.each { |key, value| self.send("#{key}=", value) }
      end
    end
  end

  def underscorize(attributes, obj)
    attributes.each do |attr|
      next unless attr.to_s.include?('-')
      new_attr = attr.to_s.gsub('-', '_')
      define_alias(attr, new_attr, obj)
    end
  end

  def define_alias(attr, new_attr, obj)
    obj.instance_eval do
      alias_method new_attr, attr
      alias_method "#{new_attr}=", "#{attr}="
    end
  end
end
