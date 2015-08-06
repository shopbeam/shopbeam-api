module Checkout
  class Submitter
    include Wisper::Publisher

    attr_reader :order

    def self.call(*args)
      new(*args).call
    end

    def initialize(order, listener)
      @order = order
      subscribe(listener)
    end

    def call
      # TODO: Crawler logic goes here...
      broadcast(:submit_checkout_successful, order)
    end
  end
end
