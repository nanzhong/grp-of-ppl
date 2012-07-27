class UsersController < ApplicationController
  
  before_filter :require_sign_in, :except => [:sign_in]
  before_filter :owner_of_user, :except => [:sign_in]

  # GET /users/1
  # GET /users/1.json
  def show
    @user = User.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user }
    end
  end

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
    @user = User.find(params[:user_id])
    @invite = @user.group_invites.find_by(:token => params[:token])
    @invitees = @invite.group.invitees.where(:token => params[:token])
    @invitees.each do |invitee|
      @invite.group.invitees.delete(invitee)
    end

    @invite.group.users.push @user

    @invite.delete

    data = [] << { type: Post::Type::USER_JOIN,
                        data: @user.name }

    @post = @invite.group.posts.create( created_at: Time.now,
                                        data: data.to_json,
                                        post_data: data.to_json )

    # XXX see GroupInvite model
    PubSub.publish "users-#{@invite.user.id}", 'invite-del', { :badge => @invite.user.group_invites.count, :id => @invite.id }
    @invitees.each do |invitee|
      PubSub.publish "groups-#{@invite.group.id}", 'user-join', { :id => invitee.id }
    end
  end

   def ignore_invite
    @user = User.find(params[:user_id])
    @invite = @user.group_invites.find_by(:token => params[:token])
    @invitees = @invite.group.invitees.where(:token => params[:token])
    @invitees.each do |invitee|
      @invite.group.invitees.delete(invitee)
    end
    @invite.delete

    data = [] << { type: Post::Type::USER_IGNORE,
                        data: @user.name }

    @post = @invite.group.posts.create( created_at: Time.now,
                                        data: data.to_json,
                                        post_data: data.to_json )

    # XXX see GroupInvite model
    PubSub.publish "users-#{@invite.user.id}", 'invite-del', { :badge => @invite.user.group_invites.count, :id => @invite.id }
    @invitees.each do |invitee|
      PubSub.publish "groups-#{@invite.group.id}", 'user-ignore', { :id => invitee.id }
    end
  end

  def show_invite
    @user = User.find(params[:user_id])
    @invite = @user.group_invites.where(:id => params[:invite_id])

    if @invite.empty?
      render :nothing
      return
    end

    @invite = @invite.first
  end

  private
  def owner_of_user
    redirect_to root_path unless (@current_user.id.to_s == params[:id] or @current_user.id.to_s == params[:user_id] )
  end
end
