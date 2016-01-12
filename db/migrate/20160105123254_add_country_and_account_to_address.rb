class AddCountryAndAccountToAddress < ActiveRecord::Migration
  def change
    add_column 'Address', :country, :string
    add_reference 'Address', :account, index: true, foreign_key: true
  end
end
