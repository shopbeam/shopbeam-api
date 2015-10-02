require 'rails_helper'

describe OrdersController do
  describe 'POST fill' do
    it_behaves_like 'verifies authenticity signature for', :post, :fill, id: 1

    context 'with valid signature' do
      let(:order) { build_stubbed(:order) }

      before do
        verify_signature
        post :fill, id: order.id
      end

      it 'enqueues checkout job' do
        expect(CheckoutJob).to have_enqueued_job("#{order.id}")
      end

      it 'responds with accepted status code' do
        expect(response).to have_http_status(202)
      end
    end
  end

  describe 'POST mail' do
    context 'with valid signature' do
      before do
        expect(controller).to receive(:verify_mailgun_signature).and_return(true)
        post :mail, foo: 'bar'
      end

      it 'enqueues mail dispatcher job' do
        expect(MailDispatcherJob).to have_enqueued_job(hash_including('foo' => 'bar'))
      end

      it 'responds with ok status code' do
        expect(response).to have_http_status(200)
      end
    end

    context 'with invalid signature' do
      it 'responds with not acceptable status code' do
        expect(controller).to receive(:verify_mailgun_signature).and_return(false)
        post :mail
        expect(response).to have_http_status(406)
      end
    end
  end
end
