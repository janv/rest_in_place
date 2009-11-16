class UsersController < ApplicationController
  
  def index
    begin
      redirect_to User.first
    rescue Exception
      raise "Seems like you haven't created any sample record. Please run: rake rest_in_place:create_sample"
    end
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