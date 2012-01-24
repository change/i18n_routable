I18n.load_path = (I18n.load_path << Dir[File.join(File.dirname(__FILE__), 'locales', 'routes.yml')]).uniq

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

        resources :posts do
          resources :comments
        end

        delocalize!

        localize do
          resources :events do
            member do
              post :join
            end
          end
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
