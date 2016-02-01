class AddValiadtedAtToPartner < ActiveRecord::Migration
  def change
    add_column 'Partner', :validatedAt, :float, default: 0, null: false
    add_column 'Brand', :validatedAt, :float, default: 0, null: false
    add_column 'Category', :validatedAt, :float, default: 0, null: false
  end
end
