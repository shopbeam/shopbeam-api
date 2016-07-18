module API
  module Params
    class StringList
      def self.parse(value)
        value.split(',')
      end
    end
  end
end
