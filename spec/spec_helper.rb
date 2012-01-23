require "rubygems"
require "bundler/setup"
require 'rspec'
require 'i18n_routable'
require 'ruby-debug'

# Add I18n load_path
# I18n.load_path = (I18n.load_path << Dir[File.join(File.dirname(__FILE__), 'locales', '*.yml')]).uniq
require 'spec_routes'
require 'mocks'
