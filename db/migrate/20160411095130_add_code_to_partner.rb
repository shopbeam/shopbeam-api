class AddCodeToPartner < ActiveRecord::Migration
  def up
    add_column 'Partner', :code, :string
    execute 'CREATE UNIQUE INDEX index_partner_on_code ON "Partner" USING btree (lower(code))'
  end

  def down
    remove_column 'Partner', :code
  end
end
