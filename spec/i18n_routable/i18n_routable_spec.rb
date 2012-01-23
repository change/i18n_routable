require 'spec_helper'
describe I18nRoutable do

  include SpecRoutes.router.url_helpers

  def resolve(path)
    SpecRoutes.router.recognize_path(path)
  end

  it "should load rails" do
    Rails.should be_present
  end

  context '#url helpers' do

    it 'should generate urls from named_routes' do
      new_post_path.should == "/posts/new"
      blogs_path.should == '/blogs'
    end

    it "should not generate named routes with not wrapped with localize" do
      lambda { es_blogs_path }.should raise_error(NameError)
    end

    it 'should change the route if the locale changes' do
      posts_path.should == "/posts"

      I18n.locale = :es
      posts_path.should == "/es/puestos"
    end

    it "should create named routes with locale prefixes" do
      posts_path.should == "/posts"
      es_posts_path.should == "/es/puestos" #named route overrides I18n.locale
      lambda { en_posts_path }.should raise_error(NameError)
    end

    it "should accept :locale param as an option" do
      posts_path(:locale => :es).should == "/es/puestos"
      posts_path(:locale => I18n.default_locale).should == posts_path
      I18n.locale = :es
      posts_path(:locale => :en).should == "/posts" # option overrides I18n.locale
    end

    # name takes precendence over option
    #   except in default named_route
    it "should have a precendence of named_route over param locale" do
      posts_path(:locale => :es).should == '/es/puestos'
      es_posts_path(:locale => :en).should == '/es/puestos'
    end
  end

  context "incoming routes" do

    it 'should route properly' do
      resolve("/posts").should == { :action => "index", :controller => "posts" }
    end

    it 'should route a localized path properly' do
      resolve("/es/puestos").should == { :action => "index", :controller => "posts", :locale => 'es' }
    end

    it 'should not route a localized path properly for an unlocalized route' do
      lambda { resolve("/es/blogs") }.should raise_error(ActionController::RoutingError)
    end
  end
end
