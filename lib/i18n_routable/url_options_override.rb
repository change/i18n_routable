module I18nRoutable
  module UrlOptionsOverride

    module ActionControllerOverride

      def self.included base
        base.alias_method_chain :url_options, :locale_removed
      end

      def url_options_with_locale_removed
        url_options_without_locale_removed.tap do |options|
          options[:_path_segments] = request.symbolized_path_parameters_without_locale
        end
      end

    end

    module PathParametersOverride
      def symbolized_path_parameters_without_locale
        @symbolized_path_parameters_without_locale ||= symbolized_path_parameters.except(:locale)
      end
    end

  end
end

ActionController::Base.send :include, I18nRoutable::UrlOptionsOverride::ActionControllerOverride
ActionDispatch::Request.send :include, I18nRoutable::UrlOptionsOverride::PathParametersOverride
