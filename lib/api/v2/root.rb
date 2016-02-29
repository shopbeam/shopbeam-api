module API
  module V2
    class Root < Grape::API
      version 'v2', using: :path, vendor: 'shopbeam'

      # Temporary disable, so we can use spock for now
      # enable for tests only
      # if Rails.env.test?
        mount API::V2::Products
        mount API::V2::PartnerDetails
        # mount API::V2::Orders
      # end

      helpers do
        params :consumer do
          requires :email, type: String, desc: 'Consumer email'
          requires :password, type: String, desc: 'Consumer password'
        end
      end

      desc 'Sign up a new consumer'
      params do
        use :consumer
      end
      post 'sign_up' do
        authenticate_client!

        consumer = current_client.consumers.create!(
          email: params[:email],
          password: params[:password]
        )

        set_consumer consumer
        present consumer
      end

      desc 'Sign in a consumer'
      params do
        use :consumer
      end
      post 'sign_in' do
        authenticate_consumer!
        status 200
        present current_consumer
      end
    end
  end
end
