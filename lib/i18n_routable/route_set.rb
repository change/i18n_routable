require 'i18n_routable/route_set/reverse_route_lookup'
require 'i18n_routable/route_set/localizable_url_helper'

module I18nRoutable
  module RouteSet

    include I18nRoutable::RouteSet::ReverseRouteLookup

  end
end

ActionDispatch::Routing::RouteSet.send :include, I18nRoutable::RouteSet
ActionDispatch::Routing::RouteSet::NamedRouteCollection.send :include, I18nRoutable::RouteSet::LocalizableUrlHelper
