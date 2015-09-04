namespace :cucumber do
  task :partners => :environment do
    result = `RAILS_ENV=test bundle exec cucumber`
    success = !result.match(/Failing Scenarios:/)
    CucumberMailer.completed(result, success).deliver_now
  end
end
