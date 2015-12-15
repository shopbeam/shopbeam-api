desc "generate widgets with overriden description"
task description_override: :environment do
  input_file = ENV['file'] || "spec/fixtures/data_override_sample.csv"
  script = Widgets::DescriptionOverride.new(input_file)
  script.process
end
