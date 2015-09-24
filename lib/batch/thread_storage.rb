class Batch
  class ThreadStorage
    class << self
      delegate :[], :[]=, to: :storage
      
      private
      def storage
        Thread.current[:batch_storage] ||= {}
      end
    end
  end
end
