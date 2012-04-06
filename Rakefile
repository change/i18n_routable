require "bundler/gem_tasks"

require 'i18n_routable'

# Stolen from rake routes
# https://github.com/rails/rails/blob/4f15f392601d4504fab850f3bf659c43f0cb51ec/railties/lib/rails/tasks/routes.rake
task :routes do

  require 'spec/spec_routes'

  all_routes = SpecRoutes.router.routes


  if ENV['CONTROLLER']
    all_routes = all_routes.select{ |route| route.defaults[:controller] == ENV['CONTROLLER'] }
  end

  routes = all_routes.collect do |route|

    reqs = route.requirements.dup
    reqs[:to] = route.app unless route.app.class.name.to_s =~ /^ActionDispatch::Routing/
    reqs = reqs.empty? ? "" : reqs.inspect

    {:name => route.name.to_s, :verb => route.verb.to_s, :path => route.path, :reqs => reqs}
  end

  routes.reject! { |r| r[:path] =~ %r{/rails/info/properties} } # Skip the route if it's internal info route

  name_width = routes.map{ |r| r[:name].length }.max
  verb_width = routes.map{ |r| r[:verb].length }.max
  path_width = routes.map{ |r| r[:path].length }.max
  reqs_with  = routes.map{ |r| r[:reqs].length }.max

  puts "#{"NAME".center(name_width)} #{"VERB".center(verb_width)} #{"PATH".center(path_width)} #{"REQUIREMENTS".center(reqs_with)}"


  routes.each do |r|
    puts "#{r[:name].rjust(name_width)} #{r[:verb].ljust(verb_width)} #{r[:path].ljust(path_width)} #{r[:reqs]}"
  end
end

task :default => :test

task :test do
  exec 'rspec'
end
