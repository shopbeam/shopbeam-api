class AddSubscribedToProxyUsers < ActiveRecord::Migration
  def change
    add_column :proxy_users, :subscribed, :boolean, default: true
  end
end
