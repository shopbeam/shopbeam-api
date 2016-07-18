module API
  module V2
    module Entities
      module PartnerDetail
        class Entity
          def self.represent(objects, options)
            objects.map do |partner, partner_details|
              { id: partner.id,
                name: partner.name,
                commission: partner.commission,
                policyUrl: partner.policyUrl,
                partnerDetails: partner_details.map do |partner_detail|
                  {
                    state: partner_detail.state,
                    zip: partner_detail.zip,
                    shippingType: partner_detail.shippingType,
                    salesTax: partner_detail.salesTax,
                    freeShippingAbove: partner_detail.freeShippingAbove,
                    siteWideDiscount: partner_detail.siteWideDiscount,
                    shippingItems: partner_detail.item_count_shipping_costs
                      .select { |item| item['status'] == 1 }
                      .map do |item|
                      {
                        itemCount: item.item_count,
                        shippingPrice: item.shipping_price,
                      }
                    end
                  }
                end
              }
            end
          end
        end
      end
    end
  end
end
