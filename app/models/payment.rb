class Payment < ActiveRecord::Base
  self.table_name = 'Payment'
  self.inheritance_column = nil
end
