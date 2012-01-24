I18n.load_path = (I18n.load_path << Dir[File.join(File.dirname(__FILE__), 'locales', 'routes.yml')]).uniq

class SpecRoutes

  cattr_accessor :router

  class << self

    def go!
      draw!
      set_default_host!
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

        localize(:locales => [:gibberish]) do
          resources :polls
        end

        resources :profiles
      end
    end

    def set_default_host!
      self.router.default_url_options[:host] = 'www.example.com'
    end
  end

end

SpecRoutes.go!
