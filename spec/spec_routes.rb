class SpecRoutes

  cattr_accessor :router

  class << self

    def routes_yml
      Dir[File.join(File.dirname(__FILE__), 'locales', 'routes.yml')].first
    end

    def go!
      draw!
      set_default_host!
      include_helper!
    end

    def always_new_router
      ActionDispatch::Routing::RouteSet.new
    end


    def draw!
      self.router = ActionDispatch::Routing::RouteSet.new
      self.router.draw do
        localize! :locales => [{:gibberish => :gibb}, :aussie, :es, :fr, :'fr-CA']

        localize do

          get :constraints => proc { false }, "*path" => "FooController#foo"

          resources :blogs

          resources :posts do
            member do
              post :join
            end
            resources :comments
          end

          get 'cafe' => 'cafe#drink'

          get 'all-the-posts' => 'posts#index', :as => :all_posts, :defaults => {:display => 'all'}

          match "/bypass_action_controller", :to => proc {|env| [200, {}, ["Hello world"]] }

          match 'about(/*anything)' => 'cms#show', :as => :about

          # TestController
          get 'test' => "test#foo", :as => :test
          get 'testing_url_for' => 'test#use_url_for_with_implicit_params'

          root :to => 'test#root'
        end

      end
    end

    def set_default_host!
      self.router.default_url_options[:host] = 'www.example.com'
    end

    def include_helper!
      ActionController::Base.descendants.each {|d| d.send :include, self.router.url_helpers}
    end
  end

end
I18n.load_path = (I18n.load_path << SpecRoutes.routes_yml).uniq

SpecRoutes.go!
