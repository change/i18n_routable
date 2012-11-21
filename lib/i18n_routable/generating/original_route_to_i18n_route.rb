module I18nRoutable
  module Generating
    module OriginalRouteToI18nRoute

      def add_route_with_localize app, conditions = {}, requirements = {}, defaults = {}, name = nil, anchor = true
        if I18nRoutable.localizing?
          conditions[:path_info], requirements = I18nRoutable.convert_path_to_localized_regexp(conditions[:path_info], requirements, anchor)
        end
        add_route_without_localize(app, conditions, requirements, defaults, name, anchor)
      end

      def self.included base
        base.alias_method_chain :add_route, :localize
      end

    end
  end
end
