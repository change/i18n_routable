module I18nRoutable
  module Mapper
    module LocalizableScope

      # Two ways of using:
      #
      # Use localize!/delocalize! to turn localization of routes on/off
      #
      #   resources :blogs # initially non-localized
      #   localize!
      #   resources :posts
      #   match 'events/:id'
      #   delocalize!
      #   resources :users
      #
      # Use localize to execute a block with localization turned on,
      # restoring the previous setting.
      #
      #   localize do
      #     resources :events
      #   end

      def localize! options={}
        I18nRoutable.localize_config = options.symbolize_keys.reverse_merge(default_localize_options)
        validate_options!
        setup_convert_to_display_locale!
        setup_convert_to_backend_locale!
      end

      private

      def default_localize_options
        {
          :locale_prefix => true,
          :locales => I18n.available_locales - [I18n.default_locale]
        }
      end

      def setup_convert_to_display_locale!
        I18nRoutable.localize_config[:backend_to_display_locales] = I18nRoutable.localize_config[:locales].inject({}) do |hsh, locale|
          if locale.is_a?(Hash)
            hsh.merge!(locale.invert)
            hsh.merge(locale.keys.first => locale.keys.first)
          else
            hsh.update(locale => locale)
          end
        end
        I18nRoutable.localize_config[:backend_to_display_locales].merge! I18n.default_locale => I18n.default_locale
      end

      def setup_convert_to_backend_locale!
        I18nRoutable.localize_config[:display_to_backend_locales] = I18nRoutable.localize_config[:locales].inject({}) do |hsh, locale|
          if locale.is_a?(Hash)
            hsh.merge!(locale)
            hsh.merge(locale.values.first => locale.values.first)
          else
            hsh.update(locale => locale)
          end
        end
        I18nRoutable.localize_config[:display_to_backend_locales].merge! I18n.default_locale => I18n.default_locale
      end

      def validate_options!
        raise ArgumentError, ":locales must be an array, given: #{I18nRoutable.localize_config[:locales].inspect}" unless I18nRoutable.localize_config[:locales].is_a?(Array)
        ensure_all_symbols!
        extra_keys = I18nRoutable.localize_config.except(*default_localize_options.keys).keys
        raise ArgumentError, "Unsupported options: #{extra_keys.inspect}" if extra_keys.present?
      end

      def ensure_all_symbols!
        I18nRoutable.localize_config[:locales].each do |locale|
          if locale.is_a?(Hash)
            raise ArgumentError, "#{locale.inspect} can only have 1 key and 1 value" unless locale.keys.length == 1
            raise ArgumentError, "#{locale.keys.first.inspect} must be a Symbol" unless locale.keys.first.is_a?(Symbol)
            raise ArgumentError, "#{locale.values.first.inspect} must be a Symbol" unless locale.values.first.is_a?(Symbol)
          else
            raise ArgumentError, "#{locale.inspect} must be a Symbol" unless locale.is_a?(Symbol)
          end
        end
      end

    end
  end
end
