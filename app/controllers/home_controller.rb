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
    @group = Group.new(:name => params[:name], :description => params[:description])

    @others = params[:others_email]

    if @user.save
      sign_in_user @user

      @group.users.push @user
      if @group.save
        @group.invite params[:invite_emails].split(',')
        redirect_to @group
      else
        render action: "new"
      end
    else
      render action: "new"
    end
  end

  def forgot
    @user = User.where(:email => params[:email].strip)
    if @user.empty?
      flash[:alert] = "We can't find an account with that email... :'("
      redirect_to root_path
    else
      @user.each do |user|
        UserMailer.forgot_sign_in_email(user).deliver
      end

      flash[:notice] = "The link was sent! Check your email. ;)"
      redirect_to root_path
    end
  end

end
