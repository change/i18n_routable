module I18nRoutable
  module RouteSet
    module ReverseRouteLookup

      # Returns the route name instead of the params
      # it also removes the localized route and just returns the base name
      # allowing you to send name with options :locale => locale if you want the same route
      # but in different locales
      def base_named_route_for path, environment = {}
        method = (environment[:method] || "GET").to_s.upcase
        path = ::Rack::Mount::Utils.normalize_path(path) unless path =~ %r{://}

        begin
          env = ::Rack::MockRequest.env_for(path, {:method => method})
        rescue URI::InvalidURIError => e
          raise ActionController::RoutingError, e.message
        end

        req = @request_class.new(env)
        @set.recognize(req) do |route, matches, params|
          if route.name
            if params[:locale].present?
              return route.name.to_s.sub(/[^_]+_/, '').to_sym
            else
              return route.name
            end
          end
        end
        nil
      end

    end
  end
end
