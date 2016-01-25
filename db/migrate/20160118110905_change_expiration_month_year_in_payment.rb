class ChangeExpirationMonthYearInPayment < ActiveRecord::Migration
  def up
    change_column 'Payment', :expirationMonth, :string
    change_column 'Payment', :expirationYear, :string
  end

  def down
    execute 'ALTER TABLE "Payment" ALTER COLUMN "expirationMonth" TYPE integer USING "expirationMonth"::integer'
    execute 'ALTER TABLE "Payment" ALTER COLUMN "expirationYear" TYPE integer USING "expirationYear"::integer'
  end
end
