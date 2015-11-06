require 'cucumber/rake/task'
require_relative 'retryable_runner'

namespace :cucumber do
  PARTNERS_OPTS = {
    well_ca: [
      'features/partners/well_ca.feature',
      '-r features/support',
      '-r features/steps/base',
      '-r features/steps/well_ca'
    ],
    lacoste: [
      'features/partners/lacoste_com_us.feature',
      '-r features/support',
      '-r features/steps/base',
      '-r features/steps/lacoste_com_us'
    ]
  }

  task :partners => [:environment, :set_cucumber_env] do
    results = ''
    retries = 0

    %i(well_ca lacoste).each do |partner|
      results_file = Rails.root.join('tmp', "cucumber_partners_#{partner}_#{Time.now.to_i}.txt")
      runner = Cucumber::Rake::RetryableRunner.new(results_file)

      # Set runner options via environment variable
      # See: https://github.com/cucumber/cucumber-ruby/blob/master/lib/cucumber/rake/task.rb#L148
      ENV['CUCUMBER_OPTS'] = "#{PARTNERS_OPTS[partner].join(' ')} -o #{results_file} --no-source --no-color"

      runner.run do
        Rake::Task["cucumber:partners:#{partner}"].execute
      end

      FileUtils.remove_file(results_file)

      results << runner.results + "\n"
      retries += runner.retries
    end

    status_type =
      case results
      when /failing scenarios/i then :failed
      when /warning/i           then :warning
      else :ok
      end

    CucumberMailer.completed(
      task: :partners,
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

    WebMock.allow_net_connect!
  end

  namespace :partners do
    Cucumber::Rake::Task.new(:well_ca) do |t|
      t.cucumber_opts = PARTNERS_OPTS[:well_ca]
    end

    Cucumber::Rake::Task.new(:lacoste) do |t|
      t.cucumber_opts = PARTNERS_OPTS[:lacoste]
    end
  end
end
