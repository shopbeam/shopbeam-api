require 'rails_helper'

describe Checkout::Notifier do
  let(:mailer) { double(deliver_now: true) }

  describe '#order_completed' do
    it 'calls checkout mailer with the target order' do
      order = double

      expect(CheckoutMailer)
        .to receive(:completed).with(order)
        .and_return(mailer)

      subject.order_completed(order)
    end
  end

  describe '#order_not_found' do
    it 'calls checkout mailer with the target order ID' do
      expect(CheckoutMailer)
        .to receive(:not_found).with(1)
        .and_return(mailer)

      subject.order_not_found(1)
    end
  end

  describe '#order_terminated' do
    it 'calls checkout mailer with the target order and exception' do
      order, exception = double, double

      expect(CheckoutMailer)
        .to receive(:terminated).with(order, exception)
        .and_return(mailer)

      subject.order_terminated(order, exception)
    end
  end

  describe '#order_aborted' do
    it 'calls checkout mailer with the target order and exception' do
      order, exception = double, double

      expect(CheckoutMailer)
        .to receive(:aborted).with(order, exception)
        .and_return(mailer)

      subject.order_aborted(order, exception)
    end
  end

  describe '#account_activated' do
    it 'calls account mailer with the target account' do
      account = double

      expect(AccountMailer)
        .to receive(:activated).with(account)
        .and_return(mailer)

      subject.account_activated(account)
    end
  end

  describe '#account_not_found' do
    it 'calls account mailer with the target account ID' do
      expect(AccountMailer)
        .to receive(:not_found).with(1)
        .and_return(mailer)

      subject.account_not_found(1)
    end
  end

  describe '#account_aborted' do
    it 'calls account mailer with the target account and exception' do
      account, exception = double, double

      expect(AccountMailer)
        .to receive(:aborted).with(account, exception)
        .and_return(mailer)

      subject.account_aborted(account, exception)
    end
  end
end
