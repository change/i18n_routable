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
    before do
      @old_conversions_from_backend_to_display_locales = I18nRoutable.localize_config[:backend_to_display_locales]
    end

    after do
      I18nRoutable.localize_config[:backend_to_display_locales] = @old_conversions_from_backend_to_display_locales
    end

    it 'should not support a symbol for :locales, it must take an array' do
      lambda do
        SpecRoutes.always_new_router.draw do
          localize! :locales => :fr
          resources :dogs
        end
      end.should raise_error(ArgumentError)
    end

    it 'should not support invalid options' do
      lambda do
        SpecRoutes.always_new_router.draw do
          localize! :foo => :boo
          resources :dogs
        end
      end.should raise_error(ArgumentError)
    end

    it 'should not support any strings for locales in a value' do
      lambda do
        SpecRoutes.always_new_router.draw do
          localize! :locales => { :gibberish => 'hey' }
          resources :dogs
        end
      end.should raise_error(ArgumentError)
    end

    it 'should not support any strings for locales in a key' do
      lambda do
        SpecRoutes.always_new_router.draw do
          localize! :locales => { 'gibberish' => :hey }
          resources :dogs
        end
      end.should raise_error(ArgumentError)
    end

    it 'should not support any strings for stand alone locales' do
      lambda do
        SpecRoutes.always_new_router.draw do
          localize! :locales => [{:gibberish => :hey}, 'es']
          resources :dogs
        end
      end.should raise_error(ArgumentError)
    end

    it 'should not support any locale hashes with multiple key/value pairs' do
      lambda do
        SpecRoutes.always_new_router.draw do
          localize! :locales => [{:gibberish => :hey, :not => :supported}, :es]
          resources :dogs
        end
      end.should raise_error(ArgumentError)
    end
  end

  context "incoming routes" do

    it 'should route properly' do
      resolve("/posts").should eql  :action => "index", :controller => "posts", :i18n_posts => "posts"
    end

    it 'should route a localized path properly' do
      resolve("/es/puestos").should eql :action => "index", :controller => "posts", :i18n_posts=>"puestos", :locale => "es"
      resolve("/fr-CA/canada_test").should eql :action => "foo", :controller => "test", :locale => "fr-CA", :i18n_test=>"canada_test"
    end

    it 'should resolve custom actions' do
      resolve("/es/puestos/1/unirse", :post).should eql :action=>"join", :controller=>"posts", :locale=>"es", :i18n_posts=>"puestos", :id=>"1", :i18n_join=>"unirse"
    end

    it 'should resolve nested resources' do
      expected = { :action=>"edit", :controller=>"comments", :locale=>"fr", :i18n_posts=>"messages", :post_id=>"hello-there", :i18n_comments=>"commentaires", :id=>"the-comment-id", :i18n_edit=>"modifier" }
      resolve("/fr/messages/hello-there/commentaires/the-comment-id/modifier").should eql expected
    end

    it "should keep the default value for untranslated route segments" do
      resolve("/gibberish/posts/").should eql :action=>"index", :controller=>"posts", :locale=>"gibberish", :i18n_posts=>"posts"
      resolve("/gibberish/posts/the-new").should eql :action=>"new", :controller=>"posts", :locale=>"gibberish", :i18n_posts=>"posts", :i18n_new=>"the-new"
    end

    it 'should recognize un-resourcful urls' do
      resolve('/es/todos-los-puestos').should eql :display=>"all", :controller=>"posts", :action=>"index", :locale=>"es", :i18n_all_the_posts=>"todos-los-puestos"
    end


  end

  context "utf-8 routes" do

    it "should escape outgoing routes" do
      I18n.locale = :es
      cafe_path.should eql '/es/caf%C3%A9'
    end

    it 'should resolve incoming escaped routes' do
      resolve('/es/caf%C3%A9').should eql :action=>"drink", :controller=>"cafe", :locale=>"es", :i18n_cafe=>"caf\xC3\xA9"

    end
  end

  context 'outgoing routes' do

    it 'should generate urls from named_routes' do
      new_post_path.should eql "/posts/new"
      blogs_path.should eql '/blogs'
    end

    it 'should keep the english if the translation is missing' do
      lambda { I18n.translate(:posts, :locale => 'gibb', :raise => true) }.should raise_error(I18n::MissingTranslationData)
      new_post_path(:locale => :gibb).should == "/gibberish/posts/the-new"
    end

    it 'should work for both _path and _url' do
      I18n.locale = :es
      posts_path.should eql "/es/puestos"
      posts_url.should eql "http://www.example.com/es/puestos"
    end

    it 'should change the route if the global locale changes' do
      I18n.locale = I18n.default_locale
      posts_path.should eql "/posts"

      I18n.locale = :es
      posts_path.should eql "/es/puestos"
    end

    it "should accept :locale param as an option" do
      posts_path(:locale => :es).should eql "/es/puestos"
      # Thread.current[:WTF] = true
      posts_path(:locale => :'fr-CA').should eql "/fr-CA/messages"
      posts_path(:locale => I18n.default_locale).should eql posts_path
    end

    it 'should override I18n.locale if :locale is passed in' do
      I18n.locale = :es
      posts_path(:locale => :en).should eql "/posts" # option overrides I18n.locale
      I18n.locale = :en
      posts_path(:locale => :es).should eql "/es/puestos" # option overrides I18n.locale
    end

    it "should accept :locale param as a symbol or string" do
      posts_path(:locale => :en).should eql "/posts" # option overrides I18n.locale
      posts_path(:locale => 'en').should eql "/posts" # option overrides I18n.locale
    end

    it "should not translate params" do
      posts_path(:locale => 'fr', :new => 'commentaires').should eql '/fr/messages?new=commentaires'
    end

    it "should understand nested resources" do
      new_post_comment_path(:locale => 'fr', :post_id => 12, :random => 'param').should eql '/fr/messages/12/commentaires/nouvelles?random=param'
    end

    it 'should render the default locale if given a bad locale' do
      posts_url(:locale => "INVALID").should eql "http://www.example.com/posts"
    end

    it 'should understand the difference between display locales and backend locales' do
      I18n.locale = :gibb
      new_post_url.should eql "http://www.example.com/gibberish/posts/the-new"
      I18n.locale = :en
      new_post_url(:locale => :gibb).should eql "http://www.example.com/gibberish/posts/the-new"
    end

  end

  context 'hash_for helpers' do

    it 'should return a localized route when using hash_for helpers passing in locale' do
      I18n.locale = 'fr'
      route_hash = hash_for_posts_url(:locale => 'es')
      route_hash.should eql :locale=>:es, :action=>"index", :controller=>"posts", :use_route=>"posts", :only_path=>false, :i18n_posts=>"puestos"
      url_for(route_hash).should eql "http://www.example.com/es/puestos"

      route_hash = hash_for_posts_url(:locale => :es)
      route_hash.should eql :locale=>:es, :action=>"index", :controller=>"posts", :use_route=>"posts", :only_path=>false, :i18n_posts=>"puestos"
      url_for(route_hash).should eql "http://www.example.com/es/puestos"
    end

    it 'should respect I18n.locale' do
      route_hash = hash_for_post_url(:id => 1)
      route_hash.should eql :id=>1, :action=>"show", :controller=>"posts", :use_route=>"post", :only_path=>false, :i18n_posts=>"posts"
      url_for(route_hash).should eql "http://www.example.com/posts/1"

      I18n.locale = 'es'

      route_hash = hash_for_post_url(:id => 1)
      route_hash.should eql :id=>1, :locale=>:es, :action=>"show", :controller=>"posts", :use_route=>"post", :only_path=>false, :i18n_posts=>"puestos"
      url_for(route_hash).should eql "http://www.example.com/es/puestos/1"
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
