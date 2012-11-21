module I18nRoutable
  module Generating
    module LocalizableUrlHelper

      # we override this, but it really only removes positional_keys that are
      # locale or i18n_*
      def define_url_helper_with_localize(route, name, kind, options)
        selector = url_helper_name(name, kind)
        hash_access_method = hash_access_name(name, kind)
        positional_segments = route.segment_keys.reject do |key|
          key == :locale || key.to_s.starts_with?("i18n_")
        end

        @module.module_eval <<-END_EVAL, __FILE__, __LINE__ + 1
          def #{selector}(*args)
            options =  #{hash_access_method}(args.extract_options!)

            if args.any?
              options[:_positional_args] = args
              options[:_positional_keys] = #{positional_segments.inspect}
            end

            url_for(options)
          end
        END_EVAL
        helpers << selector
      end

      def self.included(base)
        base.alias_method_chain :define_url_helper, :localize
      end

    end
  end
end
