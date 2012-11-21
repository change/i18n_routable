require 'rails/all'
require 'active_support/all'
require 'rack/mount/strexp'

require 'i18n_routable/version'
require 'i18n_routable/config'
require 'i18n_routable/translation_assistant'


require 'i18n_routable/routes_rb_file/localizable_scope'
ActionDispatch::Routing::Mapper.send :include, I18nRoutable::RoutesRbFile::LocalizableScope


require 'i18n_routable/generating/localizable_matcher'
ActionDispatch::Routing::Mapper::Base.send :include, I18nRoutable::Generating::LocalizableMatcher

require 'i18n_routable/generating/localizable_url_helper'
ActionDispatch::Routing::RouteSet::NamedRouteCollection.send :include, I18nRoutable::Generating::LocalizableUrlHelper


require 'i18n_routable/util/reverse_route_lookup'
ActionDispatch::Routing::RouteSet.send :include, I18nRoutable::Util::ReverseRouteLookup


require 'i18n_routable/outgoing/localizable_route'
Rack::Mount::Route.send :include, I18nRoutable::Outgoing::LocalizableRoute
