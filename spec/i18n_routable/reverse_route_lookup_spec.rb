require 'spec_helper'
describe I18nRoutable::RouteSet::ReverseRouteLookup do

  def base_named_route_for(options)
    SpecRoutes.router.base_named_route_for(options)
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
