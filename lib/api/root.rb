module API
  class Root < Grape::API
    include API::Errors
    include API::Auth::Manager

    format :json

    helpers API::Helpers

    mount API::V1::Root
  end
end
