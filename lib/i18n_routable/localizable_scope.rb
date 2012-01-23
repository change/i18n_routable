module I18nRoutable::LocalizableScope

  def localize(options={}, &block)
    @localizing = true
    @locale_prefix = options[:locale_prefix] || /[a-z]{2}/
    yield
  ensure
    @localizing = false
  end

  def trans
    {:es => {"posts" => "puestos", "new" => "nueva", 'edit' => 'editar'}, :fr => {"posts" => "postes"}}
  end

  def generate_locale_route(locale, path, options)
    new_path = "/#{locale}/"
    new_path << path.split("/").map do |part|
      trans[locale][part].presence || part
    end.join('/')
    old_as = options[:as]
    options[:as] = "#{locale}_#{old_as}".to_sym if old_as.present?
    options[:locale] = locale.to_s
    mapping = ActionDispatch::Routing::Mapper::Mapping.new(@set, @scope, new_path, options || {}).to_route
    @set.add_route(*mapping)
    options[:as] = old_as
    options.delete(:locale)
  end


end
