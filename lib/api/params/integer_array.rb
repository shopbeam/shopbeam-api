module API
  module Params
    class IntegerArray
      def self.parse(raw_value)
        vals = raw_value.split(',')
        vals.map(&:to_i)
      end
    end
  end
end
