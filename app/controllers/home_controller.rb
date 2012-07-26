class HomeController < ApplicationController

  def index
    unless @current_user.blank?
      redirect_to :controller => "groups", :action => "index"
    else 
      render :layout => "home"
    end
  end

  def new
    @user = User.new
    @group = Group.new
    @others = ""
  end

  def create
    @user = User.new(:email => params[:email])
    @group = Group.new(:name => params[:name])

    @others = params[:others_email]

    if @user.save
      sign_in_user @user

      @group.users.push @user
      if @group.save
        redirect_to @group
      else
        render action: "new"
      end
    else
      render action: "new"
    end
  end

end
