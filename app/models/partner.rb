class Partner < ActiveRecord::Base
  self.table_name = 'Partner'

  has_many :brands
  has_many :details, -> { active }, foreign_key: :PartnerId, class_name: 'PartnerDetail'

  alias_attribute :linkshare_id, :linkshareId

  scope :active, -> { where(status: 1) }

  def commission_percent
    commission / 100.0
  end
end
