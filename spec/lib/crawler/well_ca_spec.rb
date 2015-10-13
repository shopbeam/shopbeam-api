require 'rails_helper'

describe Crawler::Providers::WellCa do
  describe ".scrape" do
    before(:context) { @url = "https://well.ca/products/rogaine-for-women-hair-regrowth_101642.html" }
    subject { described_class.new(url).scrape }
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
      before(:context) { @smf = described_class.new(@url).scrape.first }

      attributes_to_test = Crawler::SMF_FIELDS.reject { |f| f == :description }
      attributes_to_test.each do |attr|
        it "should parse #{attr}" do
          expect(@smf.send(attr)).to eq send(attr)
        end
      end
    end
  end
end
