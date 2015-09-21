require 'rails_helper'

describe OrdersController do
  describe 'POST fill' do
    let(:order) { build_stubbed(:order) }

    before do
      post :fill, id: order.id
    end

    it 'enqueues checkout job' do
      expect(enqueued_jobs).to include(
        job: CheckoutJob,
        args: ["#{order.id}"],
        queue: 'default'
      )
    end

    it 'responds with accepted status code' do
      expect(response).to have_http_status(202)
    end
  end

  describe 'POST mail' do
    context 'with valid signature' do
      before do
        expect(controller).to receive(:valid_signature?).and_return(true)
      end

      context 'from known sender' do
        it 'responds with ok status code' do
          dispatcher = double

          expect(Checkout::MailDispatchers).to receive(:lookup).with('info@well.ca').and_return(dispatcher)
          expect(dispatcher).to receive(:new).with(hash_including(foo: 'bar')).and_return(double(call: true))
          post :mail, from: 'info@well.ca', foo: 'bar'
          expect(response).to have_http_status(200)
        end
      end

      context 'from unknown sender' do
        it 'responds with ok status code' do
          expect(Checkout::MailDispatchers).to receive(:lookup).with('foo@bar.com')
          post :mail, from: 'foo@bar.com'
          expect(response).to have_http_status(200)
        end
      end
    end

    context 'with invalid signature' do
      it 'responds with not acceptable status code' do
        expect(controller).to receive(:valid_signature?).and_return(false)
        post :mail
        expect(response).to have_http_status(406)
      end
    end
  end
end
