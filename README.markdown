# I18n Routable #

[![Build Status](https://secure.travis-ci.org/change/i18n_routable.png?branch=master)](http://travis-ci.org/change/i18n_routable)

This is used to make your routes internationalized! It's a whole lot of code for only 1 public method!

## Compatibility ##

:exclamation: This gem is only compatible with Rails versions >= 4.2.

## Changes Since Rails 3.x ##

I18nRoutable::TranslationAssistant#convert_path_to_localized_regexp now returns an array of three items instead of two. It returns the path as a string, the parsed path represented by a Journey node, and the requirements. This was to comply with the changes to the ActionDispatch module in 4.2.

## Interface and Options ##

```ruby
Rails.app.routes.draw do

  localize! :locales => [:es, :fr]
  regexp = I18nRoutable.display_locales.join "|"
  regexp = /#{regexp}/
  scope "(:locale)", :locale => regexp do

    resources :blogs # no translations

    resources :posts do
      resources :comments
    end

  end

end
```

options to localize are:

  * :locales. This is an array of the locales to support
    * default - I18n.available_locales - I18n.default_locale

## Translating the routes ##

All you need to do is have your I18n backend be able to translate each route segment (such as "posts", "comments", "new", "edit", etc..) within a route scope.
Here's an example yaml file assuming es and fr locales:

    es:
      routes:
        new: neuvo
        edit: editar
        posts: puestos
        comments: comentarios
    fr:
      routes:
        new: nouvelles
        edit: modifier
        posts: messages
        comments: commentaires


## What routes does this make ##

assuming "en" is the default locale and the other avaialable locales are 'es' and 'fr':

            NAME          VERB                         PATH                                        REQUIREMENTS
    post_comments GET    (/:locale)/:i18n_posts/:post_id/:i18n_comments(.:format)                {:i18n_posts=>/puestos|messages/, :i18n_comments=>/comments|commentaires/, :locale=>/es|fr/, :action=>"index", :controller=>"comments"}
                  POST   (/:locale)/:i18n_posts/:post_id/:i18n_comments(.:format)                {:i18n_posts=>/puestos|messages/, :i18n_comments=>/comments|commentaires/, :locale=>/es|fr/, :action=>"create", :controller=>"comments"}
 new_post_comment GET    (/:locale)/:i18n_posts/:post_id/:i18n_comments/:i18n_new(.:format)      {:i18n_posts=>/puestos|messages/, :i18n_comments=>/comments|commentaires/, :i18n_new=>/neuvo|nouvelles/, :locale=>/es|fr/, :action=>"new", :controller=>"comments"}
edit_post_comment GET    (/:locale)/:i18n_posts/:post_id/:i18n_comments/:id/:i18n_edit(.:format) {:i18n_posts=>/puestos|messages/, :i18n_comments=>/comments|commentaires/, :i18n_edit=>/editar|modifier/, :locale=>/es|fr/, :action=>"edit", :controller=>"comments"}
     post_comment GET    (/:locale)/:i18n_posts/:post_id/:i18n_comments/:id(.:format)            {:i18n_posts=>/puestos|messages/, :i18n_comments=>/comments|commentaires/, :locale=>/es|fr/, :action=>"show", :controller=>"comments"}
                  PUT    (/:locale)/:i18n_posts/:post_id/:i18n_comments/:id(.:format)            {:i18n_posts=>/puestos|messages/, :i18n_comments=>/comments|commentaires/, :locale=>/es|fr/, :action=>"update", :controller=>"comments"}
                  DELETE (/:locale)/:i18n_posts/:post_id/:i18n_comments/:id(.:format)            {:i18n_posts=>/puestos|messages/, :i18n_comments=>/comments|commentaires/, :locale=>/es|fr/, :action=>"destroy", :controller=>"comments"}
            posts GET    (/:locale)/:i18n_posts(.:format)                                        {:i18n_posts=>/puestos|messages/, :locale=>/es|fr/, :action=>"index", :controller=>"posts"}
                  POST   (/:locale)/:i18n_posts(.:format)                                        {:i18n_posts=>/puestos|messages/, :locale=>/es|fr/, :action=>"create", :controller=>"posts"}
         new_post GET    (/:locale)/:i18n_posts/:i18n_new(.:format)                              {:i18n_posts=>/puestos|messages/, :i18n_new=>/neuvo|nouvelles/, :locale=>/es|fr/, :action=>"new", :controller=>"posts"}
        edit_post GET    (/:locale)/:i18n_posts/:id/:i18n_edit(.:format)                         {:i18n_posts=>/puestos|messages/, :i18n_edit=>/editar|modifier/, :locale=>/es|fr/, :action=>"edit", :controller=>"posts"}
             post GET    (/:locale)/:i18n_posts/:id(.:format)                                    {:i18n_posts=>/puestos|messages/, :locale=>/es|fr/, :action=>"show", :controller=>"posts"}
                  PUT    (/:locale)/:i18n_posts/:id(.:format)                                    {:i18n_posts=>/puestos|messages/, :locale=>/es|fr/, :action=>"update", :controller=>"posts"}
                  DELETE (/:locale)/:i18n_posts/:id(.:format)                                    {:i18n_posts=>/puestos|messages/, :locale=>/es|fr/, :action=>"destroy", :controller=>"posts"}
            blogs GET    (/:locale)/blogs(.:format)                                              {:locale=>/es|fr/, :action=>"index", :controller=>"blogs"}
                  POST   (/:locale)/blogs(.:format)                                              {:locale=>/es|fr/, :action=>"create", :controller=>"blogs"}
         new_blog GET    (/:locale)/blogs/:i18n_new(.:format)                                    {:i18n_new=>/neuvo|nouvelles/, :locale=>/es|fr/, :action=>"new", :controller=>"blogs"}
        edit_blog GET    (/:locale)/blogs/:id/:i18n_edit(.:format)                               {:i18n_edit=>/editar|modifier/, :locale=>/es|fr/, :action=>"edit", :controller=>"blogs"}
             blog GET    (/:locale)/blogs/:id(.:format)                                          {:locale=>/es|fr/, :action=>"show", :controller=>"blogs"}
                  PUT    (/:locale)/blogs/:id(.:format)                                          {:locale=>/es|fr/, :action=>"update", :controller=>"blogs"}
                  DELETE (/:locale)/blogs/:id(.:format)                                          {:locale=>/es|fr/, :action=>"destroy", :controller=>"blogs"}

## How do I use it in my codes? ##

For the most part, it should be invisible. Injected into your params hash you'll get a :locale attribute. This will be blank for the default locale. So I recommend this in an early before filter:

    I18n.locale = params[:locale] || I18n.default_locale

Now you're locale is setup. Let's say your locale is set to 'es', calling `posts_url` will behind the scenes call `es_posts_url`. You can override the locale by passing :locale to your url calls, such as `posts_url(:locale => 'en')`. To see a full list of options and rules, checkout the tests. But the idea is to never need to pass locale or worry about your routes.

## FAQ ##

Q: What if I don't like the scoping with the locale
A: Then don't.

Q: What support does i18n_routable have for Unicode ?
A: All routes are CGI escaped for support in browsers. Modern browsers will properly display unicode characters in the url.

Q: Can the default locale be prefixed with the locale?
A: Yes. But you'd have to change the regexp from the one described above.

Q: What if I want to show the users a different locale than what I store it in the backend?

~~A: That's easy, just pass a hash as an array item in your localize call such as~~

:x: `ruby localize! :locales => [{:display_name => :locale}, {:second_display => :second_locale}, :locale3, :locale4]`

A: Support for this has been removed due to incompatibility with the upgrade to Rails 4.2.

## Thanks ##

A lot of ideas were taken from [https://github.com/kwi/i18n_routing](https://github.com/kwi/i18n_routing)

# LICENSE: [MIT](http://www.opensource.org/licenses/mit-license.php) #

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
