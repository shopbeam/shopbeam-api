require 'rails_helper'
describe 'import process', truncation: true do
  let(:file) { File.read('spec/fixtures/import.csv') }
  let(:product) { create(:product) }
  let(:status) { 1 }
  let(:listPriceCents) { 899 }
  let(:salePriceCents) { nil }
  let(:color) { 'Pink/blue' }
  let(:size) { '5-9' }
  let(:sku) { 'ef75e30ef6a86be6' }

  before do
    product
    Importer::Runner.from_csv(file)
  end

  it "should import 2 products" do
    expect(Product.where(status: 1).count).to eq 2
    Product.where(status: 1).all.each do |prod|
      expect(prod.status).to eq 1
    end
  end

  it "should import 2 brands" do
    expect(Brand.where(status: 1).count).to eq 2
    Brand.where(status: 1).all.each do |brand|
      expect(brand.status).to eq 1
    end
  end

  it "should invalidate old product" do
    expect(product.reload.status).to eq 0
  end

  it "should import 3 variants for product" do
    variants = Product.where(status: 1).first.variants
    expect(variants.count).to eq 3
  end

  [:status, :listPriceCents, :salePriceCents, :color, :size, :sku].each do |attr|
    it "should correctly import variant #{attr}" do
      variant = Product.where(status: 1).first.variants.first
      expect(variant.send(attr)).to eq(send(attr))
    end
  end
end
