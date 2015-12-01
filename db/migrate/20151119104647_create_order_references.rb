class CreateOrderReferences < ActiveRecord::Migration
  def change
    create_table :order_references do |t|
      t.belongs_to :order, index: true, null: false
      t.string :partner_type, null: false
      t.string :number, null: false

      t.timestamps null: false

      t.index [:partner_type, :number], unique: true
    end

    add_foreign_key :order_references, 'Order', column: :order_id
  end
end
