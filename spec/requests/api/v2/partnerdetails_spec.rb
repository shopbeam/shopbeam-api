require 'rails_helper'

describe API::V2::PartnerDetails, api: :true do
  context 'for active partners' do
    context 'with active details' do
      it 'matches response schema' do
        partner = create(:partner, status: 1)
        partner_detail = create(:partner_detail, partner: partner, status: 1)
        shipping_item = create(:item_count_shipping_cost, partner_detail: partner_detail, status: 1)

        get v2_partnerdetails_path

        expect(response).to match_response_schema('partners')
      end

      it 'returns partners in correct order' do
        partner1 = create(:partner, :with_active_details, status: 1)
        partner2 = create(:partner, :with_active_details, status: 1)

        get v2_partnerdetails_path

        expect(response).to have_http_status(200)
        expect(partner_ids).to eq([partner1.id, partner2.id])
      end

      it 'returns details in correct order' do
        partner = create(:partner, status: 1)
        partner_detail_wy_9 = create(:partner_detail, partner: partner, status: 1, state: 'WY', zip: '99999')
        partner_detail_wy_1 = create(:partner_detail, partner: partner, status: 1, state: 'WY', zip: '11111')
        partner_detail_al_5 = create(:partner_detail, partner: partner, status: 1, state: 'AL', zip: '55555')

        get v2_partnerdetails_path

        expect(response).to have_http_status(200)
        expect(partner_details('state')).to eq([
          partner_detail_al_5.state,
          partner_detail_wy_1.state,
          partner_detail_wy_9.state
        ])
        expect(partner_details('zip')).to eq([
          partner_detail_al_5.zip,
          partner_detail_wy_1.zip,
          partner_detail_wy_9.zip
        ])
      end

      it 'contains active details' do
        partner = create(:partner, status: 1)
        active_partner_detail = create(:partner_detail, partner: partner, status: 1, state: 'AL')
        inactive_partner_detail = create(:partner_detail, partner: partner, status: 0, state: 'CA')

        get v2_partnerdetails_path

        expect(response).to have_http_status(200)
        expect(partner_details('state')).to contain_exactly(active_partner_detail.state)
      end

      it 'returns shipping items in correct order' do
        partner = create(:partner, status: 1)
        partner_detail = create(:partner_detail, partner: partner, status: 1)
        shipping_item_200 = create(:item_count_shipping_cost, partner_detail: partner_detail, status: 1, itemCount: 200)
        shipping_item_100 = create(:item_count_shipping_cost, partner_detail: partner_detail, status: 1, itemCount: 100)

        get v2_partnerdetails_path

        expect(response).to have_http_status(200)
        item_counts = partner_details('shippingItems').first.map { |item| item['itemCount'] }
        expect(item_counts).to eq([shipping_item_100.itemCount, shipping_item_200.itemCount])
      end

      it 'contains active shipping items' do
        partner = create(:partner, status: 1)
        partner_detail = create(:partner_detail, partner: partner, status: 1)
        active_shipping_item = create(:item_count_shipping_cost, partner_detail: partner_detail, status: 1, itemCount: 100)
        inactive_shipping_item = create(:item_count_shipping_cost, partner_detail: partner_detail, status: 0, itemCount: 200)

        get v2_partnerdetails_path

        expect(response).to have_http_status(200)
        item_counts = partner_details('shippingItems').first.map { |item| item['itemCount'] }
        expect(item_counts).to contain_exactly(active_shipping_item.itemCount)
      end

      context 'when details found' do
        it 'returns details filtered by single partner' do
          partner1 = create(:partner, :with_active_details, status: 1)
          partner2 = create(:partner, :with_active_details, status: 1)

          get v2_partnerdetails_path, partner: partner2.id

          expect(response).to have_http_status(200)
          expect(partner_ids).to contain_exactly(partner2.id)
        end

        it 'returns details filtered by multiple partners' do
          partner1 = create(:partner, :with_active_details, status: 1)
          partner2 = create(:partner, :with_active_details, status: 1)
          partner3 = create(:partner, :with_active_details, status: 1)

          get v2_partnerdetails_path, partner: "#{partner1.id},#{partner3.id}"

          expect(response).to have_http_status(200)
          expect(partner_ids).to contain_exactly(partner1.id, partner3.id)
        end

        it 'returns details filtered by single state' do
          partner = create(:partner, status: 1)
          partner_detail_al = create(:partner_detail, partner: partner, status: 1, state: 'AL')
          partner_detail_ca = create(:partner_detail, partner: partner, status: 1, state: 'CA')

          get v2_partnerdetails_path, state: 'CA'

          expect(response).to have_http_status(200)
          expect(partner_details('state')).to contain_exactly(partner_detail_ca.state)
        end

        it 'returns details filtered by multiple states' do
          partner = create(:partner, status: 1)
          partner_detail_al = create(:partner_detail, partner: partner, status: 1, state: 'AL')
          partner_detail_ca = create(:partner_detail, partner: partner, status: 1, state: 'CA')
          partner_detail_ny = create(:partner_detail, partner: partner, status: 1, state: 'NY')

          get v2_partnerdetails_path, state: 'AL,NY'

          expect(response).to have_http_status(200)
          expect(partner_details('state')).to contain_exactly(partner_detail_al.state, partner_detail_ny.state)
        end

        it 'returns details filtered by partner and state' do
          partner1 = create(:partner, status: 1)
          partner2 = create(:partner, status: 1)
          partner1_detail_ca = create(:partner_detail, partner: partner1, status: 1, state: 'CA')
          partner2_detail_ca = create(:partner_detail, partner: partner2, status: 1, state: 'CA')

          get v2_partnerdetails_path, partner: partner2.id, state: 'CA'

          expect(response).to have_http_status(200)
          expect(partner_details('state')).to contain_exactly(partner2_detail_ca.state)
        end
      end

      context 'when no details found' do
        it 'returns empty list' do
          partner = create(:partner, status: 1)
          partner_detail = create(:partner_detail, partner: partner, status: 1, state: 'AL')

          get v2_partnerdetails_path, state: 'CA'

          expect(response).to have_http_status(200)
          expect(json_response).to be_empty
        end
      end
    end

    context 'with no active details' do
      it 'returns empty list' do
        partner = create(:partner, status: 1)
        partner_detail = create(:partner_detail, partner: partner, status: 0)

        get v2_partnerdetails_path

        expect(response).to have_http_status(200)
        expect(json_response).to be_empty
      end
    end
  end

  context 'for inactive partners' do
    it 'returns empty list' do
      partner = create(:partner, :with_active_details, status: 0)

      get v2_partnerdetails_path

      expect(response).to have_http_status(200)
      expect(json_response).to be_empty
    end
  end

  def partner_ids
    json_response.map { |partner| partner['id'] }
  end

  def partner_details(field)
    json_response.inject([]) do |memo, partner|
      partner['partnerDetails'].each do |detail|
        memo << detail[field]
      end

      memo
    end
  end
end
