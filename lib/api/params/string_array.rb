module API
  module Params
    class StringArray
      def self.parse(raw_value)
        raw_value.split(',')
      end
    end
  end
end
