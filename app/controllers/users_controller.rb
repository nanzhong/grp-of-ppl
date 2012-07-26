class UsersController < ApplicationController
  
  before_filter :require_sign_in
  before_filter :owner_of_user

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(params[:user])

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render json: @user, status: :created, location: @user }
      else
        format.html { render action: "new" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.json
  def update
    @user = User.find(params[:id])

    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :no_content }
    end
  end

  def sign_in
    users = User.where(:id => params[:user_id])
    if params[:token].blank? or users.empty?
      flash[:alert] = "Could not log into your account"
      redirect_to_back
    else
      @user = users.first
      if @user.auth_token == params[:token]
        sign_in_user @user

        redirect_to groups_path
      else
      end
    end
  end

  def sign_out
    cookies.delete :auth_token
    redirect_to_back
  end

  def accept_invite
    @user = User.find(params[:id])
    @invite = @user.group_invites.find_by(:token => params[:token])
    @invite.group.invitees.where(:token => params[:token]).each do |invitee|
      @invite.group.invitees.delete(invitee)
    end

    @invite.group.users.push @user

    @invite.delete
  end

   def ignore_invite
    @user = User.find(params[:id])
    @invite = @user.group_invites.find_by(:token => params[:token])
    @invite.group.invitees.where(:token => params[:token]).each do |invitee|
      @invite.group.invitees.delete(invitee)
    end
    @invite.delete
  end

  private
  def owner_of_user
    redirect_to root_path if @current_user.id != params[:id]
  end
end
