module I18nRoutable
  module Config

    mattr_accessor :localize_config, :defining_base, :routes_for_locale_cache
    self.routes_for_locale_cache = {}

    def localized?
      !!self.localize_config
    end

    def locales
      I18nRoutable.localize_config[:locales]
    end

    def backend_locales
      @@backend_locales ||= I18nRoutable.localize_config[:locales].map do |locale|
        if locale.is_a? Hash
          locale.values.first.to_sym
        else
          locale.to_sym
        end
      end
    end

    def display_locales
      @@display_locales ||= I18nRoutable.localize_config[:locales].map do |locale|
        if locale.is_a? Hash
          locale.keys.first.to_sym
        else
          locale.to_sym
        end
      end
    end

    def convert_to_display_locale locale
      I18nRoutable.localize_config[:backend_to_display_locales][locale.to_sym]
    end

    def routes_for_locale locale
      self.routes_for_locale_cache[locale] ||= begin
        routes = I18n.translate('routes', :locale => locale)
        hash_that_defaults_to_key = Hash.new {|h,k| h[k] = k }
        if routes.is_a?(Hash)
          # This would be easier but we need to GCI escape all the values for outgoing routes.
          routes.stringify_keys.inject(hash_that_defaults_to_key) {|hsh, (k, v)| hsh.update(k => CGI.escape(v)) }
        else
          hash_that_defaults_to_key
        end

      end
    end


  end
end

I18nRoutable.send :extend, I18nRoutable::Config
