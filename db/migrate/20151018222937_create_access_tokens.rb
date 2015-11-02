class CreateAccessTokens < ActiveRecord::Migration
  def change
    create_table :access_tokens do |t|
      t.references :consumer, index: true, foreign_key: true, null: false
      t.string :fingerprint, null: false
      t.string :token, null: false
      t.datetime :expires_at, null: false
      t.string :prev_token

      t.timestamps null: false

      t.index :fingerprint, unique: true
      t.index :token, unique: true
    end
  end
end
