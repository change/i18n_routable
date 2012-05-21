require 'spec_helper'
# describe I18nRoutable::Mapper::LocalizableRoute do

#   subject { Class.new { include I18nRoutable::Mapper::LocalizableRoute }.new}

#   context '#translated_path' do

#     before do
#       @old_config = I18nRoutable.localize_config
#       I18nRoutable.localize_config = {}
#     end

#     after do
#       I18nRoutable.localize_config = @old_config
#     end

#     def t path, locale
#       subject.send(:translated_path, path, locale)
#     end

#     it "should translate the components of a normal url" do
#       t("/posts", :es).should eql "/puestos"
#       t("/posts/new", :fr).should eql "/messages/nouvelles"
#     end

#     it "should ignore param names" do
#       t("/posts/:posts", :es).should eql "/puestos/:posts"
#       t("/posts(/:id)(.:format)", :es).should eql "/puestos(/:id)(.:format)"
#       t('all-the-posts(/:action(/:id))', :es).should eql 'todos-los-puestos(/:action(/:id))'
#       t(':alias/events/:old_action', :fr).should eql ":alias/evenements/:old_action"
#     end

#     it "replace the entire component or none of it" do
#       t("/more-posts", :es).should eql "/more-posts"
#       t("/posts/more-posts", :es).should eql "/puestos/more-posts"
#       t("/more-posts/posts", :es).should eql "/more-posts/puestos"
#     end

#   end

# end
