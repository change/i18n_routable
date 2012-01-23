require "i18n_routable/version"

require 'rails/all'
require 'active_support/all'

module I18nRoutable

end

require 'i18n_routable/localizable_scope'
require 'i18n_routable/localizable_matcher'

ActionDispatch::Routing::Mapper.send :include, I18nRoutable::LocalizableScope
ActionDispatch::Routing::Mapper::Base.send :include, I18nRoutable::LocalizableMatcher
