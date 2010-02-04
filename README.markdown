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
    "Accept: application/json" headers

The editor works by PUTting the updated value to the server and GETting the
updated record afterwards to display the updated value.
That way any authentication methods or otherwise funky workflows in your
controllers are used for the inplace-editors requests.

URL:         <http://github.com/janv/rest_in_place/>  
REPOSITORY:  git://github.com/janv/rest_in_place.git
BLOG:        <http://jan.varwig.org/projects/rest-in-place>

Installation
============

First, install REST in Place with

    script/plugin install git://github.com/janv/rest_in_place.git

To use it, include `jquery.rest_in_place.js` in your template and execute the
following in your document's onLoad handler:

    jQuery(".rest_in_place").rest_in_place();


Other JS Frameworks
===================

Besides the [jQuery][] version, this repository also includes a [mootools][]
and a [Prototype][] version (`rest_in_place.js` and `mootols.rest_in_place.js`
respectively).

REST in Place originally was a mere proof of concept, written in jQuery and
Prototype. I haven't touched it much in a while, but it apparently proved
useful to a lot of people and I want to develop it more actively in the future.
Unfortunately I never work with neither mootools nor Prototype, so I can only
improve the jQuery version of the plugin.

I will happily include contributions for the other versions, but I won't
develop them on my own.

[jQuery]: http://www.jquery.com/
[mootools]: http://mootools.net/
[Prototype]: http://www.prototypejs.org/

Rails Request forgery Protection
================================

For REST in Place to work with Rails request forgery protection, place the
following lines into your applications layout:

    <script type="text/javascript">
      rails_authenticity_token = '<%= form_authenticity_token %>'
    </script>

Usage Instructions
==================

To make a piece of Text inplace-editable, wrap it into an element (a span
usually) with class "rest_in_place". The editor needs 3 pieces of information
to work: a URL, an object name and the attribute name. These are provided as
follows:

-   put attributes into the element, like this:
    
        <span class="rest_in_place" data-url="/users/1" data-object="user" data-attribute="name">
          <%= @user.name %>
        </span>
  
-   if any of these attributes is missing, DOM parents of the element are searched
    for them. That means you can write something like:
    
        <div data-object="user" data-url="/users/1">
          Name:  <span class="rest_in_place" data-attribute="name" ><%= @user.name %></span><br/>
          eMail: <span class="rest_in_place" data-attribute="email"><%= @user.email %></span>
        </div>
    
-   You can completely omit the url to use the current document's url.
    With proper RESTful controllers this should always work, the explicit
    url-attribute is for cases when you want to edit a resource that is
    displayed as part of a non-RESTful webpage.
  
-   Rails provides the dom_id helper that constructs a dom id out of an
    ActiveRecord for you. So, your HTML page may look like this:
    
        <div id="<%= dom_id @user # == "user_1" %>">
          Name:  <span class="rest_in_place" data-attribute="name" ><%= @user.name %></span><br/>
          eMail: <span class="rest_in_place" data-attribute="email"><%= @user.email %></span>
        </div>
    
    REST in Place recognizes dom_ids of this form and derives the object parameter
    from them, so that (with the current documents url used) you really only need
    to provide the attributes name in most cases.
   
    **Note that a manually defined (in the element or in one of the parents)  
    object always overrides dom_id recognition.**

-   REST in Place supports multiple form types. The default type is a input
    field, a textarea is also supported. To select a form type use the
    `data-formtype` attribute in the element and set it to the name of your
    formtype ( `input`, or `textarea` ).
    
    To write your own form types, just extend the `RestInPlace.forms` object
    and select your new form type throught the `data-formtype` attribute.
    
    **This feature is only supported in the jQuery version.**

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
          type.json {render :json => @user}
        end
      end

      def update
        @user = User.find params[:id]
        if @user.update_attributes!(params[:user])
          respond_to do |format|
            format.html { redirect_to( @person )  }
            format.json { render :nothing =>  true }
          end
        else
          respond_to do |format|
            format.html { render :action  => :edit } # edit.html.erb
            format.json { render :nothing =>  true }
          end
        end
      end
    end

Your app/views/users/show.html.erb:

    <html>
    <head>
      <%= javascript_include_tag "jquery-1.4.min" , "jquery.rest_in_place" %>
      <script type="text/javascript">
        rails_authenticity_token = '<%= form_authenticity_token %>'
        jQuery(function(){
          jQuery(".rest_in_place").rest_in_place();
        });
      </script>
    </head>
    <body>
      <div id="<%= dom_id @user %>">
        ID: <%= @user.id %><br />
        Name: <span class="rest_in_place" data-formtype="input" data-attribute="name"><%= @user.name %></span><br/><br/>
        Hobbies: <span class="rest_in_place" data-formtype="textarea" data-attribute="hobbies"><%= @user.hobbies %></span>
      </div>
    </body> 
    </html>

You can run this example by running to the testapp included in this
plugin with script/server (sqlite3 required) and visiting
localhost:3000/users/

Hint:  
you need to set up the database first.
Copy and edit `testapp/config/database.yml.sample` accordingly.
If you don't want to use the included sqlite3 database, run `rake db:create`
and `rake db:schema:load`.

Troubleshooting
===============

REST in Place is very picky about correct headers and formatting.
If you experience errors, please make sure your controller sends responses as
properly formatted JSON with the correct MIME-Type "application/json".

Non-Rails
=========

REST in Place was written for Ruby on Rails but is usable with any kind of
RESTful web api. You should be able to adapt the instructions above to your
framework easily.

Participation
=============

I'd love to get comments, bug reports (or better, patches) about REST in Place.
For this, you can either fork the project and send a pull request, or submit a
bug in the tracker at github: <http://github.com/janv/rest_in_place/issues>

For general comments and questions, please use the comment function on my blog:
<http://jan.varwig.org/projects/rest-in-place>

Acknowledgements
================

Thanks to Kevin Valdek for the mootools version (commit 086b409d38932426540f402bb642c66165c78976)
and improvements to the testapp (commit 8eb121271345943588fe2a8467c790e7e37f3d7a).

Thanks to nando for commit 17ca4e3060a1420bf13d9b9d89ceeba2bcc144d2

Copyright (c) 2010 [Jan Varwig], released under the MIT license
