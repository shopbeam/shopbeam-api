class ChangeStateInAddress < ActiveRecord::Migration
  def up
    change_column_null 'Address', :state, true
  end

  def down
    change_column_null 'Address', :state, false
  end
end
