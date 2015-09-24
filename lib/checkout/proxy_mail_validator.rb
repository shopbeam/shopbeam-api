module Checkout
  module ProxyMailValidator
    def parse(body, format)
      tpl = Regexp.escape(template(format).squish)
      tpl.gsub!(/<match>(.*?)<\/match>/) { $1.gsub(/\\([.|()\[\]{}+\\^$*?])/, '\1') }
      pattern = Regexp.new(tpl, 'i')

      body.squish!

      pattern.match(body) do |match|
        return captures(pattern, match)
      end

      false
    end

    private

    def template(format)
      File.read("app/views/#{to_s.underscore}.#{format}")
    end

    def captures(pattern, match)
      pattern
        .named_captures.except('scrub')
        .each_with_object({}) do |(name, index), captures|
          captures[name] = match[index.first]
        end
    end
  end
end
