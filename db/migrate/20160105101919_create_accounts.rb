class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :partner_type, null: false
      t.string :email, null: false
      t.string :password, null: false
      t.string :password_salt, null: false
      t.string :aasm_state, null: false, default: 'pending'

      t.timestamps null: false

      t.index [:partner_type, :email], unique: true
    end
  end
end
