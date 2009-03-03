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
    @user.update_attributes!(params[:user])
    redirect_to @user, :status => :see_other
  end
end