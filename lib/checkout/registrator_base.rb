module Checkout
  class RegistratorBase
    def initialize(account)
      @account = account
    end

    def register!
      raise NotImplementedError, 'Subclasses must implement a register! method.'
    end

    protected

    attr_reader :account

    def browser
      @browser ||= Checkout::Browser.new(headless: { display: account.id })
    end
  end
end
