module I18nRoutable::LocalizableUrlHelper

  def define_url_helper_with_localize(route, name, kind, options)
    define_url_helper_without_localize(route, name, kind, options).tap do
      url_name = "#{name}_#{kind}"
      if I18nRoutable.defining_base
        @module.module_eval method_definition_of_base_localized_route(url_name), __FILE__, __LINE__
      elsif I18nRoutable.localized?
        @module.module_eval method_definition_of_localized_route(url_name), __FILE__, __LINE__
      end
    end
  end

  def method_definition_of_base_localized_route(url_name)
    <<-RUBY
      def #{url_name}_with_localize(*args)
        options = args.extract_options!
        args << options
        if options.has_key?(:locale)
          locale = options.delete(:locale)
          locale = nil if locale == I18n.default_locale
        elsif I18n.locale && I18n.locale != I18n.default_locale
          locale = I18n.locale
        end
        if locale
          send(:"\#\{locale\}_#{url_name}", *args)
        else
          #{url_name}_without_localize(*args)
        end
      end
      alias_method_chain :#{url_name}, :localize
    RUBY
  end

  def method_definition_of_localized_route(url_name)
    <<-RUBY
      def #{url_name}_with_localize(*args)
        options = args.extract_options!
        options.delete(:locale)
        #{url_name}_without_localize(*(args << options))
      end

      alias_method_chain :#{url_name}, :localize
    RUBY
  end

  def self.included(base)
    base.alias_method_chain :define_url_helper, :localize
  end

end
