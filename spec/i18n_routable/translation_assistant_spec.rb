require 'spec_helper'
describe I18nRoutable::TranslationAssistant do

  subject { I18nRoutable }

  context '#convert_path_to_localized_regexp' do


    def convert path
      subject.convert_path_to_localized_regexp path
    end

    it 'should not segment sections that have no translations' do
      convert('/blogs').should eql ["/blogs", []]
      convert('/blogs/new').should eql ["/blogs/:i18n_new", ['new']]
    end

    it "should translate the components of a normal url" do
      convert("/posts").should eql ["/:i18n_posts", ["posts"]]
    end

    it "should translate the components of a glob url" do
      convert("/about").should eql ["/:i18n_about", ["about"]]
      convert("/about(/*anything)").should eql ["/:i18n_about(/*anything)", ["about"]]
    end

    it 'should respect optional arguments within optional arguments' do
      convert("posts/comments(/:users(/:individual))").should eql [":i18n_posts/:i18n_comments(/:users(/:individual))", ["posts", "comments"]]
      convert("posts/comments(/users(/:users))").should eql [":i18n_posts/:i18n_comments(/:i18n_users(/:users))", ["posts", "comments", "users"]]
    end

    it 'should preserve order' do
      convert("/posts/new").should eql ["/:i18n_posts/:i18n_new", ["posts", "new"]]
    end

    it "should ignore param names" do
      convert("/posts/:posts").should eql ["/:i18n_posts/:posts", ["posts"]]
      convert("/posts(/:id)(.:format)").should eql ["/:i18n_posts(/:id)(.:format)", ["posts"]]
      convert(':alias/events/:old_action').should eql [":alias/:i18n_events/:old_action", ["events"]]
    end

    it 'should double underscore dashes' do
      convert('all-the-posts(/:action(/:id))').should eql [":i18n_all__the__posts(/:action(/:id))", ["all-the-posts"]]
    end

    it "should only translate segments" do
      convert("/posts/more-posts").should eql ["/:i18n_posts/more-posts", ["posts"]]
      convert("/more-posts/posts").should eql ["/more-posts/:i18n_posts", ["posts"]]
    end
  end

  context '#route_constraint_for_segment' do

    def convert segment
      subject.send :route_constraint_for_segment, segment
    end

    before do
      I18n.stub(:available_locales).and_return %w{fr de nl au}
    end

    it 'should translate in the locales passed in to I18nRoutable' do
      convert("posts").should == /posts|puestos|messages/
    end

    it 'should regexp escape' do
      convert("ur.l").should == /ur\.l/
    end

    it 'should cgi escape' do
      convert("ur*l").should == /ur%2Al/
    end
  end

end
