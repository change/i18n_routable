# outoing route helper that injects i18n_ params when scoring the route
module I18nRoutable
  module Outgoing
    module LocalizableRoute

      def required_i18n_names
        @required_i18n_names ||= path.required_names.inject({}) do |hsh, name|
          if name =~ /i18n_(.+)/
            hsh[name] = $1
          end
          hsh
        end
      end

      def merge_localized_constraints! constraints
        required_i18n_names.each do |param_name, name|
          constraints[param_name] ||= I18nRoutable.translate_segment(name, constraints[:locale])
        end
      end

      def score_with_localize constraints
        merge_localized_constraints!(constraints)
        score_without_localize constraints
      end



      def self.included base
        base.send :alias_method_chain, :score, :localize
      end

    end
  end
end
