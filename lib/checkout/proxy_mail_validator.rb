module Checkout
  module ProxyMailValidator
    def validate_and_sanitize!(body, format)
      tpl = Regexp.escape(template(format).squish)
      tpl.gsub!(/<match>(.*?)<\/match>/) { $1.gsub(/\\([.|()\[\]{}+\\^$*?])/, '\1') }
      pattern = Regexp.new(tpl, 'i')

      body.squish!

      pattern.match(body) do |match|
        if match.names.include?('scrub')
          pattern.named_captures['scrub'].each do |capture|
            body.sub!(match[capture], '')
          end
        end

        return true
      end

      false
    end

    private

    def template(format)
      File.read("app/views/#{to_s.underscore}.#{format}")
    end
  end
end
