require 'rails_helper'

describe OrdersController do
  describe 'POST fill' do
    let(:order) { build_stubbed(:order) }

    context 'with valid signature' do
      before do
        verify_authenticity_signature
      end

      it 'enqueues checkout job' do
        post :fill, id: order.id

        expect(CheckoutJob).to have_enqueued_job("#{order.id}")
      end

      it 'responds with accepted status code' do
        post :fill, id: order.id

        expect(response).to have_http_status(202)
      end
    end

    context 'with invalid signature' do
      it 'responds with unauthorized status code' do
        post :fill, id: order.id

        expect(response).to have_http_status(401)
      end
    end
  end

  describe 'POST mail' do
    context 'with valid signature' do
      it 'enqueues mail dispatcher job' do
        post :mail, foo: 'bar', **mailgun_signature

        expect(MailDispatcherJob).to have_enqueued_job(hash_including('foo' => 'bar'))
      end

      it 'responds with ok status code' do
        post :mail, foo: 'bar', **mailgun_signature

        expect(response).to have_http_status(200)
      end
    end

    context 'with invalid signature' do
      it 'responds with not acceptable status code' do
        post :mail

        expect(response).to have_http_status(406)
      end
    end
  end
end
