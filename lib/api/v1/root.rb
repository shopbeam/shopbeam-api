module API
  module V1
    class Root < Grape::API
      version 'v1', using: :header, vendor: 'shopbeam'

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
