require 'spec_helper'
describe I18nRoutable do  
  
  include SpecRoutes.router.url_helpers
  
  def get(url)
    SpecRoutes.router.recognize_path(url)
  end
    
  it "should load rails" do
    Rails.should be_present
  end
  
  context '#url helpers' do
    
    it 'should generate urls from named_routes' do
      new_post_path.should == "/posts/new"
      blogs_path.should == '/blogs'
    end
  end
  
  context "incoming routes" do
    
    it 'should route properly' do
      get("/posts")
      # {:get => "/posts"}.should route_to(:controller => 'posts', :action => 'index') 
    end
  end
  
end
