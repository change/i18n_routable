# outoing route helper that injects i18n_ paramsto generate the route
module I18nRoutable
  module Outgoing
    module LocalizableFormatter

      def generate_with_localize name, options, recall = {}, parameterize = nil
        constraints = recall.merge options
        locale = add_locale_param(constraints) #added this line

        match_route(name, constraints) do |route|
          data = constraints.dup

          keys_to_keep = route.parts.reverse.drop_while { |part|
            !options.key?(part) || (options[part] || recall[part]).nil?
            } | route.required_parts

          (data.keys - keys_to_keep).each do |bad_key|
            data.delete bad_key
          end

          parameterized_parts = data.dup

          # Added these lines
          reject_unnecessary_i18n_params!(options, route.required_parts)
          inject_i18n_translations(parameterized_parts, route.required_parts)
          modify_locale(parameterized_parts, locale)
          options.delete(:locale)

          if parameterize
            parameterized_parts.each do |k,v|
              parameterized_parts[k] = parameterize.call(k, v)
            end
          end

          parameterized_parts.keep_if { |_,v| v  }

          next if !name && route.requirements.empty? && route.parts.empty?

          next unless missing_keys(route, parameterized_parts)

          z = Hash[options.to_a - data.to_a - route.defaults.to_a]

          return [route.format(parameterized_parts), z]
        end

        raise ActionDispatch::Journey::Router::RoutingError
      end

      def reject_unnecessary_i18n_params!(params, required_params)
        params.reject! do |(param_name, value)|
          param_name.to_s.starts_with?('i18n_')
        end
      end

      def add_locale_param(constraints)
        # set the locale to the params or current
        locale = I18nRoutable.convert_to_backend_locale(constraints[:locale]) || I18n.locale
        # reject the locale unless we support that locale
        constraints[:locale] = I18nRoutable.backend_locales.include?(locale) ? locale : I18n.default_locale
        constraints[:locale]
      end



      def modify_locale(params, locale)
        # delete the locale if it's the default (no locale in scope)
        if locale.to_s == I18n.default_locale.to_s
          params.delete :locale
        else
          # reset the locale to the display version
          params[:locale] = I18nRoutable.convert_to_display_locale(locale)
        end
      end

      # this method injects translations into the params
      # that start with i18n_
      # :i18n_posts => 'puestos'
      def inject_i18n_translations(params, required_params)
        reject_unnecessary_i18n_params!(params, required_params)
        required_params_to_check = required_params
        return unless required_params_to_check

        required_params_to_check.each do |required_param|
          if required_param.to_s =~ /i18n_(.+)/
            params[required_param] ||= I18nRoutable.translate_segment($1, params[:locale])
          end
        end
      end


      def self.included base
        base.send :alias_method_chain, :generate, :localize
      end
    end

  end
end
