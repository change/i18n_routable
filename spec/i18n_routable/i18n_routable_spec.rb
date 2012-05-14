require 'spec_helper'
describe I18nRoutable do

  before do
    I18n.locale = :en
  end

  include SpecRoutes.router.url_helpers

  def resolve(path, http_verb=:get)
    SpecRoutes.router.recognize_path(path, {:method => http_verb})
  end

  def base_named_route_for(options)
    SpecRoutes.router.base_named_route_for(options)
  end

  it 'should load the version' do
    I18nRoutable::VERSION.should be_present
  end

  it "should load rails" do
    Rails.should be_present
  end

  context 'validating config options' do

    it 'should not support a symbol for :locales, it must take an array' do
      lambda do
        SpecRoutes.always_new_router.draw do
          localize :locales => :fr do
            resources :dogs
          end
        end
      end.should raise_error(ArgumentError)
    end

    it 'should not support invalid options' do
      lambda do
        SpecRoutes.always_new_router.draw do
          localize :foo => :boo do
            resources :dogs
          end
        end
      end.should raise_error(ArgumentError)
    end

  end

  context "incoming routes" do

    it 'should route properly' do
      resolve("/posts").should eql :action => "index", :controller => "posts"
    end

    it 'should route a localized path properly' do
      resolve("/es/puestos").should eql :action => "index", :controller => "posts", :locale => "es"
      resolve("/fr-CA/canada_test").should eql :action => "foo", :controller => "test", :locale => "fr-CA"
    end

    it 'should not route an unlocalized path properly' do
      lambda { resolve("/es/blogs") }.should raise_error(ActionController::RoutingError)
      lambda { resolve("/fr/profils") }.should raise_error(ActionController::RoutingError)
    end

    it 'should not prefix the locale on unprefixed routes' do
      lambda { resolve("/es/usuarios") }.should raise_error(ActionController::RoutingError)
      resolve("/usuarios").should eql  :action => "index", :controller => "users", :locale => "es"
      resolve("/utilisateurs").should eql :action => "index", :controller => "users", :locale => "fr"
    end

    it 'should resolve custom actions' do
      resolve("/es/eventos/1/unirse", :post).should eql :action => "join", :id => "1", :controller => "events", :locale => "es"
    end

    it 'should resolve nested resources' do
      expected = { :action => "edit", :post_id => "hello-there", :id => 'the-comment-id', :controller => "comments", :locale => "fr" }
      resolve("/fr/messages/hello-there/commentaires/the-comment-id/modifier").should eql expected
    end

    it "should not translate a route for an unexisting translation" do
      resolve("/gibberish/polls/").should eql  :action => "index", :controller => "polls", :locale => "gibberish"
      resolve("/gibberish/polls/the-new").should eql  :action => "new", :controller => "polls", :locale => "gibberish"
    end

    it 'should recognize un-resourcful urls' do
      resolve('/es/todos-los-puestos').should eql :display => "all", :locale => "es", :action => "index", :controller => "posts"
    end

  end

  context "utf-8 routes" do
    it "should escape outgoing routes" do
      I18n.locale = :es
      cafe_path.should eql '/es/caf%C3%A9'
    end
    it 'should resolve incoming escaped routes' do
      resolve('/es/caf%C3%A9').should eql :locale => "es", :action => "drink", :controller => "cafe"
    end
  end

  context '#url helpers' do

    it 'should generate urls from named_routes' do
      new_post_path.should eql "/posts/new"
      blogs_path.should eql '/blogs'
    end

    it 'should change the route if the global locale changes' do
      I18n.locale = I18n.default_locale
      posts_path.should eql "/posts"

      I18n.locale = :es
      posts_path.should eql "/es/puestos"
    end

    it "should create named routes with locale prefixes" do
      es_posts_path.should eql "/es/puestos"
      fr_new_event_path.should eql "/fr/evenements/nouvelles"
      fr_ca_new_event_path.should eql "/fr-CA/evenements/nouvelles"
    end

    it "should create named routes without locale prefixes when specified" do
      es_users_path.should eql "/usuarios"
      new_user_path(:locale => :fr).should eql "/utilisateurs/nouvelles"
    end

    it "should not create a named route for the default locale" do
      lambda { en_posts_path }.should raise_error(NameError)
    end

    it "should not create named routes for unlocalized routes" do
      lambda { es_blogs_path }.should raise_error(NameError)
      lambda { fr_profiles_path }.should raise_error(NameError)
    end

    it "should accept :locale param as an option" do
      posts_path(:locale => :es).should eql "/es/puestos"
      posts_path(:locale => :'fr-CA').should eql "/fr-CA/messages"
      posts_path(:locale => I18n.default_locale).should eql posts_path
      I18n.locale = :es
      posts_path(:locale => :en).should eql "/posts" # option overrides I18n.locale
    end

    it "should accept :locale param as a symbol or string" do
      posts_path(:locale => :en).should eql "/posts" # option overrides I18n.locale
      posts_path(:locale => 'en').should eql "/posts" # option overrides I18n.locale
    end

    it "should have a precendence of named route over locale param" do
      es_posts_path(:locale => :en).should eql '/es/puestos'
    end

    it "should understand nested resources" do
      fr_new_post_comment_path(:post_id => 12, :random => 'param').should eql '/fr/messages/12/commentaires/nouvelles?random=param'
    end

    it "should create named url helpers" do
      es_posts_url.should eql "http://www.example.com/es/puestos"
      I18n.locale = :es
      post_url(2).should eql "http://www.example.com/es/puestos/2"
    end

    it 'should render the default locale if given a bad locale' do
      posts_url(:locale => "INVALID").should eql "http://www.example.com/posts"
    end

    it 'should understand the difference between display locales and backend locales' do
      I18n.locale = :gibb
      new_poll_url.should eql "http://www.example.com/gibberish/polls/the-new"
      gibb_new_poll_url.should eql "http://www.example.com/gibberish/polls/the-new"
    end

  end

  context 'hash_for helpers' do

    it 'should return a localized route when using hash_for helpers' do
      hash_for_posts_url(:locale => 'es').should eql :action => "index", :controller => "posts", :use_route => "es_posts", :only_path => false
    end

    it 'should respect I18n.locale' do
      hash_for_post_url(:id => 1).should eql :action => "show", :controller => "posts", :use_route => "post", :id => 1, :only_path => false
      I18n.locale = 'es'
      hash_for_post_url(:id => 1).should eql :action => "show", :controller => "posts", :use_route => "es_post", :id => 1, :only_path => false
    end

  end

  context '#base_named_route_for' do

    it 'should pick the best route' do
      base_named_route_for('/posts').should eql :posts
      base_named_route_for("/posts?random=variable").should eql :posts
      base_named_route_for("/all-the-posts").should eql :all_posts
      base_named_route_for("posts/1").should eql :post
    end

    it 'should remove the locale from the name' do
      base_named_route_for('/es/puestos').should eql :posts
      base_named_route_for('/es/puestos/2').should eql :post
    end

    it "should not fail under a route that doesn't exist" do
      base_named_route_for("/route-that-doesn't-exist").should be_nil
    end

  end

end
