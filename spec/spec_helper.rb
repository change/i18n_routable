require "rubygems"
require "bundler/setup"
require 'ruby-debug'
ENV["RAILS_ENV"] ||= 'test'

require 'i18n_routable'
require 'rspec'
require 'rspec/rails'


I18n.default_locale = :en
require 'mocks'
require 'spec_routes'

RSpec.configure do |config|
  config.infer_base_class_for_anonymous_controllers = true
end
