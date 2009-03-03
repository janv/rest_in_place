REST in Place
===========
                                    _______
                                   /       \
                                   | R.I.P.|
                                   |       |
                                   |       |
                                 -------------

REST in Place is an AJAX Inplace-Editor that talks to RESTful controllers.
It requires absolutely no additional server-side code if your controller
fulfills the following REST preconditions:

-   It uses the HTTP PUT method to update a record
-   It delivers an object in JSON form for requests with
    "Accept: application/javascript" headers

The editor works by PUTting the updated value to the server and GETting the
updated record afterwards to display the updated value.
That way any authentication methods or otherwise funky workflows in your
controllers are used for the inplace-editors requests.

URL: <http://github.com/janv/rest_in_place/>  
REPOSITORY:  <git://github.com/janv/rest_in_place.git>  
BLOG: <http://jan.varwig.org/projects/rest-in-place>

Instructions
============

First, install REST in Place with

    script/plugin install git://github.com/janv/rest_in_place.git

To use it, include either `rest_in_place.js`, `jquery.rest_in_place.js` or
`mootools.rest_in_place.js` in your template (_after_ loading your JavaScript
framework). `rest_in_place.js` is the version for the Prototype framework,
`jquery.rest_in_place.js` uses the [jQuery][] framework and `mootools.rest_in_place.js`
uses [mootools][].

For REST in Place to work with Rails request forgery protection, place the
following lines into your applications layout:

    <script type="text/javascript">
      rails_authenticity_token = '<%= form_authenticity_token %>'
    </script>

To make a piece of Text inplace-editable, wrap it into an element (a span
usually) with class "rest_in_place". The editor needs 3 pieces of information
to work: a URL, an object name and the attribute name. These are provided as
follows:

-   put attributes into the element, like this:
    
        <span class="rest_in_place" url="/users/1" object="user" attribute="name">
          <%= @user.name %>
        </span>
  
-   if any of these attributes is missing, DOM parents of the element are searched
    for them. That means you can write something like:
    
        <div object="user" url="/users/1">
          Name:  <span class="rest_in_place" attribute="name" ><%= @user.name %></span><br/>
          eMail: <span class="rest_in_place" attribute="email"><%= @user.email %></span>
        </div>
    
-   You can completely omit the url, to use the current document's url.
    With proper RESTful controllers this should always work, the explicit
    url-attribute is for cases when you want to edit a resource that is
    displayed as part of a non-RESTful webpage.
  
-   Rails provides the dom_id helper that constructs a dom id out of an
    ActiveRecord for you. So, your HTML page may look like this:
    
        <div id="<%= dom_id @user # == "user_1" %>">
          Name:  <span class="rest_in_place" attribute="name" ><%= @user.name %></span><br/>
          eMail: <span class="rest_in_place" attribute="email"><%= @user.email %></span>
        </div>
    
  REST in Place recognizes dom_ids of this form and derives the object parameter
  from them, so that (with the current documents url used) you really only need
  to provide the attributes name in most cases.
  
  !! --------  
  !! Note that a manually defined (in the element or in one of the parents)  
  !! object always overrides dom_id recognition.  
  !! --------

[jQuery]: http://www.jquery.com/
[mootools]: http://mootools.net/

Example
=======

Your routes.rb:

    map.resources :users
  
Your app/controllers/users_controller.rb:

    class UsersController < ApplicationController
      def show
        @user = User.find params[:id]
        respond_to do |type|
          type.html
          type.js {render :json => @user}
        end
      end

      def update
        @user = User.find params[:id]
        @user.update_attributes!(params[:user])
        redirect_to @user, :status => :see_other
      end
    end

Your app/views/users/show.html.erb:

    <html>
    <head>
        <%= javascript_include_tag "jquery-1.2.6.min" , "jquery.rest_in_place" %>
        <script type="text/javascript">
          rails_authenticity_token = '<%= form_authenticity_token %>'
        </script>
    </head>
    <body>
        <div id="<%= dom_id @user %>">
          ID: <%= @user.id %><br />
          Name: <span class="rest_in_place" attribute="name"><%= @user.name %></span>
        </div>
    </body> 
    </html>

You can run this example by switching to the testapp included in this
plugin, running script/server (sqlite3 required) and going to
localhost:3000/users/1

Hint:  
you need to set up the database first.
Copy and edit `testapp/config/database.yml.sample` accordingly.
If you don't want to use the included sqlite3 database, run `rake db:create`,
`rake db:schema:load` and `rake rest_in_place:create_sample` to create a test
dataset.


Non-Rails
=========

REST in Place was written for Ruby on Rails but is usable with any kind of
RESTful web api. Just include the rest_in_place.js in your webpage and follow
the instructions.

Participation
=============

I'd love to get comments, bug reports (or better, patches) about REST in Place.
I haven't set up a trac yet, so please use the project page at my blog
to contact me about REST in Place:
<http://jan.varwig.org/projects/rest-in-place>

Acknowledgements
================

Thanks to Kevin Valdek for the mootools version (commit 086b409d38932426540f402bb642c66165c78976)
and improvements to the testapp (commit 8eb121271345943588fe2a8467c790e7e37f3d7a).

Thanks to nando for commit 17ca4e3060a1420bf13d9b9d89ceeba2bcc144d2

Copyright (c) 2009 [Jan Varwig], released under the MIT license
