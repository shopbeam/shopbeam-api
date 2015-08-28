class AddNumberSaltToPayment < ActiveRecord::Migration
  def change
    add_column 'Payment', :numberSalt, :string
  end
end
