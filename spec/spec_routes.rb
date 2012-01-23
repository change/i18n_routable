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

        localize :locale_prefix => /[a-z]{2}/ do
          resources :posts
        end
      end
    end
  end

end

SpecRoutes.go!
