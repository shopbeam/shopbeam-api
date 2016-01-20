class RenameNumberSaltToSalt < ActiveRecord::Migration
  def change
    rename_column 'Payment', :numberSalt, :salt
  end
end
