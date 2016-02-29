class Partner < ActiveRecord::Base
  self.table_name = 'Partner'

  has_many :brands
  has_many :partner_details, foreign_key: :PartnerId

  alias_attribute :linkshare_id, :linkshareId

  scope :active, -> { where(status: 1) }
end
