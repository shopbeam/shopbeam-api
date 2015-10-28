require 'cucumber/rake/task'
require_relative 'retryable_runner'

namespace :cucumber do
  WIDGETS_OPTS = {
    rogaine: [
      'features/widgets/rogaine.feature',
      '-r features/support',
      '-r features/steps/rogaine'
    ]
  }

  task :widgets => [:environment, :set_cucumber_env] do
    results = ''
    retries = 0

    %i(rogaine).each do |widget|
      results_file = Rails.root.join('tmp', "cucumber_widgets_#{widget}_#{Time.now.to_i}.txt")
      runner = Cucumber::Rake::RetryableRunner.new(results_file)

      # Set runner options via environment variable
      # See: https://github.com/cucumber/cucumber-ruby/blob/master/lib/cucumber/rake/task.rb#L148
      ENV['CUCUMBER_OPTS'] = "#{WIDGETS_OPTS[widget].join(' ')} -o #{results_file} --no-source --no-color"

      runner.run do
        Rake::Task["cucumber:widgets:#{widget}"].execute
      end

      FileUtils.remove_file(results_file)

      results << runner.results + "\n"
      retries += runner.retries
    end

    status_type = results.match(/failing scenarios/i) ? :failed : :ok

    CucumberMailer.completed(
      task: :widgets,
      results: results,
      retries: retries,
      status_type: status_type
    ).deliver_now
  end

  task :set_cucumber_env do
    ActionMailer::Base.delivery_method = :mailgun
    ActionMailer::Base.mailgun_settings = {
      api_key: Rails.application.secrets.mailgun_api_key,
      domain: 'orders.shopbeam.com'
    }
  end

  namespace :widgets do
    Cucumber::Rake::Task.new(:rogaine) do |t|
      t.cucumber_opts = WIDGETS_OPTS[:rogaine]
    end
  end
end
