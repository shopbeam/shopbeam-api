class AddDemoToProducts < ActiveRecord::Migration
  def change
    add_column 'Product', :demo, :boolean, default: false, null: false
  end
end
