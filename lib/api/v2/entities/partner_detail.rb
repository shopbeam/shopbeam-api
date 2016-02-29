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
                  partnerDetails: results.map do |r|
                    {
                      state: r.state,
                      zip: r.zip,
                      shippingType: r.shippingType,
                      salesTax: r.salesTax,
                      freeShippingAbove: r.freeShippingAbove,
                      siteWideDiscount: r.siteWideDiscount
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
          end
        end
      end
    end
  end
end
