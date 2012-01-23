module I18nRoutable::LocalizableRoute
  def localize(*args, &block)
    block.call
  end
end
