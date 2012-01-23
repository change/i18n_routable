require 'spec_helper'
describe I18nRoutable do  
  
  include SpecRoutes.router.url_helpers
  
  it "should load rails" do
    Rails.should be_present
  end
  
  context '#url helpers' do
    
    it 'should generate urls from named_routes' do
      new_post_path.should == "/posts/new"
      blogs_path.should == '/blogs'
    end
  end
  
end
