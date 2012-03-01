module I18nRoutable
  module Config

    mattr_accessor :localize_config, :defining_base

    def localized?
      !!self.localize_config
    end

    def locales
      I18nRoutable.localize_config[:locales].map(&:to_s)
    end

  end
end

I18nRoutable.send :extend, I18nRoutable::Config
