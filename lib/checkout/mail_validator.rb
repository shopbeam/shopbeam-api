module Checkout
  module MailValidator
    def parse!(body)
      tpl = template
      pattern = regexp(tpl)
      content = squish(body)

      raise InvalidMailError.new(tpl, content) unless pattern =~ content

      captures(pattern, Regexp.last_match)
    end

    private

    def template
      tpl = File.read("app/views/#{to_s.underscore}.html")
      squish(tpl)
    end

    def regexp(tpl)
      str = Regexp.escape(tpl)
      str.gsub!(/<match>(.*?)<\/match>/) { Regexp.last_match(1).gsub(/\\([.|()\[\]{}+\\^$*?])/, '\1') }
      Regexp.new(str, Regexp::IGNORECASE | Regexp::MULTILINE)
    end

    def captures(pattern, match)
      pattern
        .named_captures.except('scrub')
        .each_with_object({}) do |(name, index), captures|
          captures[name] = match[index.first]
        end
    end

    def squish(str)
      str.strip.tap do |s|
        s.gsub!(/[[:blank:]]+/, ' ')
        s.gsub!(/\s{2,}/, "\n")
      end
    end
  end
end
