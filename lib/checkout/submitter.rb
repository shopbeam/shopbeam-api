module Checkout
  class Submitter
    include Wisper::Publisher

    attr_reader :order

    def initialize(order)
      @order = order
    end

    def call
      # TODO: Crawler logic goes here...
      broadcast(:submit_checkout_successful, order)
    end
  end
end
