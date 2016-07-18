require 'rails_helper'

describe API::V2::Products, api: :true do
  let(:url) { v2_products_path }
  subject do
    get url
    json_response
  end

  context "zero case" do
    it "returns empty array" do
      expect(subject).to eq []
      expect(response.status).to eq 200
    end
  end

  context "normal case" do
    let!(:product1) { create(:product) }
    let!(:product2) { create(:product) }
    let!(:variant1) { create(:variant, product: product1, color: 'red', listPriceCents: 2200, salePriceCents: 1100) }
    let!(:variant2) { create(:variant, product: product2, color: 'green', listPriceCents: 220, salePriceCents: 110) }
    let!(:variant3) { create(:variant, product: product2, color: 'blue', listPriceCents: 22000, salePriceCents: 11000) }

    it "returns 2 products and 3 variants" do
      expect(subject.count).to eq 2
      expect(subject.first['variants'].count).to eq 1
      expect(subject.second['variants'].count).to eq 2
      expect(response.status).to eq 200
    end

    context "parameters" do
      context "partner" do
        let(:url) { v2_products_path(params: { partner: "#{product1.brand.partner_id},666" }) }

        it "returns 1 product and 1 variant for specified partners" do
          expect(subject.first['partnerId']).to eq product1.brand.partner_id
        end
      end

      context "brand" do
        let(:url) { v2_products_path(params: { brand: "#{product2.brand_id},666" }) }

        it "returns 1 product 2 variants for specified brands" do
          expect(subject.first['brandId']).to eq product2.brand_id
        end
      end

      context "category" do
        let!(:product_category) { create(:product_category, product: product1) }
        let(:url) { v2_products_path(params: { category: "#{product_category.category_id},666" }) }

        it "returns 1 product 1 variants for specified category" do
          expect(subject.first['categories'].first['name']).to eq product_category.category.name
        end
      end

      context "color" do
        let(:url) { v2_products_path(params: { color: "#{variant1.color},#{variant2.color}" }) }

        it "returns 2 product 2 variants for specified colors" do
          expect(subject.count).to eq 2
        end

        context "variants of same product" do
          let(:url) { v2_products_path(params: { color: "#{variant3.color},#{variant2.color}" }) }

          it "returns 1 product 2 variants for specified colors" do
            expect(subject.count).to eq 1
            expect(subject.first['variants'].count).to eq 2
          end
        end
      end

      context "size" do
        let(:url) { v2_products_path(params: { size: "#{variant1.size},zzz" }) }

        it "returns 1 product 1 variants for specified category" do
          expect(subject.first['variants'].first['size']).to eq variant1.size
        end
      end

      context "minprice" do
        let(:price) { variant1.list_price_cents }
        let(:url) { v2_products_path(params: { minprice: price }) }

        it "returns products with higher price" do
          subject.first['variants'].each do |v|
            calculated = [v['listPrice'], v['salePrice']].min
            expect(calculated).to be >= price
          end
        end
      end

      context "maxprice" do
        let(:price) { variant1.list_price_cents }
        let(:url) { v2_products_path(params: { maxprice: price }) }

        it "returns products with lower price" do
          subject.first['variants'].each do |v|
            calculated = [v['listPrice'], v['salePrice']].max
            expect(calculated).to be <= price
          end
        end
      end
    end
  end
end
