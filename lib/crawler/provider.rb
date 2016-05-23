module Crawler
  class Provider
    class ProviderNotSupportedError < StandardError; end

    class << self
      def lookup(url: nil, name: nil)
        if url
          lookup_by_url(url)
        elsif name
          lookup_by_name(name)
        else
          raise ArgumentError.new("specify url or name")
        end
      end

      def lookup_by_url(url)
        case url
        # TODO: Extract URL patterns into constants
        when %r((https?://www.lacoste.com/us)|(http://click.linksynergy.com(.*?)www.lacoste.com))
          Crawler::Providers::LacosteComUs
        when %r(https?://well.ca)
          Crawler::Providers::WellCa
        else
          raise ProviderNotSupportedError.new("Crawler for site '#{url}' is not supported.")
        end
      end

      def lookup_by_name(name)
        case name
        when "well_ca"
          Crawler::Providers::WellCa
        when "target_com"
          Crawler::Providers::TargetCom
        else
          raise ProviderNotSupportedError.new("Crawler for provider '#{name}' is not supported.")
        end
      end

      def can_scrape_whole_brand?
        false
      end

      def get(url)
        Nokogiri::HTML(URI.parse(url).open)
      end
    end

    def initialize(url)
      @url = url
      @page = self.class.get(url)
    end

    private
    def strip_tabs(text)
      text.gsub(/\t?\n?\r?/, '')
    end

    def uid(*args)
      ascii = args.join.encode(Encoding.find('ASCII'), undef: :replace, invalid: :replace, replace: '')
      Digest::MD5.hexdigest(ascii)[0...16]
    end

    def capitalize(text)
      return unless text
      text.split(" ").map(&:capitalize).join(" ")
    end
  end
end
