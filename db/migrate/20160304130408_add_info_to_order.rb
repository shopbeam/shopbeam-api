class AddInfoToOrder < ActiveRecord::Migration
  def change
    enable_extension 'hstore' unless extension_enabled?('hstore')
    add_column 'Order', :info, :hstore
  end
end
