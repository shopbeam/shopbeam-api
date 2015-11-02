module API
  class Root < Grape::API
    include API::Errors
    include API::Auth::Manager

    format :json

    helpers API::Helpers

    mount API::V1::Root

    # Must be the last route!
    route :any, '*path' do
      # Proxy all other requests to Spock API
      redirect "https://www.shopbeam.com#{request.fullpath}"
    end
  end
end
