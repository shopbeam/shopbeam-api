class ChangeProxyUsersSubscription < ActiveRecord::Migration
  def up
    remove_column :proxy_users, :subscribed

    Class.new(ActiveRecord::Base) do
      self.table_name = 'proxy_users'
      serialize :subscription, Hash

      all.each do |proxy_user|
        proxy_user.update!(subscription: { 'orders' => '1', 'promotions' => '1' })
      end
    end
  end

  def down
    add_column :proxy_users, :subscribed, :boolean, default: true
  end
end
