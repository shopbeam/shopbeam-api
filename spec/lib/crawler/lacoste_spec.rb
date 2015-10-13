require 'rails_helper'

describe Crawler::Providers::LacosteComUs do
  describe ".scrape" do
    before(:context) { @url = "http://www.lacoste.com/us/lacoste/men/accessories/watches/lacoste.12.12-watch/2010823.html?dwvar_2010823_color=000" }
    subject { described_class.new(url).scrape }

    let(:url) { @url }
    let(:name) { "12.12 Watch" }
    let(:'original-brand') { "LACOSTE" }
    let(:partner) { "Lacoste" }
    let(:brand) { "Lacoste" }
    let(:description) { "<h3>Lacoste.12.12 Watch</h3> <span itemprop=\"productID\">2010823</span><p>An iconic watch family, the Lacoste.12.12 captures and transforms the essence of the polo shirt into a watch collection.</p><ul><li>White Silicone Strap With White Dial</li><li>Buckle Closure</li><li>Tr90 Composite Material Case</li><li>Quartz Chronograph Movement</li><li>2 Year Limited Warranty &amp; 24-36 Months Approximate Battery Life</li></ul>" }
    let(:'original-category') { 'Men: Accessories: Watches' }
    let(:size) { '' }
    let(:color) { 'White' }
    let(:'color-family') { 'white' }
    let(:'color-substitute') { nil }
    let(:sku) { '2c2510a369aedb29' }
    let(:'parent-sku') { '1e6e3abf0b9fe36a' }
    let(:category) { '' }
    let(:'image-url1') { 'http://imagena1.lacoste.com/sits_pod26/dw/image/v2/AAUP_PRD/on/demandware.static/-/Sites-master/default/dw6bd01afd/10_2010823_000_24.jpg?sw=656&amp;sh=656&amp;sm=fit' }
    (2..7).each do |i|
      let(:"image-url#{i}") { nil }
    end
    let(:'source-url') { url }
    let(:'list-price') { 175.00 }
    let(:'sale-price') { nil }
    let(:'partner-data') { nil }

    it "should return array of SMF objects" do
      expect(subject.first.class).to eq Crawler::SMF
    end


    context "attributes" do
      before(:context) { @smf = described_class.new(@url).scrape.first }
      Crawler::SMF_FIELDS.each do |attr|
        it "should parse #{attr} attribute" do
          expect(@smf.send(attr)).to eq send(attr)
        end
      end
    end

    context "no colors variations" do
      it "yields the only color" do
        crawler = described_class.new(url)

        expect { |b| crawler.send(:variations, &b) }.to yield_control.exactly(1).times

        crawler.send(:variations) do |color, images, prices|
          expect(color).to eq 'White'
          expect(images).to include(send(:'image-url1'))
          expect(prices[:list]).to eq '175.00'
          expect(prices[:sale]).to be_nil
        end
      end
    end

    context "there are colors variations" do
      let(:url) { 'http://www.lacoste.com/us/lacoste-sport/kids/shoes/high-top-ampthill-sneakers/30SPI3001.html?dwvar_30SPI3001_color=21G' }
      it "yields all color variations" do
        crawler = described_class.new(url)

        expect { |b| crawler.send(:variations, &b) }.to yield_control.exactly(12).times

        results = []
        crawler.send(:variations) do |color, images, prices, size|
          results << {color: color, images: images, prices: prices, size: size}
        end

        expect(results[0][:color]).to eq "G"
        expect(results[6][:color]).to eq "Db"

        expect(results[0][:images]).to include("http://imagena1.lacoste.com/sits_pod26/dw/image/v2/AAUP_PRD/on/demandware.static/-/Sites-master/default/dw81561705/11_30SPI3001_21G_01.jpg?sw=656&amp;sh=656&amp;sm=fit")
        expect(results[6][:images]).to include("http://imagena1.lacoste.com/sits_pod26/dw/image/v2/AAUP_PRD/on/demandware.static/-/Sites-master/default/dwce38d190/11_30SPI3001_DB4_01.jpg?sw=656&amp;sh=656&amp;sm=fit")

        expect(results[0][:prices][:list]).to eq '50.00'
        expect(results[6][:prices][:list]).to eq '50.00'

        expect(results[0][:prices][:sale]).to be_nil
        expect(results[6][:prices][:sale]).to be_nil

        expect(results[0][:size]).to eq "4 (uk 3)"
        expect(results[11][:size]).to eq "9 (uk 8)"
      end
    end
  end
end
