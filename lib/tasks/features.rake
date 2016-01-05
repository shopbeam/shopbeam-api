require_relative '../../spec/features_runner'

namespace :features do
  namespace :partners do
    RSpec::Core::RakeTask.new(:all) do |t, output|
      t.pattern = 'spec/features/partners'
      t.rspec_opts = "--format documentation --out #{output} --fail-fast"
    end

    RSpec::Core::RakeTask.new(:hilton_com) do |t|
      t.pattern = 'spec/features/partners/hilton_com.feature'
    end

    RSpec::Core::RakeTask.new(:lacoste) do |t|
      t.pattern = 'spec/features/partners/lacoste_com_us.feature'
    end

    RSpec::Core::RakeTask.new(:target_com) do |t|
      t.pattern = 'spec/features/partners/target_com.feature'
    end

    RSpec::Core::RakeTask.new(:well_ca) do |t|
      t.pattern = 'spec/features/partners/well_ca.feature'
    end
  end

  namespace :widgets do
    RSpec::Core::RakeTask.new(:all) do |t, output|
      t.pattern = 'spec/features/widgets'
      t.rspec_opts = "--format documentation --out #{output} --fail-fast"
    end

    RSpec::Core::RakeTask.new(:rogaine) do |t|
      t.pattern = 'spec/features/widgets/rogaine.feature'
    end
  end

  task :partners do
    Rake::Task['features:run'].invoke(:partners)
  end

  task :widgets do
    Rake::Task['features:run'].invoke(:widgets)
  end

  task :run, [:name] => :features_env do |t, args|
    name = args[:name]
    results_file = Rails.root.join('tmp', "features_#{name}.txt")
    runner = FeaturesRunner.new(results_file)

    runner.run do
      Rake::Task["features:#{name}:all"].execute(results_file)
    end

    File.unlink(results_file)

    status_type =
      case runner.results
      when /0 failures/i then :ok
      when /warning/i then :warning
      else :failed
      end

    FeaturesMailer.completed(
      task: name,
      results: runner.results,
      retries: runner.retries,
      status_type: status_type
    ).deliver_now
  end

  task :features_env => :environment do
    abort('The Rails environment is not running in test mode!') unless Rails.env.test?

    ActionMailer::Base.delivery_method = :mailgun
    ActionMailer::Base.mailgun_settings = {
      api_key: Rails.application.secrets.mailgun_api_key,
      domain: 'orders.shopbeam.com'
    }

    WebMock.allow_net_connect!
  end
end
