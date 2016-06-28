module API
  class Root < Grape::API
    include API::Errors
    include API::Auth::Manager

    format :json

    helpers API::Helpers

    mount API::V2::Root
  end
end
