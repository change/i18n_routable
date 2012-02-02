module I18nRoutable::ReverseRouteLookup


  # Pretty much directly copied from ActionDispatch::Routing::RouteSet#recognize_path
  # It just returns the route name instead of the params
  # it also removes the localized route and just returns the base name
  # allowing you to send name with options :locale => locale if you want the same route
  # but in different locales
  def base_named_route_for(path, environment = {})
    method = (environment[:method] || "GET").to_s.upcase
    path = Rack::Mount::Utils.normalize_path(path) unless path =~ %r{://}

    begin
      env = Rack::MockRequest.env_for(path, {:method => method})
    rescue URI::InvalidURIError => e
      raise ActionController::RoutingError, e.message
    end

    req = @request_class.new(env)
    route, matches, params = @set.recognize(req)
    name = route.try(:name)
    if name && params[:locale].present?
      name = name.to_s.gsub(/^#{params[:locale]}_/, '').to_sym
    end
    return name
  end

end
