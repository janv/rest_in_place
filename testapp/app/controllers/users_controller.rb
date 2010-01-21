class UsersController < ApplicationController
  
  def index
    User.create! :name => "Frank" unless User.first
    redirect_to User.first
  end
  
  def show
    @user = User.find params[:id]
    respond_to do |type|
      type.html
      type.js {render :json => @user}
    end
  end

  def update
    @user = User.find params[:id]
    if @user.update_attributes!(params[:user])
       flash[:notice] = 'Person was successfully updated.'
       format.html {redirect_to( @person )}
       format.json {render :nothing => true}
       # format.js    # update.js.erb
    else
      format.html {render :action => :edit} # edit.html.erb
      format.json {render :nothing => true}
      format.js   {render :action => :edit} # edit.js.erb
    end
  end
end