class CreateClients < ActiveRecord::Migration
  def change
    create_table :clients do |t|
      t.string :referer

      t.timestamps null: false
    end
  end
end
