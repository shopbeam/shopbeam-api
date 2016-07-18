module API
  module Params
    class IntegerList
      def self.parse(value)
        value.split(',').map(&:to_i)
      end
    end
  end
end
