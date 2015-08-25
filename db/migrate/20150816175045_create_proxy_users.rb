class CreateProxyUsers < ActiveRecord::Migration
  def change
    create_table :proxy_users do |t|
      t.belongs_to :user, index: true, null: false
      t.string :provider_type, null: false
      t.string :email, null: false
      t.string :password, null: false
      t.string :password_salt, null: false

      t.timestamps null: false

      t.index [:user_id, :provider_type], unique: true
      t.index :email, unique: true
    end

    add_foreign_key :proxy_users, 'User', column: :user_id
  end
end
