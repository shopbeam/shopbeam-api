class AddThemeToOrders < ActiveRecord::Migration
  def change
    add_column 'Order', :theme, :string, null: false, default: 'default'
  end
end
