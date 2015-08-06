require 'rails_helper'

describe OrdersController do
  describe 'POST fill' do
    let(:order) { build_stubbed(:order) }

    it 'enqueues checkout job' do
      expect(CheckoutJob).to receive(:perform_later).with("#{order.id}").once
      post :fill, id: order.id
    end

    it 'returns accepted status code' do
      post :fill, id: order.id
      expect(response).to have_http_status(202)
    end
  end
end
