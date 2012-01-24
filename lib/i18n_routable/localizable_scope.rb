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

  def localize!
    I18nRoutable.localized = true
  end

  def delocalize!
    I18nRoutable.localized = false
  end

  def localize
    old_localized = I18nRoutable.localized
    localize!
    yield if block_given?
  ensure
    I18nRoutable.localized = old_localized
  end

  private

  def translate_route en_route
    en_path     = en_route[1][:path_info]
    en_defaults = en_route[3]
    en_name     = en_route[4]
    TRANS.keys.each do |locale|
      localized_route = en_route.dup
      localized_route[1][:path_info] = translated_path(en_path, locale)
      localized_route[3]             = translated_defaults(en_defaults, locale)
      localized_route[4]             = translated_name(en_name, locale) if en_name
      @set.add_route(*localized_route)
    end
  end

  def translated_path en_path, locale
    new_path = en_path.dup
    new_path.insert 0, "/#{locale}"
    TRANS[locale].each { |k, v| new_path.gsub!(k, v) }
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

  TRANS = {
    :es => {
      "posts" => "puestos",
      "events" => "eventos",
      "new" => "neuvo",
      "edit" => "editar"
    },
    :fr => {
      "posts" => "messages",
      "events" => "evenements",
      "new" => "nouvelles",
      "edit" => "modifier"
    }
  }

end
