class CreateAuthTokens < ActiveRecord::Migration
  def change
    create_table :auth_tokens do |t|
      t.references :owner, polymorphic: true, null: false
      t.string :key, null: false
      t.string :secret, null: false

      t.timestamps null: false

      t.index [:owner_id, :owner_type]
      t.index :key, unique: true
      t.index :secret, unique: true
    end
  end
end
