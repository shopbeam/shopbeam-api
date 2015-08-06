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

    it 'returns accepted status code' do
      expect(response).to have_http_status(202)
    end
  end
end
