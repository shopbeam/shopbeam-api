class UpdatePartnerTypeInProxyUsers < ActiveRecord::Migration
  def up
    execute <<-SQL
      UPDATE proxy_users
      SET partner_type =
        CASE partner_type
          WHEN 'Checkout::Partners::WellCa'       THEN 'WellCa'
          WHEN 'Checkout::Partners::LacosteComUs' THEN 'LacosteComUs'
        END
    SQL
  end

  def down
    execute <<-SQL
      UPDATE proxy_users
      SET partner_type =
        CASE partner_type
          WHEN 'WellCa'       THEN 'Checkout::Partners::WellCa'
          WHEN 'LacosteComUs' THEN 'Checkout::Partners::LacosteComUs'
        END
    SQL
  end
end
