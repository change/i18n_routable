module I18nRoutable
  module RoutesRbFile
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

      def localize! options={}, &block
        I18nRoutable.setup! options
      end

      def localize &block
        I18nRoutable.localizing!
              # debugger;1

        create_routes!(&block)
        I18nRoutable.not_localizing!
      end

      def create_routes! &block
        regexp = I18nRoutable.display_locales.join "|"
        scope "(:locale)", :locale => /#{regexp}/, &block
      end

    end
  end
end
