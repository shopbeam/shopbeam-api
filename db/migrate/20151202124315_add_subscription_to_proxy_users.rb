class AddSubscriptionToProxyUsers < ActiveRecord::Migration
  def change
    add_column :proxy_users, :subscription, :text
  end
end
