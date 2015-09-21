module Checkout
  class ProxyMail < KeywordStruct.new(:from, :recipient, :subject, :body_html, :body_plain); end
end
