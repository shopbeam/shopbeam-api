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
      it 'responds with ok status code' do
        dispatcher = double

        expect(controller).to receive(:valid_signature?).and_return(true)
        expect(Checkout::MailDispatchers).to receive(:lookup).with('sender@orders.shopbeam.com').and_return(dispatcher)
        expect(dispatcher).to receive(:new).with(hash_including(foo: 'bar')).and_return(double(call: true))
        post :mail, sender: 'sender@orders.shopbeam.com', foo: 'bar'
        expect(response).to have_http_status(200)
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
