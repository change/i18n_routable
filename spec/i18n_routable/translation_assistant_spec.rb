# encoding: utf-8
require 'spec_helper'
describe I18nRoutable::TranslationAssistant do

  subject { I18nRoutable }

  let (:parser) { ActionDispatch::Journey::Parser.new }

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

    def converted_result_equals path, expected_results
      conversion = convert(path)
      conversion[0].should eql expected_results[0]

      conversion[1].should be_kind_of(ActionDispatch::Journey::Nodes::Node)
      conversion[1].to_s.should eql expected_results[1].to_s
      conversion[1].to_s.should eql expected_results[0]

      conversion[2].should eql expected_results[2]
    end


    it 'should not segment sections that have no translations' do
      converted_result_equals '/blogs', ["/blogs", parser.parse("/blogs"), {}]
      converted_result_equals '/blogs/new', ["/blogs/:i18n_new", parser.parse("/blogs/:i18n_new"), {i18n_new: /new|the\-new|neuvo|nouvelles/i}]
    end

    it "should translate the components of a normal url" do
      converted_result_equals "/posts", ["/:i18n_posts", parser.parse("/:i18n_posts"), {i18n_posts: /posts|puestos|messages/i}]
    end

    it "should translate the components of a glob url" do
      converted_result_equals "/about", ["/:i18n_about", parser.parse("/:i18n_about"), {i18n_about: /about|sobre/i}]
      converted_result_equals "/about(/*anything)", ["/:i18n_about(/*anything)", parser.parse("/:i18n_about(/*anything)"), {i18n_about: /about|sobre/i}]
    end

    it 'should respect optional arguments within optional arguments' do
      converted_result_equals "posts/comments(/:users(/:individual))", [":i18n_posts/:i18n_comments(/:users(/:individual))",
        parser.parse(":i18n_posts/:i18n_comments(/:users(/:individual))"),
        {i18n_posts: /posts|puestos|messages/i, i18n_comments: /comments|commentaires/i}]
      converted_result_equals "posts/comments(/users(/:users))", [":i18n_posts/:i18n_comments(/:i18n_users(/:users))",
        parser.parse(":i18n_posts/:i18n_comments(/:i18n_users(/:users))"),
        {i18n_posts: /posts|puestos|messages/i,
         i18n_comments: /comments|commentaires/i,
         i18n_users: /users|usuarios|utilisateurs|canada_utilisateurs/i}]
    end

    it 'should preserve order' do
      converted_result_equals "/posts/new", ["/:i18n_posts/:i18n_new",
        parser.parse("/:i18n_posts/:i18n_new"),
        {i18n_posts: /posts|puestos|messages/i, i18n_new: /new|the\-new|neuvo|nouvelles/i}]
    end

    it "should ignore param names" do
      converted_result_equals "/posts/:posts", ["/:i18n_posts/:posts",
        parser.parse("/:i18n_posts/:posts"),
       {i18n_posts: /posts|puestos|messages/i}]
      converted_result_equals "/posts(/:id)(.:format)", ["/:i18n_posts(/:id)(.:format)",
        parser.parse("/:i18n_posts(/:id)(.:format)"),
        {i18n_posts: /posts|puestos|messages/i}]
      converted_result_equals ':alias/events/:old_action', [":alias/:i18n_events/:old_action",
        parser.parse(":alias/:i18n_events/:old_action"),
        {i18n_events: /events|eventos|evenements/i}]
    end

    it 'should double underscore dashes' do
      converted_result_equals 'all-the-posts(/:action(/:id))', [":i18n_all__the__posts(/:action(/:id))",
        parser.parse(":i18n_all__the__posts(/:action(/:id))"),
        {i18n_all__the__posts: /all\-the\-posts|todos\-los\-puestos/i}]
    end

    it "should only translate segments" do
      converted_result_equals "/posts/more-posts", ["/:i18n_posts/more-posts",
        parser.parse("/:i18n_posts/more-posts"),
        {i18n_posts: /posts|puestos|messages/i}]
      converted_result_equals "/more-posts/posts", ["/more-posts/:i18n_posts",
        parser.parse("/more-posts/:i18n_posts"),
        {i18n_posts: /posts|puestos|messages/i}]
    end
  end


end
