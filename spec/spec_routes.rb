class SpecRoutes

  cattr_accessor :router

  class << self

    def go!
      draw!
    end

    def draw!
      self.router = ActionDispatch::Routing::RouteSet.new
      self.router.draw do
        resources :posts

        localize do
          resources :blogs
        end
      end
    end
  end

end

SpecRoutes.go!
