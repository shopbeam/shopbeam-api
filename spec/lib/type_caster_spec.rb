require 'rails_helper'

describe TypeCaster do
  %i(string text integer float decimal boolean).each do |type|
    shared_examples_for "#{type} caster" do |result|
      input, output = result.first

      it "and casts #{input.inspect} as #{output.inspect}" do
        expect(described_class.cast(input, type)).to eq(output)
      end
    end
  end

  %w(string text).each do |type|
    it_behaves_like "#{type} caster", nil      => nil
    it_behaves_like "#{type} caster", ''       => ''
    it_behaves_like "#{type} caster", ' '      => ' '
    it_behaves_like "#{type} caster", 'string' => 'string'
    it_behaves_like "#{type} caster", true     => '1'
    it_behaves_like "#{type} caster", 'true'   => 'true'
    it_behaves_like "#{type} caster", false    => '0'
    it_behaves_like "#{type} caster", 'false'  => 'false'
  end

  it_behaves_like 'integer caster', nil        => nil
  it_behaves_like 'integer caster', 1          => 1
  it_behaves_like 'integer caster', '1'        => 1
  it_behaves_like 'integer caster', '1ignore'  => 1
  it_behaves_like 'integer caster', 'bad1'     => 0
  it_behaves_like 'integer caster', 'bad'      => 0
  it_behaves_like 'integer caster', 1.7        => 1
  it_behaves_like 'integer caster', false      => 0
  it_behaves_like 'integer caster', true       => 1
  it_behaves_like 'integer caster', [1, 2]     => nil
  it_behaves_like 'integer caster', {1 => 2}   => nil
  it_behaves_like 'integer caster', (1..2)     => nil
  it_behaves_like 'integer caster', Object.new => nil
  it_behaves_like 'integer caster', Float::NAN => nil
  it_behaves_like 'integer caster', 1.0/0.0    => nil
  it_behaves_like 'integer caster', 30.minutes => 1800

  %w(float decimal).each do |type|
    it_behaves_like "#{type} caster", nil        => nil
    it_behaves_like "#{type} caster", 1.23       => 1.23
    it_behaves_like "#{type} caster", '1'        => 1.0
    it_behaves_like "#{type} caster", '1ignore'  => 1.0
    it_behaves_like "#{type} caster", 'bad1'     => 0.0
    it_behaves_like "#{type} caster", 'bad'      => 0.0
    it_behaves_like "#{type} caster", 30.minutes => 1800.0
  end

  it_behaves_like 'float caster', 1.0/0.0 => Float::INFINITY
  it_behaves_like 'decimal caster', BigDecimal.new('1.0') / BigDecimal.new('0.0') => BigDecimal('Infinity')

  it_behaves_like 'boolean caster', nil     => nil
  it_behaves_like 'boolean caster', ''      => nil
  it_behaves_like 'boolean caster', true    => true
  it_behaves_like 'boolean caster', 1       => true
  it_behaves_like 'boolean caster', '1'     => true
  it_behaves_like 'boolean caster', 't'     => true
  it_behaves_like 'boolean caster', 'T'     => true
  it_behaves_like 'boolean caster', 'true'  => true
  it_behaves_like 'boolean caster', 'TRUE'  => true
  it_behaves_like 'boolean caster', 'on'    => true
  it_behaves_like 'boolean caster', 'ON'    => true
  it_behaves_like 'boolean caster', false   => false
  it_behaves_like 'boolean caster', 0       => false
  it_behaves_like 'boolean caster', '0'     => false
  it_behaves_like 'boolean caster', 'f'     => false
  it_behaves_like 'boolean caster', 'F'     => false
  it_behaves_like 'boolean caster', 'false' => false
  it_behaves_like 'boolean caster', 'FALSE' => false
  it_behaves_like 'boolean caster', 'off'   => false
  it_behaves_like 'boolean caster', 'OFF'   => false
  it_behaves_like 'boolean caster', ' '     => false
end
