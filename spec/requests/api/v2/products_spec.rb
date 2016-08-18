require 'rails_helper'

# TODO: create full with active parents by default?
# TODO: check nested data count?
# TODO: omit active parents creation
# TODO: omit local var which never been used?
# TODO: verify object.value vs actual value, eg.: product.price vs 100
# TODO: status: 1 (active) by default?
# TODO: by_entity vs by entity_id?
# TODO: no need to test compound filters in partner details?
# TODO: extract all entities from models
# TODO: add spec for aggregateminmaxprice_trigger in Product
# TODO: use arel instead of raw SQL?
# TODO: add spec for updatesalepercent_trigger in Product
# TODO: modify OrderItem#price_cents and handle case when sale_price_cents is 0 (if not, add validation???)
# TODO: extra queries regardless includes???
describe API::V2::Products, api: :true do
  describe 'GET /' do
    context 'when products are active' do
      context 'with active variants' do
        context 'when brand is active' do
          context 'when partner is active' do
            it 'matches response schema' do
              partner = create(:partner, status: 1)
              brand = create(:brand, partner: partner, status: 1)
              product = create(:product, :full, brand: brand, status: 1)

              get v2_products_path

              expect(response).to have_http_status(200)
              expect(json_response).not_to be_empty
              expect(response).to match_response_schema('products')
            end

            it 'contains active categories' do
              product = create(:product, :with_variants, status: 1)
              active_category_1 = create(:category, status: 1)
              active_category_2 = create(:category, status: 1)
              inactive_category_1 = create(:category, status: 0)
              inactive_category_2 = create(:category, status: 0)
              create(:product_category, product: product, category: active_category_1, status: 1)
              create(:product_category, product: product, category: active_category_2, status: 0)
              create(:product_category, product: product, category: inactive_category_1, status: 1)
              create(:product_category, product: product, category: inactive_category_2, status: 0)

              get v2_products_path

              expect(response).to have_http_status(200)
              category_ids = list('categories').map { |category| category['id'] }
              expect(category_ids).to contain_exactly(active_category_1.id)
            end

            it 'contains active variants' do
              product = create(:product, status: 1)
              active_variant = create(:variant, product: product, status: 1)
              inactive_variant = create(:variant, product: product, status: 0)

              get v2_products_path

              expect(response).to have_http_status(200)
              expect(variant_ids).to contain_exactly(active_variant.id)
            end

            it 'contains active variant images' do
              product = create(:product, status: 1)
              variant = create(:variant, product: product, status: 1)
              active_variant_image = create(:variant_image, variant: variant, status: 1)
              inactive_variant_image = create(:variant_image, variant: variant, status: 0)

              get v2_products_path

              expect(response).to have_http_status(200)
              variant_image_ids = list('variants').first['images'].map { |image| image['id'] }
              expect(variant_image_ids).to contain_exactly(active_variant_image.id)
            end

            it 'contains calculated min list price' do
              product = create(:product, status: 1)
              create(:variant, product: product, status: 0, listPriceCents: 200)
              create(:variant, product: product, status: 1, listPriceCents: 300)
              create(:variant, product: product, status: 1, listPriceCents: 400)

              get v2_products_path

              expect(response).to have_http_status(200)
              expect(json_response.first['minListPrice']).to eq(300)
            end

            it 'contains calculated max list price' do
              product = create(:product, status: 1)
              create(:variant, product: product, status: 1, listPriceCents: 500)
              create(:variant, product: product, status: 1, listPriceCents: 600)
              create(:variant, product: product, status: 0, listPriceCents: 700)

              get v2_products_path

              expect(response).to have_http_status(200)
              expect(json_response.first['maxListPrice']).to eq(600)
            end

            it 'returns products filtered by single variant id' do
              product_1 = create(:product, status: 1)
              product_2 = create(:product, status: 1)
              variant_1 = create(:variant, product: product_1, status: 1)
              variant_2 = create(:variant, product: product_2, status: 1)

              get v2_products_path, id: variant_2.id

              expect(response).to have_http_status(200)
              expect(product_ids).to contain_exactly(product_2.id)
              expect(variant_ids).to contain_exactly(variant_2.id)
            end

            it 'returns products filtered by multiple variant ids' do
              product_1 = create(:product, status: 1)
              product_2 = create(:product, status: 1)
              product_3 = create(:product, :with_variants, status: 1)
              variant_1 = create(:variant, product: product_1, status: 1)
              variant_2 = create(:variant, product: product_1, status: 1)
              variant_3 = create(:variant, product: product_2, status: 1)

              get v2_products_path, id: "#{variant_1.id},#{variant_3.id}"

              expect(response).to have_http_status(200)
              expect(product_ids).to contain_exactly(product_1.id, product_2.id)
              expect(variant_ids).to contain_exactly(variant_1.id, variant_3.id)
            end

            it 'returns products filtered by single partner id' do
              partner_1 = create(:partner, status: 1)
              partner_2 = create(:partner, status: 1)
              brand_1 = create(:brand, partner: partner_1, status: 1)
              brand_2 = create(:brand, partner: partner_2, status: 1)
              product_1 = create(:product, :with_variants, brand: brand_1, status: 1)
              product_2 = create(:product, :with_variants, brand: brand_2, status: 1)

              get v2_products_path, partner: partner_2.id

              expect(response).to have_http_status(200)
              expect(product_ids).to contain_exactly(product_2.id)
            end

            it 'returns products filtered by multiple partner ids' do
              partner_1 = create(:partner, status: 1)
              partner_2 = create(:partner, status: 1)
              partner_3 = create(:partner, status: 1)
              brand_1 = create(:brand, partner: partner_1, status: 1)
              brand_2 = create(:brand, partner: partner_2, status: 1)
              brand_3 = create(:brand, partner: partner_3, status: 1)
              product_1 = create(:product, :with_variants, brand: brand_1, status: 1)
              product_2 = create(:product, :with_variants, brand: brand_2, status: 1)
              product_3 = create(:product, :with_variants, brand: brand_3, status: 1)

              get v2_products_path, partner: "#{partner_1.id},#{partner_3.id}"

              expect(response).to have_http_status(200)
              expect(product_ids).to contain_exactly(product_1.id, product_3.id)
            end

            it 'returns products filtered by single brand id' do
              brand_1 = create(:brand, status: 1)
              brand_2 = create(:brand, status: 1)
              product_1 = create(:product, :with_variants, brand: brand_1, status: 1)
              product_2 = create(:product, :with_variants, brand: brand_2, status: 1)

              get v2_products_path, brand: brand_2.id

              expect(response).to have_http_status(200)
              expect(product_ids).to contain_exactly(product_2.id)
            end

            it 'returns products filtered by multiple brand ids' do
              brand_1 = create(:brand, status: 1)
              brand_2 = create(:brand, status: 1)
              brand_3 = create(:brand, status: 1)
              product_1 = create(:product, :with_variants, brand: brand_1, status: 1)
              product_2 = create(:product, :with_variants, brand: brand_2, status: 1)
              product_3 = create(:product, :with_variants, brand: brand_3, status: 1)

              get v2_products_path, brand: "#{brand_1.id},#{brand_3.id}"

              expect(response).to have_http_status(200)
              expect(product_ids).to contain_exactly(product_1.id, product_3.id)
            end

            it 'returns products filtered by single category id' do
              product_1 = create(:product, :with_variants, status: 1)
              product_2 = create(:product, :with_variants, status: 1)
              category_1 = create(:category, status: 1)
              category_2 = create(:category, status: 1)
              create(:product_category, product: product_1, category: category_1, status: 1)
              create(:product_category, product: product_2, category: category_2, status: 1)

              get v2_products_path, category: category_2.id

              expect(response).to have_http_status(200)
              expect(product_ids).to contain_exactly(product_2.id)
              category_ids = list('categories').map { |category| category['id'] }
              expect(category_ids).to contain_exactly(category_2.id)
            end

            it 'returns products filtered by multiple category ids' do
              product_1 = create(:product, :with_variants, status: 1)
              product_2 = create(:product, :with_variants, status: 1)
              product_3 = create(:product, :full, status: 1)
              category_1 = create(:category, status: 1)
              category_2 = create(:category, status: 1)
              category_3 = create(:category, status: 1)
              create(:product_category, product: product_1, category: category_1, status: 1)
              create(:product_category, product: product_1, category: category_2, status: 1)
              create(:product_category, product: product_2, category: category_3, status: 1)

              get v2_products_path, category: "#{category_1.id},#{category_3.id}"

              expect(response).to have_http_status(200)
              expect(product_ids).to contain_exactly(product_1.id, product_2.id)
              category_ids = list('categories').map { |category| category['id'] }
              expect(category_ids).to contain_exactly(category_1.id, category_3.id)
            end

            it 'returns products filtered by min price' do
              product_1 = create(:product, status: 1)
              product_2 = create(:product, status: 1)
              product_3 = create(:product, status: 1)
              variant_1 = create(:variant, product: product_1, status: 1, salePriceCents: nil, listPriceCents: 200)
              variant_2 = create(:variant, product: product_1, status: 1, salePriceCents: 0, listPriceCents: 200)
              variant_3 = create(:variant, product: product_1, status: 1, salePriceCents: 100, listPriceCents: 200)
              variant_4 = create(:variant, product: product_1, status: 1, salePriceCents: 200, listPriceCents: 200)
              variant_5 = create(:variant, product: product_2, status: 1, salePriceCents: 50, listPriceCents: 50)
              variant_6 = create(:variant, product: product_3, status: 1, salePriceCents: 50, listPriceCents: 150)
              variant_7 = create(:variant, product: product_3, status: 1, salePriceCents: 150, listPriceCents: 150)

              get v2_products_path, minprice: 100

              expect(response).to have_http_status(200)
              expect(product_ids).to contain_exactly(product_1.id, product_3.id)
              expect(variant_ids).to contain_exactly(variant_1.id, variant_2.id, variant_3.id, variant_4.id, variant_7.id)
            end

            it 'returns products filtered by max price' do
              product_1 = create(:product, status: 1)
              product_2 = create(:product, status: 1)
              product_3 = create(:product, status: 1)
              variant_1 = create(:variant, product: product_1, status: 1, salePriceCents: nil, listPriceCents: 200)
              variant_2 = create(:variant, product: product_1, status: 1, salePriceCents: 0, listPriceCents: 200)
              variant_3 = create(:variant, product: product_1, status: 1, salePriceCents: 100, listPriceCents: 200)
              variant_4 = create(:variant, product: product_1, status: 1, salePriceCents: 200, listPriceCents: 200)
              variant_5 = create(:variant, product: product_2, status: 1, salePriceCents: 150, listPriceCents: 150)
              variant_6 = create(:variant, product: product_3, status: 1, salePriceCents: 50, listPriceCents: 150)
              variant_7 = create(:variant, product: product_3, status: 1, salePriceCents: 150, listPriceCents: 150)

              get v2_products_path, maxprice: 100

              expect(response).to have_http_status(200)
              expect(product_ids).to contain_exactly(product_1.id, product_3.id)
              expect(variant_ids).to contain_exactly(variant_3.id, variant_6.id)
            end

            it 'returns products filtered by sale' do
              product_1 = create(:product, status: 1)
              product_2 = create(:product, status: 1)
              product_3 = create(:product, status: 1)
              variant_1 = create(:variant, product: product_1, status: 1, salePriceCents: nil, listPriceCents: 100)
              variant_2 = create(:variant, product: product_1, status: 1, salePriceCents: 0, listPriceCents: 100)
              variant_3 = create(:variant, product: product_1, status: 1, salePriceCents: 50, listPriceCents: 100)
              variant_4 = create(:variant, product: product_2, status: 1, salePriceCents: 100, listPriceCents: 100)
              variant_5 = create(:variant, product: product_3, status: 1, salePriceCents: 70, listPriceCents: 100)
              variant_6 = create(:variant, product: product_3, status: 1, salePriceCents: 80, listPriceCents: 100)

              get v2_products_path, sale: 30

              expect(response).to have_http_status(200)
              expect(product_ids).to contain_exactly(product_1.id, product_3.id)
              expect(variant_ids).to contain_exactly(variant_3.id, variant_5.id)
            end

            it 'returns products searched for term' do
              product_1 = create(:product, :with_variants, status: 1, searchText: 'Black Polo')
              product_2 = create(:product, :with_variants, status: 1, searchText: 'White Shirt')

              get v2_products_path, q: 'shirt'

              expect(response).to have_http_status(200)
              expect(product_ids).to contain_exactly(product_2.id)
            end

            it 'returns products sorted by date created DESC' do
              product_1 = create(:product, :with_variants, status: 1, createdAt: 2.days.ago)
              product_2 = create(:product, :with_variants, status: 1, createdAt: 3.days.ago)
              product_3 = create(:product, :with_variants, status: 1, createdAt: 1.day.ago)

              get v2_products_path, sortby: :recent

              expect(response).to have_http_status(200)
              expect(product_ids).to eq([product_3.id, product_1.id, product_2.id])
            end

            it 'returns products sorted by min price ASC' do
              product_1 = create(:product, status: 1)
              product_2 = create(:product, status: 1)
              product_3 = create(:product, status: 1)
              variant_1 = create(:variant, product: product_1, status: 1, salePriceCents: nil, listPriceCents: 100)
              variant_2 = create(:variant, product: product_1, status: 1, salePriceCents: 0, listPriceCents: 100)
              variant_3 = create(:variant, product: product_1, status: 1, salePriceCents: 70, listPriceCents: 100)
              variant_4 = create(:variant, product: product_2, status: 1, salePriceCents: 100, listPriceCents: 100)
              variant_5 = create(:variant, product: product_3, status: 1, salePriceCents: 50, listPriceCents: 100)
              variant_6 = create(:variant, product: product_3, status: 1, salePriceCents: 80, listPriceCents: 100)

              get v2_products_path, sortby: :lowtohigh

              expect(response).to have_http_status(200)
              expect(product_ids).to eq([product_3.id, product_1.id, product_2.id])
            end

            it 'returns products sorted by max price DESC' do
              product_1 = create(:product, status: 1)
              product_2 = create(:product, status: 1)
              product_3 = create(:product, status: 1)
              variant_1 = create(:variant, product: product_1, status: 1, salePriceCents: nil, listPriceCents: 70)
              variant_2 = create(:variant, product: product_1, status: 1, salePriceCents: 0, listPriceCents: 70)
              variant_3 = create(:variant, product: product_1, status: 1, salePriceCents: 70, listPriceCents: 70)
              variant_4 = create(:variant, product: product_2, status: 1, salePriceCents: 100, listPriceCents: 100)
              variant_5 = create(:variant, product: product_3, status: 1, salePriceCents: 50, listPriceCents: 80)
              variant_6 = create(:variant, product: product_3, status: 1, salePriceCents: 80, listPriceCents: 80)

              get v2_products_path, sortby: :hightolow

              expect(response).to have_http_status(200)
              expect(product_ids).to eq([product_2.id, product_3.id, product_1.id])
            end

            it 'returns products sorted by relevance DESC' do
              product_1 = create(:product, :with_variants, status: 1, searchText: 'Harlow Coated Leggings')
              product_2 = create(:product, :with_variants, status: 1, searchText: 'Fabric Coat Armani Coats Coats')
              product_3 = create(:product, :with_variants, status: 1, searchText: 'Rain Coat Apparel Jackets and Coats')

              get v2_products_path, q: 'coat', sortby: :relevance

              expect(response).to have_http_status(200)
              expect(product_ids).to eq([product_2.id, product_3.id, product_1.id])
            end

            it 'returns products limited by count' do
              create_list(:product, 3, :with_variants, status: 1)

              get v2_products_path, limit: 2

              expect(response).to have_http_status(200)
              expect(product_ids.size).to eq(2)
            end

            it 'returns products shifted by offset' do
              create_list(:product, 3, :with_variants, status: 1)

              get v2_products_path, limit: 2, offset: 2

              expect(response).to have_http_status(200)
              expect(product_ids.size).to eq(1)
            end
          end

          context 'when partner is not active' do
            it 'returns empty list' do
              partner = create(:partner, status: 0)
              brand = create(:brand, partner: partner, status: 1)
              product = create(:product, :with_variants, brand: brand, status: 1)

              get v2_products_path

              expect(response).to have_http_status(200)
              expect(json_response).to be_empty
            end
          end
        end

        context 'when brand is not active' do
          it 'returns empty list' do
            partner = create(:partner, status: 1)
            brand = create(:brand, partner: partner, status: 0)
            product = create(:product, :with_variants, brand: brand, status: 1)

            get v2_products_path

            expect(response).to have_http_status(200)
            expect(json_response).to be_empty
          end
        end
      end

      context 'with no active variants' do
        it 'returns empty list' do
          product = create(:product, status: 1)
          variant = create(:variant, product: product, status: 0)

          get v2_products_path

          expect(response).to have_http_status(200)
          expect(json_response).to be_empty
        end
      end
    end

    context 'when products are not active' do
      it 'returns empty list' do
        partner = create(:product, :with_variants, status: 0)

        get v2_products_path

        expect(response).to have_http_status(200)
        expect(json_response).to be_empty
      end
    end
  end

  private

  def list(field)
    json_response.map { |product| product[field] }.flatten
  end

  def product_ids
    list('id')
  end

  def variant_ids
    list('variants').map { |variant| variant['id'] }
  end
end
