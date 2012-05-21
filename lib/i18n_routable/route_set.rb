require 'i18n_routable/route_set/reverse_route_lookup'

ActionDispatch::Routing::RouteSet.send :include, I18nRoutable::RouteSet::ReverseRouteLookup
