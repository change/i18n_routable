module I18nRoutable
  module Util
    module ReverseRouteLookup

      # Returns the route name instead of the params
      # it also removes the localized route and just returns the base name
      # allowing you to send name with options :locale => locale if you want the same route
      # but in different locales
      # essientially copied from Rails.app.recognize_path
      def base_named_route_for path, environment = {}
        method = (environment[:method] || "GET").to_s.upcase
        path = Journey::Router::Utils.normalize_path(path) unless path =~ %r{://}

        env = ::Rack::MockRequest.env_for(path, {:method => method})

        req = @request_class.new(env)
        @router.recognize(req) do |route, matches, params|
          return route.name if route.name
        end
        nil
      end

    end
  end
end
