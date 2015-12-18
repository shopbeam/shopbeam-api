require 'rails_helper'

describe MailDispatcherJob do
  it { expect(described_class).to be_retryable(1) }

  context 'when dispatcher found' do
    it 'calls the target dispatcher' do
      dispatcher = spy('dispatcher')

      expect(Checkout::MailDispatchers)
        .to receive(:lookup).with('sender@example.com')
        .and_return(dispatcher)

      subject.perform('from' => 'sender@example.com')

      expect(dispatcher).to have_received(:call)
    end
  end

  context 'when dispatcher not found' do
    it 'does not call a dispatcher' do
      dispatcher = spy('dispatcher')

      expect(Checkout::MailDispatchers)
        .to receive(:lookup).with('sender@example.com')
        .and_return(nil)

      subject.perform('from' => 'sender@example.com')

      expect(dispatcher).not_to have_received(:call)
    end
  end
end
