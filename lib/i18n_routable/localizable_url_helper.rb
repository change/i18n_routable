module I18nRoutable::LocalizableUrlHelper

  def self.extract_locale!(args)
    locale = nil
    options = args.extract_options!
    if options.has_key?(:locale)
      locale = options.delete(:locale).to_s
      locale = nil if locale == I18n.default_locale.to_s
    elsif I18n.locale && I18n.locale != I18n.default_locale
      locale = I18n.locale.to_s
    end
    args << options if options.present?
    [locale, args]
  end

  def define_hash_access_with_localize(route, name, kind, options)
    define_hash_access_without_localize(route, name, kind, options).tap do
      selector = hash_access_name(name, kind)
      if I18nRoutable.defining_base
        @module.module_eval method_definition_of_base_localized_route_hash_helper(selector, I18nRoutable.locales, name), __FILE__
      elsif I18nRoutable.localized?
        @module.module_eval method_definition_of_localized_route_hash_helper(selector), __FILE__
      end
    end
  end

  def method_definition_of_base_localized_route_hash_helper(selector, locales, name)
    <<-RUBY
      def #{selector}_with_localize(options={})
        locale, args = I18nRoutable::LocalizableUrlHelper.extract_locale!([options])
        #{selector}_without_localize(*args).tap do |hsh|
          if locale && #{locales.inspect}.include?(locale)
            hsh[:use_route] = "\#\{locale\}_#{name}"
          end
        end
      end
      alias_method_chain :#{selector}, :localize
    RUBY
  end

  def method_definition_of_localized_route_hash_helper(selector)
    <<-RUBY
      def #{selector}_with_localize(*args)
        options = args.extract_options!
        options.delete(:locale)
        #{selector}_without_localize(*(args << options))
      end
      alias_method_chain :#{selector}, :localize
    RUBY
  end

  def self.included(base)
    base.alias_method_chain :define_hash_access, :localize
  end

end
