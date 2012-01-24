require 'spec_helper'
describe I18nRoutable do

  before do
    I18n.locale = :en
  end

  include SpecRoutes.router.url_helpers

  def resolve(path)
    SpecRoutes.router.recognize_path(path)
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

    it "should have a precendence of named route over locale param" do
      es_posts_path(:locale => :en).should == '/es/puestos'
    end


  end

end
