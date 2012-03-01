module I18nRoutable
  module Mapper
    module LocalizableMatcher

      def match_with_localize path, options={}
        options_clone = deep_clone(options)
        I18nRoutable.defining_base = I18nRoutable.localized?
        match_without_localize(path, options).tap do
          I18nRoutable.defining_base = false
          if I18nRoutable.localized?
            translate_route ActionDispatch::Routing::Mapper::Mapping.new(@set, @scope, path, options_clone).to_route
          end
        end
      end

      def self.included base
        base.alias_method_chain :match, :localize
      end

    end
  end
end