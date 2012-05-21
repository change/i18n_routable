require 'i18n_routable/mapper/localizable_scope'
require 'i18n_routable/mapper/localizable_matcher'

module I18nRoutable
  module Mapper

    include I18nRoutable::Mapper::LocalizableScope

  end
end

ActionDispatch::Routing::Mapper.send :include, I18nRoutable::Mapper
ActionDispatch::Routing::Mapper::Base.send :include, I18nRoutable::Mapper::LocalizableMatcher
