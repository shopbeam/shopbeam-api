module API
  module V2
    class Root < Grape::API
      version 'v2', using: :path, vendor: 'shopbeam'

      mount API::V2::Products
      mount API::V2::PartnerDetails
      mount API::V2::Orders

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
        present consumer, with: API::V2::Entities::Consumer
      end

      desc 'Sign in a consumer'
      params do
        use :consumer
      end
      post 'sign_in' do
        authenticate_consumer!
        status 200
        present current_consumer, with: API::V2::Entities::Consumer
      end
    end
  end
end
