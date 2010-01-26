class UsersController < ApplicationController
  
  def index
    User.delete_all
    User.create! :name => "Frank",  :hobbies => "Fishing"
    User.create! :name => "Walter", :hobbies => "Walking"
    redirect_to User.first
  end
  
  def show
    @user = User.find params[:id]
    @user2 = User.find(:all)[1]
    respond_to do |type|
      type.html
      type.json {render :json => @user}
    end
  end

  def update
    @user = User.find params[:id]
    if @user.update_attributes!(params[:user])
      flash[:notice] = 'Person was successfully updated.'
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