module API
  module V2
    module Entities
      module PartnerDetail
        class Entity
          class << self
            def represent(records, opts)
              group_by_partner(records) do |partner, results|
                { id: partner.id,
                  name: partner.name,
                  commission: partner.commission,
                  policyUrl: partner.policyUrl,
                  partnerDetails: group_by_state(results) do |r, res|
                    {
                      state: r.state,
                      zip: r.zip,
                      shippingType: r.shippingType,
                      salesTax: r.salesTax,
                      freeShippingAbove: r.freeShippingAbove,
                      siteWideDiscount: r.siteWideDiscount,
                      shippingItems: res.map do |rr|
                        {
                          itemCount: rr.item_count_shipping_cost.item_count,
                          shippingPrice: rr.item_count_shipping_cost.shipping_price,
                        }
                      end
                    }
                  end
                }
              end
            end

            def group_by_partner(records)
              grouped = {}
              records.each do |r|
                grouped[r.partner] ||= []
                grouped[r.partner] << r
              end
              grouped.map do |partner, results|
                yield partner, results
              end
            end

            def group_by_state(records)
              grouped = {}
              records.each do |r|
                grouped[r.state] ||= []
                grouped[r.state] << r
              end
              grouped.map do |state, results|
                yield results.first, results
              end
            end
          end
        end
      end
    end
  end
end
