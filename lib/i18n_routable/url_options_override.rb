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


    module TestRequestOverride

      def self.included base
        base.alias_method_chain :assign_parameters, :locale_removed
      end

      def assign_parameters_with_locale_removed(routes, controller_path, action, parameters = {})
        assign_parameters_without_locale_removed(routes, controller_path, action, parameters)
        @symbolized_path_parameters_without_locale = nil
      end
    end

  end
end

ActionController::UrlFor.send :include, I18nRoutable::UrlOptionsOverride::ActionControllerOverride
ActionDispatch::Http::Parameters.send :include, I18nRoutable::UrlOptionsOverride::PathParametersOverride
if Rails.env.test?
  ActionController::TestCase # make sure it is loaded
  ActionController::TestRequest.send :include, I18nRoutable::UrlOptionsOverride::TestRequestOverride
end
