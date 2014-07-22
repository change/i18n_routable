# encoding: utf-8
require 'spec_helper'
describe I18nRoutable::TranslationAssistant do

  subject { I18nRoutable }

    before do
      I18nRoutable.localizing!
    end

    after do
      I18nRoutable.not_localizing!
    end

  context '#convert_path_to_localized_regexp' do

    def convert path
      subject.convert_path_to_localized_regexp path
    end

    it 'should not segment sections that have no translations' do
      convert('/blogs').should eql ["/blogs", {}]
      convert('/blogs/new').should eql ["/blogs/:i18n_new", {i18n_new: /new|the\-new|neuvo|nouvelles/i}]
    end

    it "should translate the components of a normal url" do
      convert("/posts").should eql ["/:i18n_posts", {i18n_posts: /posts|puestos|messages/i}]
    end

    it "should translate the components of a glob url" do
      convert("/about").should eql ["/:i18n_about", {i18n_about: /about|sobre/i}]
      convert("/about(/*anything)").should eql ["/:i18n_about(/*anything)", {i18n_about: /about|sobre/i}]
    end

    it 'should respect optional arguments within optional arguments' do
      convert("posts/comments(/:users(/:individual))").should eql [":i18n_posts/:i18n_comments(/:users(/:individual))",
        {i18n_posts: /posts|puestos|messages/i, i18n_comments: /comments|commentaires/i}]
      convert("posts/comments(/users(/:users))").should eql [":i18n_posts/:i18n_comments(/:i18n_users(/:users))",
        {i18n_posts: /posts|puestos|messages/i,
         i18n_comments: /comments|commentaires/i,
         i18n_users: /users|usuarios|utilisateurs|canada_utilisateurs/i}]
    end

    it 'should preserve order' do
      convert("/posts/new").should eql ["/:i18n_posts/:i18n_new",
        {i18n_posts: /posts|puestos|messages/i, i18n_new: /new|the\-new|neuvo|nouvelles/i}]
    end

    it "should ignore param names" do
      convert("/posts/:posts").should eql ["/:i18n_posts/:posts",
       {i18n_posts: /posts|puestos|messages/i}]
      convert("/posts(/:id)(.:format)").should eql ["/:i18n_posts(/:id)(.:format)",
        {i18n_posts: /posts|puestos|messages/i}]
      convert(':alias/events/:old_action').should eql [":alias/:i18n_events/:old_action",
        {i18n_events: /events|eventos|evenements/i}]
    end

    it 'should double underscore dashes' do
      convert('all-the-posts(/:action(/:id))').should eql [":i18n_all__the__posts(/:action(/:id))",
        {i18n_all__the__posts: /all\-the\-posts|todos\-los\-puestos/i}]
    end

    it "should only translate segments" do
      convert("/posts/more-posts").should eql ["/:i18n_posts/more-posts",
        {i18n_posts: /posts|puestos|messages/i}]
      convert("/more-posts/posts").should eql ["/more-posts/:i18n_posts",
        {i18n_posts: /posts|puestos|messages/i}]
    end
  end


end
