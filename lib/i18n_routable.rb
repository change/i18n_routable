require "i18n_routable/version"

require 'rails/all'
require 'active_support/all'

module I18nRoutable
  class << self
    cattr_accessor :localize_config
    cattr_accessor :defining_base
    def localized?
      !!self.localize_config
    end
    def locales
      I18nRoutable.localize_config[:locales].map(&:to_s)
    end
  end
end

require 'i18n_routable/localizable_scope'
require 'i18n_routable/localizable_route'
require 'i18n_routable/localizable_matcher'
require 'i18n_routable/localizable_url_helper'
require 'i18n_routable/reverse_route_lookup'


ActionDispatch::Routing::Mapper.send :include, I18nRoutable::LocalizableScope
ActionDispatch::Routing::Mapper.send :include, I18nRoutable::LocalizableRoute
ActionDispatch::Routing::Mapper::Base.send :include, I18nRoutable::LocalizableMatcher
ActionDispatch::Routing::RouteSet::NamedRouteCollection.send :include, I18nRoutable::LocalizableUrlHelper
ActionDispatch::Routing::RouteSet.send :include, I18nRoutable::ReverseRouteLookup
