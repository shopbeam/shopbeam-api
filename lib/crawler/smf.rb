require 'crawler'
module Crawler
  class SMF < KeywordStruct.new(*SMF_FIELDS)
    def to_a
      SMF_FIELDS.map {|field| self[field].nil? ? '' : self[field] }
    end
  end
end
