require 'spec_helper'
describe I18nRoutable::Mapper::LocalizableRoute do

  subject { Class.new { include I18nRoutable::Mapper::LocalizableRoute }.new}

  context '#translated_path' do

    before do
      I18nRoutable.localize_config = {}
    end

    def t path, locale
      subject.send(:translated_path, path, locale)
    end

    it "should translate the components of a normal url" do
      t("/posts", :es).should == "/puestos"
      t("/posts/new", :fr).should == "/messages/nouvelles"
    end

    it "should ignore param names" do
      t("/posts/:posts", :es).should == "/puestos/:posts"
      t("/posts(/:id)(.:format)", :es).should == "/puestos(/:id)(.:format)"
      t('all-the-posts(/:action(/:id))', :es).should == 'todos-los-puestos(/:action(/:id))'
      t(':alias/events/:old_action', :fr).should == ":alias/evenements/:old_action"
    end

    it "replace the entire component or none of it" do
      t("/more-posts", :es).should == "/more-posts"
      t("/posts/more-posts", :es).should == "/puestos/more-posts"
      t("/more-posts/posts", :es).should == "/more-posts/puestos"
    end

  end

end
