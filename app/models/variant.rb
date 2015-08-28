class Variant < ActiveRecord::Base
  self.table_name = 'Variant'

  alias_attribute :source_url, :sourceUrl
end
