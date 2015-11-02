namespace :api do
  desc 'API Routes'
  task :routes => :environment do
    API::Root.routes.each do |route|
      method = route.route_method
      path = route.route_path.gsub(':version', route.route_version)
      puts "#{method} #{path}".rjust(35)
    end
  end
end
