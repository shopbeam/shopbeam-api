require 'rails_helper'

Dir[Rails.root.join('spec/steps/**/*steps.rb')].each { |f| require f }

RSpec.configure do |config|
  config.include FeatureHelper, type: :feature

  config.around(type: :feature) do |example|
    WebMock.allow_net_connect!
    example.run
    @browser.close if @browser
  end

  config.before(lacoste: true) do
    session = build_session(address1: '1 Infinite Loop', city: 'Cupertino', state: 'CA')

    @bot = Checkout::LacosteComUs::Bot.new(session)
    @browser = @bot.send(:browser)
  end

  config.before(well_ca: true) do
    session = build_session(city: 'Toronto', state: 'ON', zip: 'A1A 1A1')

    @bot = Checkout::WellCa::Bot.new(session)
    @browser = @bot.send(:browser)
  end
end
