# Inspired by ActiveRecord::ConnectionAdapters::Column#type_cast
# See https://github.com/rails/rails/blob/4-1-stable/activerecord/lib/active_record/connection_adapters/column.rb#L91-L109
module TypeCaster
  extend self

  TRUE_VALUES = [true, 1, '1', 't', 'T', 'true', 'TRUE', 'on', 'ON'].to_set

  def cast(value, type)
    return nil if value.nil?

    case type
    when :string, :text then value_to_string(value)
    when :integer       then value_to_integer(value)
    when :float         then value.to_f
    when :decimal       then value_to_decimal(value)
    when :boolean       then value_to_boolean(value)
    else value
    end
  end

  private

  def value_to_string(value)
    case value
    when TrueClass  then '1'
    when FalseClass then '0'
    else value.to_s
    end
  end

  def value_to_integer(value)
    case value
    when TrueClass, FalseClass
      value ? 1 : 0
    else
      value.to_i rescue nil
    end
  end

  def value_to_decimal(value)
    # Using .class is faster than .is_a? and
    # subclasses of BigDecimal will be handled
    # in the else clause
    if value.class == BigDecimal
      value
    elsif value.respond_to?(:to_d)
      value.to_d
    else
      value.to_s.to_d
    end
  end

  def value_to_boolean(value)
    if value.is_a?(String) && value.empty?
      nil
    else
      TRUE_VALUES.include?(value)
    end
  end
end
