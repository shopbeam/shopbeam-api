require 'cucumber/rake/task'

namespace :cucumber do
  task :partners => :environment do
    results = [:well_ca, :lacoste].map do |partner|
      `RAILS_ENV=test bundle exec rake cucumber:partners:#{partner}`
    end
    result = results.join("\n")
    success = !result.match(/Failing Scenarios:/)
    CucumberMailer.partners_completed(result, success).deliver_now
  end

  namespace :partners do
    Cucumber::Rake::Task.new(:well_ca) do |t|
      t.cucumber_opts = "features/partners/well_ca.feature -r features/support -r features/steps/well_ca/"
    end

    Cucumber::Rake::Task.new(:lacoste) do |t|
      t.cucumber_opts = "features/partners/lacoste_com_us.feature -r features/support -r features/steps/lacoste_com_us/"
    end
  end
end
