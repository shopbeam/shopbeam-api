module API
  module Errors
    extend ActiveSupport::Concern

    class ApiError < StandardError; end
    class UnauthorizedError < ApiError; end

    included do
      rescue_from ActiveRecord::RecordNotFound do
        error!('404 Not Found', 404)
      end

      rescue_from UnauthorizedError do
        error!('401 Unauthorized', 401)
      end

      rescue_from ActiveRecord::RecordInvalid do
        error!('422 Unprocessable Entity', 422)
      end

      rescue_from Grape::Exceptions::Base do |e|
        error!(e.message, e.status)
      end

      rescue_from :all do |e|
        bc = ActiveSupport::BacktraceCleaner.new
        bc.add_filter   { |line| line.gsub(Rails.root.to_s, '') }
        bc.add_silencer { |line| line =~ /gems/ }

        Rails.logger.error "#{e.message}\n\n#{bc.clean(e.backtrace).join("\n")}"

        error!("Something went wrong on Shopbeam's end", 500)
      end
    end
  end
end
