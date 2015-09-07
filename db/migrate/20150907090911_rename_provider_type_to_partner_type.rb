class RenameProviderTypeToPartnerType < ActiveRecord::Migration
  def change
    rename_column :proxy_users, :provider_type, :partner_type
  end
end
