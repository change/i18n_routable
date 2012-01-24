class SpecRoutes

  cattr_accessor :router

  class << self

    def go!
      draw!
    end

    def draw!
      self.router = ActionDispatch::Routing::RouteSet.new
      self.router.draw do
        resources :blogs

        localize!

        resources :posts

        delocalize!

        localize do
          resources :events
        end

        localize(:locale_prefix => false) do
          resources :users
        end

        resources :profiles
      end
    end
  end

end

SpecRoutes.go!
