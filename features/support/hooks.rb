Before('@partners, @widgets') do
  WebMock.allow_net_connect!
end

After('@partners, @widgets') do
  @browser.close if @browser
end
