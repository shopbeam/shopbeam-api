require 'rails_helper'

describe Crawler::Providers::TargetCom do
  describe "#scrape_brand" do
    let(:url1) { "http://tws.target.com/searchservice/item/brand_results/v2/by_brand?pageCount=100&offset=0&response_group=Items%2CVariationSummary&guest_mfg_brand=l%27oreal+paris" }
    let(:url2) { "http://tws.target.com/searchservice/item/brand_results/v2/by_brand?pageCount=100&offset=100&response_group=Items%2CVariationSummary&guest_mfg_brand=l%27oreal+paris" }

    before do
      stub_request(:get, url1).to_return(body: File.new('spec/fixtures/loreal_paris1.html'))
      stub_request(:get, url2).to_return(body: File.new('spec/fixtures/loreal_paris2.html'))
    end

    subject do
      described_class.scrape_brand('l%27oreal+paris')
    end

    let(:partner) { 'Target.com' }
    let(:brand) { "L'oreal Paris" }
    let(:'original-brand') { "L'Oreal Paris" }
    let(:name) { "L'Oréal® Paris Colour Riche Collection Exclusive Red Lipcolor" }
    let(:color) { "Julianne's Red" }
    let(:'color-family') { 'red' }
    let(:size) { '' }
    let(:category) { '' }
    let(:'original-category') { 'New' }
    let(:'list-price') { '5.99' }
    let(:'sale-price') { nil }
    let(:'image-url1') { 'http://scene7.targetimg1.com/is/image/Target/17256627' }
    let(:sku) { 'e3dce3be5fd40fdd' }
    let(:'parent-sku') { 'b2afb22622b3049d' }
    let(:'partner-data') { nil }
    let(:'source-url') { 'http://www.target.com/p/l-oreal-paris-13-oz-red-lipstick/-/A-17256628' }
    let(:'color-substitute') { nil }
    let(:description) do
      "This red is more than your average lip shade—it’s bold, iconic, curated richness that glides on for a soft matte finish.<br><br>A Red for Every Woman<br>Pure Matte Color<br>Velvet Soft Feel<br><br>Directions:<br>Apply starting in the center of your upper lip. Work from the center to outer edges of your lips, following the contour of your mouth. Then glide across the entire bottom lip."
    end

    (2..7).each do |i|
      let(:"image-url#{i}") { nil }
    end

    it "should return array with single SMF object" do
      expect(subject.first.class).to eq Crawler::SMF
      expect(subject.count).to eq 15
    end

    context "attributes" do
      subject do
        described_class.scrape_brand('l%27oreal+paris').first.format
      end

      Crawler::SMF_FIELDS.each do |attr|
        it "should parse #{attr}" do
          expect(subject.send(attr)).to eq send(attr)
        end
      end
    end
  end
end
