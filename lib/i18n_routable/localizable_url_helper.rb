module I18nRoutable::LocalizableUrlHelper

  def define_url_helper_with_localize(route, name, kind, options)
    define_url_helper_without_localize(route, name, kind, options).tap do
      if I18nRoutable.defining_base
        @module.module_eval <<-END_EVAL, __FILE__, __LINE__ + 1
          def #{name}_#{kind}(*args)
            options = hash_for_#{name}_#{kind}(args.extract_options!)

            if args.any?
              options[:_positional_args] = args
              options[:_positional_keys] = #{route.segment_keys.inspect}
            end

            locale = options.delete(:locale) || I18n.locale

            if locale != :en
              send(:"\#\{locale\}_#{name}_#{kind}", *args)
            else
              url_for(options)
            end
          end
        END_EVAL
      end
    end
  end

  def self.included(base)
    base.alias_method_chain :define_url_helper, :localize
  end

end
