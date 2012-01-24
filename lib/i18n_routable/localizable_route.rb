module I18nRoutable::LocalizableRoute

  private

  def translate_route en_route
    en_path     = en_route[1][:path_info]
    en_defaults = en_route[3]
    en_name     = en_route[4]
    I18nRoutable.localize_config[:locales].each do |locale|
      localized_route = en_route.dup
      localized_route[1][:path_info] = translated_path(en_path, locale)
      localized_route[3]             = translated_defaults(en_defaults, locale)
      localized_route[4]             = translated_name(en_name, locale) if en_name
      @set.add_route(*localized_route)
    end
  end

  def translated_path en_path, locale
    new_path = en_path.dup
    new_path.insert 0, "/#{locale}" if I18nRoutable.localize_config[:locale_prefix]
    translation = I18n.translate 'routes', :locale => locale, :default => {}
    translation.each_pair { |k, v| new_path.gsub!(k.to_s, v) }
    new_path
  end

  def translated_defaults en_defaults, locale
    new_defaults = en_defaults.dup
    new_defaults[:locale] = locale.to_s
    new_defaults
  end

  def translated_name en_name, locale
    "#{locale}_#{en_name}"
  end

end
