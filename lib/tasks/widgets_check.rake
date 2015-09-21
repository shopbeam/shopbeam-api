require 'cucumber/rake/task'

namespace :cucumber do
  task :widgets => :environment do
    results = [:rogaine].map do |widget|
      `RAILS_ENV=test bundle exec rake cucumber:widgets:#{widget}`
    end
    result = results.join("\n")
    success = !result.match(/Failing Scenarios:/)
    CucumberMailer.widgets_completed(result, success).deliver_now
  end

  namespace :widgets do
    Cucumber::Rake::Task.new(:rogaine) do |t|
      t.cucumber_opts = "features/widgets/rogaine.feature -r features/support -r features/steps/rogaine/"
    end

    task :all => :environment do
      Rake::Task['cucumber:widgets:rogaine'].invoke
    end
  end
end
