require 'rails_helper'

describe Crawler::Providers::WellCa do
  describe ".scrape" do
    before(:context) { @url = "https://well.ca/products/rogaine-for-women-hair-regrowth_101642.html" }
    subject do
      stub_request(:get, @url).to_return(body: File.new('spec/fixtures/rogaine_for_women.html'))
      described_class.new(url).scrape
    end
    let(:url) { @url }
    let(:partner) { 'Well.ca' }
    let(:brand) { 'Rogaine' }
    let(:'original-brand') { 'Rogaine' }
    let(:name) { 'for Women Hair Regrowth Treatment Foam' }
    let(:color) { 'Minoxidil %' }
    let(:'color-family') { '' }
    let(:size) { '2 X 60 G' }
    let(:category) { '' }
    let(:'original-category') { 'Personal Care: Hair Care: Hair Regrowth & Hair Loss' }
    let(:'list-price') { '129.99' }
    let(:'sale-price') { nil }
    let(:'image-url1') { 'https://d3t32hsnjxo7q6.cloudfront.net/i/a87a5a3ca17d01c61286bee4dbb40555_ra,w403,h403_pa,w403,h403.jpg' }
    let(:sku) { '5f61f23eef41af91' }
    let(:'parent-sku') { '10016433ceaa0b26' }
    let(:'partner-data') { nil }
    let(:'source-url') { url }
    let(:'color-substitute') { nil }

    (2..7).each do |i|
      let(:"image-url#{i}") { nil }
    end

    it "should return array with single SMF object" do
      expect(subject.first.class).to eq Crawler::SMF
      expect(subject.count).to eq 1
    end

    context "attributes" do
      before(:context) do
        stub_request(:get, @url).to_return(body: File.new('spec/fixtures/rogaine_for_women.html'))
        @smf = described_class.new(@url).scrape.first.format
      end
      
      attributes_to_test = Crawler::SMF_FIELDS.reject { |f| f == :description }
      attributes_to_test.each do |attr|
        it "should parse #{attr}" do
          expect(@smf.send(attr)).to eq send(attr)
        end
      end
    end

    context "out of stock" do
      let(:url) { "https://well.ca/products/rogaine-for-men-hair-regrowth_2005.html" }
      before { stub_request(:get, url).to_return(body: File.new('spec/fixtures/rogaine_for_men.html')) }

      it "should return empty array" do
        expect(subject.count).to eq 0
      end
    end
  end

  describe "#scrape_brand" do
    let(:brand) { "andrea-eye-qs" }
    let(:products) do
      [ "https://well.ca/products/andrea-eye-qs-ultra-quick_11897.html",
        "https://well.ca/products/andrea-eye-qs-eye-make-up_25024.html",
        "https://well.ca/products/andrea-eye-qs-makeup-remover-lotion_11905.html",
        "https://well.ca/products/andrea-eye-qs-makeup-remover-gel_11901.html"]
    end

    before do
      stub_request(:get, "https://well.ca/brand/andrea-eye-qs.html?page=1").to_return(body: File.new('spec/fixtures/andrea_eye_qs.html'))
      stub_request(:get, "https://well.ca/brand/andrea-eye-qs.html?page=2").to_return(body: "")
    end

    subject do
      described_class.scrape_brand(brand)
    end

    it "should return all products URLs" do
      products.each do |product|
        expect(subject).to include(product)
      end
    end

    context "when there are more than one page" do
      let(:brand) { "pure-encapsulations" }
      let(:products) do
        [ "https://well.ca/products/pure-encapsulations-nitric-oxide_109679.html",
          "https://well.ca/products/pure-encapsulations-thyroid-support_109695.html",
        ]
      end

      before do
        stub_request(:get, "https://well.ca/brand/pure-encapsulations.html?page=1").to_return(body: File.new('spec/fixtures/pure-encapsulations_1.html'))
        stub_request(:get, "https://well.ca/brand/pure-encapsulations.html?page=2").to_return(body: File.new('spec/fixtures/pure-encapsulations_2.html'))
        stub_request(:get, "https://well.ca/brand/pure-encapsulations.html?page=3").to_return(body: "")
      end

      it "should return products URLs from first and second page" do
        products.each do |product|
          expect(subject).to include(product)
        end
      end
    end
  end
end
