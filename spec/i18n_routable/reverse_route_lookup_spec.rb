# encoding: utf-8
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
      base_named_route_for('/es/puestos/neuvo').should eql :new_post
    end

    it "should not fail under a route that doesn't exist" do
      base_named_route_for("/route-that-doesn't-exist").should be_nil
    end

    def force_encoding path, encoding
      path.force_encoding encoding
      path.encoding.to_s.should == encoding
      path
    end

    it 'should raise an exception on unicode paths' do
      path = "/es/puestos/é"
      force_encoding path, 'UTF-8'
      expect { base_named_route_for(path) }.to raise_error URI::InvalidURIError
    end

    it 'should raise an exception on binary paths' do
      path = "/es/puestos/h\xC3\xA9llo"
      force_encoding path, 'ASCII-8BIT'
      expect { base_named_route_for(path) }.to raise_error URI::InvalidURIError
    end

  end

end
