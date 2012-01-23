require "i18n_routable/version"

require 'rails/all'
require 'active_support/all'

module I18nRoutable

end

require 'i18n_routable/localizable_route'

ActionDispatch::Routing::Mapper.send :include, I18nRoutable::LocalizableRoute
