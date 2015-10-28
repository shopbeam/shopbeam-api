module Cucumber
  module Rake
    class RetryableRunner
      MAX_RETRIES = 3
      ERRORS = %w(
        Watir::Wait::TimeoutError
        Net::ReadTimeout
      )

      attr_reader :results, :retries

      def initialize(results_file)
        @results_file = results_file
        @results = ''
        @retries = 0
      end

      def run
        yield
      rescue SystemExit
        if retry?
          @retries += 1
          retry
        end
      ensure
        @results = output
      end

      def retry?
        @retries < MAX_RETRIES && /#{ERRORS.join('|')}/ =~ output
      end

      def output
        File.read(@results_file)
      end
    end
  end
end
