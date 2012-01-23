module I18nRoutable::LocalizableMatcher

  def self.included(base)
    base.alias_method_chain :match, :localize
  end


  def match_with_localize(path, options=nil)
    # create normal english route
    match_without_localize(path, options).tap do
      # create localized routes
      if @localizing
        trans.keys.each do |locale|
          generate_locale_route(locale, path, options)
        end
      end
    end
  end

end
