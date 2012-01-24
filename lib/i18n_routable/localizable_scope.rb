module I18nRoutable::LocalizableScope

  # Two ways of using:
  #
  # Use localize!/delocalize! to turn localization of routes on/off
  #
  #   resources :blogs # initially non-localized
  #   localize!
  #   resources :posts
  #   match 'events/:id'
  #   delocalize!
  #   resources :users
  #
  # Use localize to execute a block with localization turned on,
  # restoring the previous setting.
  #
  #   localize do
  #     resources :events
  #   end

  def localize! options={}
    I18nRoutable.localize_config = options.reverse_merge(default_localize_options)
  end

  def delocalize!
    I18nRoutable.localize_config = nil
  end

  def localize options={}
    old_localized_config = I18nRoutable.localize_config
    localize! options
    yield if block_given?
  ensure
    I18nRoutable.localize_config = old_localized_config
  end

  private

  def default_localize_options
    {
    :locale_prefix => true,
    :locales => I18n.available_locales - I18n.default_locale
    }
  end

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
    I18n.translate('routes', :locale => locale).each_pair { |k, v| new_path.gsub!(k.to_s, v) }
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
