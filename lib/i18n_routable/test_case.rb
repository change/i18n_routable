module  I18nRoutable
  module TestCase

    # patches test_request
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

ActionController::TestRequest.send :include, I18nRoutable::TestCase::TestRequestOverride
