class Partner < ActiveRecord::Base
  self.table_name = 'Partner'

  has_many :brands

  alias_attribute :linkshare_id, :linkshareId

  scope :active, -> { where(status: 1) }
end
