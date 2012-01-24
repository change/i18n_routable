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
    I18nRoutable.localize_config = options.symbolize_keys.reverse_merge(default_localize_options)
    validate_options!
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
    :locales => I18n.available_locales - [I18n.default_locale]
    }
  end

  def validate_options!
    raise ArgumentError, ":locales must be an array, given: #{I18nRoutable.localize_config[:locales].inspect}" unless I18nRoutable.localize_config[:locales].is_a?(Array)
    extra_keys = I18nRoutable.localize_config.except(*default_localize_options.keys).keys
    raise ArgumentError, "Unsupported options: #{extra_keys.inspect}" if extra_keys.present?
  end

end
