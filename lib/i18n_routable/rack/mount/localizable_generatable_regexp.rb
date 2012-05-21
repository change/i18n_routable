module I18nRoutable
  module Rack
    module Mount
      module LocalizableGeneratableRegexp


        # this method injects translations into the params based on required_params
        # that start with i18n_
        # :i18n_posts => 'puestos'
        def inject_i18n_translations(params)

          required_params_to_check = required_params - params.keys
          return unless required_params_to_check

          required_params_to_check.each do |required_param|
            if required_param.to_s =~ /i18n_(.+)/
              params[required_param] ||= I18nRoutable.translate_segment($1, params[:locale])
            end
          end

        end

        def generate_with_localize(params = {}, recall = {}, options = {})
          # set the locale to the params or current
          params[:locale] ||= I18nRoutable.convert_to_backend_locale(params[:locale]) || I18n.locale
          # reject the locale unless we support that locale
          params[:locale] = I18n.default_locale unless I18nRoutable.backend_locales.include?(params[:locale].to_sym)

          merged = recall.merge(params)
          should_inject_translations = required_defaults.present? && required_defaults.all? { |k, v| merged[k] == v }
          inject_i18n_translations(params) if should_inject_translations

          # delete the locale if it's the default (no locale in scope)
          if params[:locale].to_s == I18n.default_locale.to_s
            params.delete :locale
          else
            # reset the locale to the display version
            params[:locale] = I18nRoutable.convert_to_display_locale(params[:locale])
          end

          # call super
          generate_without_localize(params, recall, options)
        end

        def self.included base
          base.send :alias_method_chain, :generate, :localize
        end
      end

    end
  end
end

Rack::Mount::GeneratableRegexp::InstanceMethods.send :include, I18nRoutable::Rack::Mount::LocalizableGeneratableRegexp
