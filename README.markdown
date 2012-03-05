# I18n Routable #

This is used to make your routes internationalized! It's a whole lot of code for only 1 public method!

## Interface and Options ##

```ruby
Rails.app.routes.draw do

  resources :users # not localized routes

  localize do # begin localized routes
    resources :posts do
      resources :comments
    end
  end

end
```

options to localize are:

  * :locales. This is an array of the locales to support
    * default - I18n.available_locales - I18n.default_locale
  * :locale_prefix. This specifies whether or not to prefix each routes with that locale. With locale_prefix => true, you'll have /posts and /es/puestos. With :locale_prefix => false, you'll have /posts and /puestos. Assuming an es locale.
    * default - true

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

assuming "en" is the default locale and 'es' is the other avaialable locale:

            NAME          VERB                         PATH                                        REQUIREMENTS
                   users GET    /users(.:format)                                   {:controller=>"users", :action=>"index"}
                         POST   /users(.:format)                                   {:controller=>"users", :action=>"create"}
                new_user GET    /users/new(.:format)                               {:controller=>"users", :action=>"new"}
               edit_user GET    /users/:id/edit(.:format)                          {:controller=>"users", :action=>"edit"}
                    user GET    /users/:id(.:format)                               {:controller=>"users", :action=>"show"}
                         PUT    /users/:id(.:format)                               {:controller=>"users", :action=>"update"}
                         DELETE /users/:id(.:format)                               {:controller=>"users", :action=>"destroy"}
           post_comments GET    /posts/:post_id/comments(.:format)                 {:controller=>"comments", :action=>"index"}
        es_post_comments GET    /es/puestos/:post_id/comments(.:format)            {:controller=>"comments", :action=>"index"}
                         POST   /posts/:post_id/comments(.:format)                 {:controller=>"comments", :action=>"create"}
                         POST   /es/puestos/:post_id/comments(.:format)            {:controller=>"comments", :action=>"create"}
        new_post_comment GET    /posts/:post_id/comments/new(.:format)             {:controller=>"comments", :action=>"new"}
     es_new_post_comment GET    /es/puestos/:post_id/comments/neuvo(.:format)      {:controller=>"comments", :action=>"new"}
       edit_post_comment GET    /posts/:post_id/comments/:id/edit(.:format)        {:controller=>"comments", :action=>"edit"}
    es_edit_post_comment GET    /es/puestos/:post_id/comments/:id/editar(.:format) {:controller=>"comments", :action=>"edit"}
            post_comment GET    /posts/:post_id/comments/:id(.:format)             {:controller=>"comments", :action=>"show"}
         es_post_comment GET    /es/puestos/:post_id/comments/:id(.:format)        {:controller=>"comments", :action=>"show"}
                         PUT    /posts/:post_id/comments/:id(.:format)             {:controller=>"comments", :action=>"update"}
                         PUT    /es/puestos/:post_id/comments/:id(.:format)        {:controller=>"comments", :action=>"update"}
                         DELETE /posts/:post_id/comments/:id(.:format)             {:controller=>"comments", :action=>"destroy"}
                         DELETE /es/puestos/:post_id/comments/:id(.:format)        {:controller=>"comments", :action=>"destroy"}
                   posts GET    /posts(.:format)                                   {:controller=>"posts", :action=>"index"}
                es_posts GET    /es/puestos(.:format)                              {:controller=>"posts", :action=>"index"}
                         POST   /posts(.:format)                                   {:controller=>"posts", :action=>"create"}
                         POST   /es/puestos(.:format)                              {:controller=>"posts", :action=>"create"}
                new_post GET    /posts/new(.:format)                               {:controller=>"posts", :action=>"new"}
             es_new_post GET    /es/puestos/neuvo(.:format)                        {:controller=>"posts", :action=>"new"}
               edit_post GET    /posts/:id/edit(.:format)                          {:controller=>"posts", :action=>"edit"}
            es_edit_post GET    /es/puestos/:id/editar(.:format)                   {:controller=>"posts", :action=>"edit"}
                    post GET    /posts/:id(.:format)                               {:controller=>"posts", :action=>"show"}
                 es_post GET    /es/puestos/:id(.:format)                          {:controller=>"posts", :action=>"show"}
                         PUT    /posts/:id(.:format)                               {:controller=>"posts", :action=>"update"}
                         PUT    /es/puestos/:id(.:format)                          {:controller=>"posts", :action=>"update"}
                         DELETE /posts/:id(.:format)                               {:controller=>"posts", :action=>"destroy"}
                         DELETE /es/puestos/:id(.:format)                          {:controller=>"posts", :action=>"destroy"}

## How do I use it in my codes? ##

For the most part, it should be invisible. Injected into your params hash you'll get a :locale attribute. This will be blank for the default locale. So I recommend this in an early before filter:

    I18n.locale = params[:locale] || I18n.default_locale

Now you're locale is setup. Let's say your locale is set to 'es', calling `posts_url` will behind the scenes call `es_posts_url`. You can override the locale by passing :locale to your url calls, such as `posts_url(:locale => 'en')`. To see a full list of options and rules, checkout the tests. But the idea is to never need to pass locale or worry about your routes.

## TESTING ##

Add `require 'i18n_routable/test_case'` to your test environment loader.

## FAQ ##

Q: What if I don't like the block syntax?
A: You can use the bang methods instead!

```ruby
Rails.app.routes.draw do
  localize!
  resources :posts
  delocalize!
end
```

Q: What support does i18n_routable have for Unicode ?
A: All routes are CGI escaped for support in browsers. Modern browsers will properly display unicode characters in the url.

Q: My routes output is now huge! Why do you make a new route for every locale?
A: We want to harnass the power of the rails router. So instead of rewriting a lot of the funcionality it provides, we just create more routes for you, and we do some magic to make sure the proper locale helper is called. We're also not doing any regular expression checking for locale support, so each route should be a bit faster.

Q: Can the default locale be prefixed with the locale?
A: The default locale cannot be prefixed.


## Thanks ##

A lot of ideas were taken from [https://github.com/kwi/i18n_routing](https://github.com/kwi/i18n_routing)

# LICENSE: [MIT](http://www.opensource.org/licenses/mit-license.php) #

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
