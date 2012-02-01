require 'spec_helper'
describe I18nRoutable do

  before do
    I18n.locale = :en
  end

  include SpecRoutes.router.url_helpers

  def resolve(path, http_verb=:get)
    SpecRoutes.router.recognize_path(path, {:method => http_verb})
  end

  it "should load rails" do
    Rails.should be_present
  end

  context "incoming routes" do

    it 'should route properly' do
      resolve("/posts").should == { :action => "index", :controller => "posts" }
    end

    it 'should route a localized path properly' do
      resolve("/es/puestos").should == { :action => "index", :controller => "posts", :locale => "es" }
    end

    it 'should not route an unlocalized path properly' do
      lambda { resolve("/es/blogs") }.should raise_error(ActionController::RoutingError)
      lambda { resolve("/fr/profils") }.should raise_error(ActionController::RoutingError)
    end

    it 'should not prefix the locale on unprefixed routes' do
      lambda { resolve("/es/usuarios") }.should raise_error(ActionController::RoutingError)
      resolve("/usuarios").should  == { :action => "index", :controller => "users", :locale => "es" }
      resolve("/utilisateurs").should  == { :action => "index", :controller => "users", :locale => "fr" }
    end

    it 'should resolve custom actions' do
      resolve("/es/eventos/1/unirse", :post).should == { :action => "join", :id => "1", :controller => "events", :locale => "es" }
    end

    it 'should resolve nested resources' do
      expected = { :action => "edit", :post_id => "hello-there", :id => 'the-comment-id', :controller => "comments", :locale => "fr" }
      resolve("/fr/messages/hello-there/commentaires/the-comment-id/modifier").should == expected
    end

    it "should not translate a route for an unexisting translation" do
      resolve("/gibberish/polls").should == { :action => "index", :controller => "polls", :locale => "gibberish" }
    end

  end

  context '#url helpers' do

    it 'should generate urls from named_routes' do
      new_post_path.should == "/posts/new"
      blogs_path.should == '/blogs'
    end

    it 'should change the route if the global locale changes' do
      I18n.locale = I18n.default_locale
      posts_path.should == "/posts"

      I18n.locale = :es
      posts_path.should == "/es/puestos"
    end

    it "should create named routes with locale prefixes" do
      es_posts_path.should == "/es/puestos"
      fr_new_event_path.should == "/fr/evenements/nouvelles"
    end

    it "should create named routes without locale prefixes when specified" do
      es_users_path.should == "/usuarios"
      new_user_path(:locale => :fr).should == "/utilisateurs/nouvelles"
    end

    it "should not create a named route for the default locale" do
      lambda { en_posts_path }.should raise_error(NameError)
    end

    it "should not create named routes for unlocalized routes" do
      lambda { es_blogs_path }.should raise_error(NameError)
      lambda { fr_profiles_path }.should raise_error(NameError)
    end

    it "should accept :locale param as an option" do
      posts_path(:locale => :es).should == "/es/puestos"
      posts_path(:locale => I18n.default_locale).should == posts_path
      I18n.locale = :es
      posts_path(:locale => :en).should == "/posts" # option overrides I18n.locale
    end

    it "should accept :locale param as a symbol or string" do
      posts_path(:locale => :en).should == "/posts" # option overrides I18n.locale
      posts_path(:locale => 'en').should == "/posts" # option overrides I18n.locale
    end

    it "should have a precendence of named route over locale param" do
      es_posts_path(:locale => :en).should == '/es/puestos'
    end

    it "should understand nested resources" do
      fr_new_post_comment_path(:post_id => 12, :random => 'param').should == '/fr/messages/12/commentaires/nouvelles?random=param'
    end

    it "should create named url helpers" do
      es_posts_url.should == "http://www.example.com/es/puestos"
      I18n.locale = :es
      post_url(2).should == "http://www.example.com/es/puestos/2"
    end

  end

  context 'validating config options' do

    it 'should not support a symbol for :locales' do
      lambda do
        SpecRoutes.router.draw do
          localize :locales => :fr do
            resources :dogs
          end
        end
      end.should raise_error(ArgumentError)
    end

    it 'should not support invalid options' do
      lambda do
        SpecRoutes.router.draw do
          localize :foo => :boo do
            resources :dogs
          end
        end
      end.should raise_error(ArgumentError)
    end

  end

end
