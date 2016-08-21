module AttrDecryptor
  extend ActiveSupport::Concern

  class_methods do
    def attr_decryptor(*attributes)
      options = attributes.extract_options!

      attributes.each do |attribute|
        salt_attr = (options[:salt] || "#{attribute}_salt").to_sym
        type = (options[:type] || :string).to_sym

        define_method(attribute) do
          value = read_attribute(attribute)

          return nil if !value.is_a?(String) || value.empty?
          value = Encryptor.decrypt(value, read_attribute(salt_attr))
          TypeCaster.cast(value, type)
        end

        define_method("#{attribute}=") do |value|
          salt = read_attribute(salt_attr) || write_attribute(salt_attr, SecureRandom.base64) && read_attribute(salt_attr)
          encrypted = Encryptor.encrypt(value.to_s, salt)[:value]
          write_attribute(attribute, encrypted)
        end
      end
    end
  end
end
