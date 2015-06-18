module I18nRoutable
  module Config

    mattr_accessor :localize_config, :defining_base, :route_translation_cache, :localizing
    self.localize_config = {}

    def setup! options
      setup_localize_config! options
      validate_options!
      I18n.available_locales = self.localize_config[:locales]
      setup_convert_to_display_locale!
      setup_convert_to_backend_locale!
    end

    def localizing?
      localizing
    end

    def localizing!
      self.localizing = true
      self.build_route_translation_cache!
    end

    def not_localizing!
      self.localizing = false
      self.route_translation_cache = nil
    end

    def locales
      self.localize_config[:locales]
    end

    def backend_locales
      self.localize_config[:backend_locales] ||= self.localize_config[:locales].map do |locale|
        if locale.is_a? Hash
          locale.values.first.to_sym
        else
          locale.to_sym
        end
      end
    end

    def display_locales
      self.localize_config[:display_locales] ||= self.localize_config[:locales].map do |locale|
        if locale.is_a? Hash
          locale.keys.first.to_sym
        else
          locale.to_sym
        end
      end
    end

    def convert_to_display_locale locale
      return nil unless locale.present?
      self.localize_config[:backend_to_display_locales][locale.to_sym]
    end

    def convert_to_backend_locale locale
      return nil unless locale.present?
      self.localize_config[:display_to_backend_locales][locale.to_sym]
    end

    protected

    def build_route_translation_cache!
      route_translation_cache = self.backend_locales.each_with_object({}) do |locale, hsh|
        route_translations_for_locale(locale).each_pair do |route, translation|
          route = route.to_s
          hsh[route] ||= Set[escape route]
          hsh[route] << escape(translation)
        end
      end

      route_translation_cache.keys.each do |route|
        route_translation_cache[route] = /#{ route_translation_cache[route].to_a * '|' }/i
      end

      self.route_translation_cache = route_translation_cache
    end

    def escape route_translation
      Regexp.escape ActionDispatch::Journey::Router::Utils.escape_fragment route_translation
    end

    def default_localize_options
      {locale_prefix: true, locales: nil, translations: {}}
    end

    def default_locales
      I18n.available_locales - [I18n.default_locale]
    end

    def setup_localize_config! options
      self.localize_config = options.symbolize_keys.reverse_merge(default_localize_options)
      self.localize_config[:locales] ||= default_locales
      self.localize_config[:translations].symbolize_keys!
    end

    def validate_options!
      raise ArgumentError, ":locales must be an array, given: #{self.localize_config[:locales].inspect}" unless self.localize_config[:locales].is_a?(Array)
      ensure_all_symbols!
      extra_keys = self.localize_config.except(*default_localize_options.keys).keys
      raise ArgumentError, "Unsupported options: #{extra_keys.inspect}" if extra_keys.present?
    end

    def ensure_all_symbols!
      self.localize_config[:locales].each do |locale|
        if locale.is_a?(Hash)
          raise ArgumentError, "#{locale.inspect} can only have 1 key and 1 value" unless locale.keys.length == 1
          raise ArgumentError, "#{locale.keys.first.inspect} must be a Symbol" unless locale.keys.first.is_a?(Symbol)
          raise ArgumentError, "#{locale.values.first.inspect} must be a Symbol" unless locale.values.first.is_a?(Symbol)
        else
          raise ArgumentError, "#{locale.inspect} must be a Symbol" unless locale.is_a?(Symbol)
        end
      end
    end

    def setup_convert_to_display_locale!
      self.localize_config[:backend_to_display_locales] = self.localize_config[:locales].inject({}) do |hsh, locale|
        if locale.is_a?(Hash)
          hsh.merge!(locale.invert)
          hsh.merge(locale.keys.first => locale.keys.first)
        else
          hsh.update(locale => locale)
        end
      end
      self.localize_config[:backend_to_display_locales].merge! I18n.default_locale => I18n.default_locale
    end

    def setup_convert_to_backend_locale!
      self.localize_config[:display_to_backend_locales] = self.localize_config[:locales].inject({}) do |hsh, locale|
        if locale.is_a?(Hash)
          hsh.merge!(locale)
          hsh.merge(locale.values.first => locale.values.first)
        else
          hsh.update(locale => locale)
        end
      end
      self.localize_config[:display_to_backend_locales].merge! I18n.default_locale => I18n.default_locale
    end

    def route_translations_for_locale locale
      translations = localize_config[:translations]
      return I18n.translate('routes', :locale => locale, :default => {}) unless translations.present?
      translations_for_locale = translations[locale]
      return {} if translations_for_locale.blank?
      translations_for_locale.symbolize_keys.fetch(:routes)
    end

  end
end

I18nRoutable.send :extend, I18nRoutable::Config
