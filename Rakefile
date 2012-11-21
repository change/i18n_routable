require "bundler/gem_tasks"

require 'i18n_routable'

# Stolen from rake routes
# https://github.com/rails/rails/blob/4f15f392601d4504fab850f3bf659c43f0cb51ec/railties/lib/rails/tasks/routes.rake
task :routes do

  require Pathname.new(File.dirname(__FILE__))+ 'spec/spec_routes'

  all_routes = SpecRoutes.router.routes

  require 'debugger'
  # debugger;1

  fake_rails = Class.new do
    def config
      self
    end
    def assets
      self
    end
    def prefix
      0
    end
  end

  Rails.application = fake_rails.new

  require 'rails/application/route_inspector'
  inspector = Rails::Application::RouteInspector.new
  puts inspector.format(all_routes, ENV['CONTROLLER']).join "\n"

end

task :default => :test

task :test do
  exec 'rspec --order random'
end
