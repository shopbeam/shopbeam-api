require 'rails_helper'

describe Checkout::Notifier do
  let(:mailer) { double(deliver_now: true) }

  describe '#order_completed' do
    it 'calls order mailer with the target order' do
      order = double

      expect(OrderMailer)
        .to receive(:completed).with(order)
        .and_return(mailer)

      subject.order_completed(order)
    end
  end

  describe '#order_not_found' do
    it 'calls order mailer with the target order ID' do
      expect(OrderMailer)
        .to receive(:not_found).with(1)
        .and_return(mailer)

      subject.order_not_found(1)
    end
  end

  describe '#order_terminated' do
    it 'calls order mailer with the target order and exception' do
      order, exception = double, double

      expect(OrderMailer)
        .to receive(:terminated).with(order, exception)
        .and_return(mailer)

      subject.order_terminated(order, exception)
    end
  end

  describe '#order_aborted' do
    it 'calls order mailer with the target order and exception' do
      order, exception = double, double

      expect(OrderMailer)
        .to receive(:aborted).with(order, exception)
        .and_return(mailer)

      subject.order_aborted(order, exception)
    end
  end
end
