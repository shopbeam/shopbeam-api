class AddIndexUserOnApiKey < ActiveRecord::Migration
  def change
    add_index :User, :apiKey, unique: true
  end
end
