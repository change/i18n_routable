require 'rails/all'
require 'active_support/all'
require 'journey'

require 'i18n_routable/version'
require 'i18n_routable/config'
require 'i18n_routable/route_translation_visitor'
require 'i18n_routable/translation_assistant'


require 'i18n_routable/routes_rb_file/localizable_scope'
ActionDispatch::Routing::Mapper.send :include, I18nRoutable::RoutesRbFile::LocalizableScope


require 'i18n_routable/generating/original_route_to_i18n_route'
ActionDispatch::Routing::RouteSet.send :include, I18nRoutable::Generating::OriginalRouteToI18nRoute

require 'i18n_routable/generating/localizable_url_helper'
ActionDispatch::Routing::RouteSet::NamedRouteCollection.send :include, I18nRoutable::Generating::LocalizableUrlHelper


require 'i18n_routable/util/reverse_route_lookup'
ActionDispatch::Routing::RouteSet.send :include, I18nRoutable::Util::ReverseRouteLookup


require 'i18n_routable/outgoing/localizable_route'
Journey::Route.send :include, I18nRoutable::Outgoing::LocalizableRoute

require 'i18n_routable/outgoing/localizable_formatter'
Journey::Formatter.send :include, I18nRoutable::Outgoing::LocalizableFormatter
