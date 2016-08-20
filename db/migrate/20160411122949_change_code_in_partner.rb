class ChangeCodeInPartner < ActiveRecord::Migration
  PARTNER_CODES = {
    'Advertising Week' => 'advertisingweek_eu',
    'Lacoste'          => 'lacoste_com_us',
    'Target.com'       => 'target_com',
    'TESTv2-Well.ca'   => 'well_ca',
    'Well.ca'          => 'well_ca'
  }

  def up
    result = Hash.new { |hash, key| hash[key] = Hash.new(&hash.default_proc) }

    Class.new(ActiveRecord::Base) do
      self.table_name = 'Partner'

      find_each do |partner|
        result[partner.id][:code] = PARTNER_CODES[partner.name] || partner.name.parameterize.underscore
      end

      update(result.keys, result.values)
    end

    change_column_null 'Partner', :code, false
    execute 'ALTER TABLE ONLY "Partner" DROP CONSTRAINT "Partner_name_key"'
  end

  def down
    execute 'ALTER TABLE ONLY "Partner" ADD CONSTRAINT "Partner_name_key" UNIQUE (name)'
    change_column_null 'Partner', :code, true
    execute 'UPDATE "Partner" SET code = NULL'
  end
end
