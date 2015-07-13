require 'action_controller/railtie'
require 'active_support/all'

require 'i18n_routable/version'
require 'i18n_routable/config'
require 'i18n_routable/route_translation_visitor'
require 'i18n_routable/translation_assistant'


require 'i18n_routable/routes_rb_file/localizable_scope'
ActionDispatch::Routing::Mapper.send :include, I18nRoutable::RoutesRbFile::LocalizableScope


require 'i18n_routable/generating/original_route_to_i18n_route'
ActionDispatch::Routing::RouteSet.send :include, I18nRoutable::Generating::OriginalRouteToI18nRoute


require 'i18n_routable/util/reverse_route_lookup'
ActionDispatch::Routing::RouteSet.send :include, I18nRoutable::Util::ReverseRouteLookup


require 'i18n_routable/outgoing/localizable_route'
ActionDispatch::Journey::Route.send :include, I18nRoutable::Outgoing::LocalizableRoute

require 'i18n_routable/outgoing/localizable_formatter'
ActionDispatch::Journey::Formatter.send :include, I18nRoutable::Outgoing::LocalizableFormatter
