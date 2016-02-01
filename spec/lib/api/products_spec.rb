require 'rails_helper'

describe API::V1::Products, type: :request do
  let(:url) { "/products" }
  subject do
    get url
    JSON.parse(response.body)
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
        let(:url) { "/products?partner=#{product1.brand.partner_id},666" }

        it "returns 1 product and 1 variant for specified partners" do
          expect(subject.first['partnerId']).to eq product1.brand.partner_id
        end
      end

      context "brand" do
        let(:url) { "/products?brand=#{product2.brand_id},666" }

        it "returns 1 product 2 variants for specified brands" do
          expect(subject.first['brandId']).to eq product2.brand_id
        end
      end

      context "category" do
        let!(:product_category) { create(:product_category, product: product1) }
        let(:url) { "/products?category=#{product_category.category_id},666" }

        it "returns 1 product 1 variants for specified category" do
          expect(subject.first['categories'].first['name']).to eq product_category.category.name
        end
      end

      context "color" do
        let(:url) { "/products?color=#{variant1.color},#{variant2.color}" }

        it "returns 2 product 2 variants for specified colors" do
          expect(subject.count).to eq 2
        end

        context "variants of same product" do
          let(:url) { "/products?color=#{variant3.color},#{variant2.color}" }

          it "returns 1 product 2 variants for specified colors" do
            expect(subject.count).to eq 1
            expect(subject.first['variants'].count).to eq 2
          end
        end
      end

      context "size" do
        let(:url) { "/products?size=#{variant1.size},zzz" }

        it "returns 1 product 1 variants for specified category" do
          expect(subject.first['variants'].first['size']).to eq variant1.size
        end
      end

      context "minprice" do
        let(:price) { variant1.list_price_cents }
        let(:url) { "/products?minprice=#{price}" }

        it "returns products with higher price" do
          subject.first['variants'].each do |v|
            calculated = [v['listPrice'], v['salePrice']].min
            expect(calculated).to be >= price
          end
        end
      end

      context "maxprice" do
        let(:price) { variant1.list_price_cents }
        let(:url) { "/products?maxprice=#{price}" }

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
