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
  end

  context "incoming routes" do

    it 'should route properly' do
      resolve("/posts").should == { :action=>"index", :controller=>"posts" }
    end
  end

end
