namespace :partner do
  task :all => :environment do
    result = `script -q /dev/null cucumber`
    success = $?.exitstatus == 0
    CucumberMailer.completed(result, success).deliver_now
  end

end
