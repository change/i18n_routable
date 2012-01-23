class SpecRoutes
  
  cattr_accessor :router
  
  def self.draw!
    self.router = ActionDispatch::Routing::RouteSet.new
    self.router.draw do
      resources :posts

      localize do
        resources :blogs
      end
    end
  end
    
end

SpecRoutes.draw!
