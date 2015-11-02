class CreateConsumers < ActiveRecord::Migration
  def change
    create_table :consumers do |t|
      t.string :email, null: false
      t.string :password_digest, null: false
      t.references :client, index: true, foreign_key: true, null: false

      t.timestamps null: false

      t.index :email, unique: true
    end
  end
end
