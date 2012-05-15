module I18nRoutable
  module Mapper
    module LocalizableRoute

      def self.normalize_locale locale
        locale.to_s.downcase.gsub /-/, ''
      end

      private

      def translate_route en_route
        en_path     = en_route[1][:path_info]
        en_defaults = en_route[3]
        en_name     = en_route[4]
        I18nRoutable.locales.each do |locale|
          locale, backend_locale = get_backend_locale_and_locale_from_config(locale)
          localized_route                = deep_clone(en_route)
          localized_route[1][:path_info] = translated_path(en_path, locale, backend_locale)
          localized_route[3]             = translated_defaults(en_defaults, locale)
          localized_route[4]             = translated_name(en_name, backend_locale) if en_name
          @set.add_route(*localized_route)
        end
      end

      def translated_path en_path, locale, backend_locale=locale
        new_path = ''
        new_path.insert 0, "/#{locale}" if I18nRoutable.localize_config[:locale_prefix]
        new_path << en_path.split(/(\(.+\))/).map do |component|
          unless component.starts_with?("(")
            component.split("/").map do |word|
              word.blank? || word.starts_with?(":") ? word :
              CGI.escape(I18n.translate(word, :locale => backend_locale, :scope => 'routes', :default => word))
            end.join("/")
          else
            component
          end
        end.join
        new_path
      end

      def translated_defaults en_defaults, locale
        new_defaults = en_defaults.dup
        new_defaults[:locale] = locale.to_s
        new_defaults
      end

      def translated_name en_name, locale
        "#{I18nRoutable::Mapper::LocalizableRoute.normalize_locale locale}_#{en_name}"
      end

      def get_backend_locale_and_locale_from_config(locale)
        if locale.is_a?(Hash)
          [locale.keys.first, locale.values.first]
        else
          [locale, locale]
        end
      end

    end
  end
end
