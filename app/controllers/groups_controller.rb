class GroupsController < ApplicationController

  before_filter :require_sign_in , :except => [:join]
  before_filter :group_from_id, :except => [:index, :new, :create]
  before_filter :member_of_group, :only => [:show, :edit, :update, :destroy, :show_reply, :hide_reply]
  before_filter :no_cache

  # GET /groups
  # GET /groups.json
  def index
    @groups = Group.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @groups }
    end
  end

  # GET /groups/1
  # GET /groups/1.json
  def show
    @posts = @group.posts.desc(:created_at).page(params[:page]).per(5)
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @group }
    end
  end

  # GET /groups/new
  # GET /groups/new.json
  def new
    @group = Group.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @group }
    end
  end

  # GET /groups/1/edit
  def edit
  end

  # POST /groups
  # POST /groups.json
  def create
    @group = Group.new(params[:group])
    @group.users.push @current_user
    
    respond_to do |format|
      if @group.save
        @group.invite params[:invite_emails].split(',')
        format.html { redirect_to @group, notice: 'Group was successfully created.' }
        format.json { render json: @group, status: :created, location: @group }
      else
        format.html { render action: "new" }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /groups/1
  # PUT /groups/1.json
  def update
    respond_to do |format|
      if @group.update_attributes(params[:group])
        @group.invite params[:invite_emails].split(',')

        format.html { redirect_to @group, notice: 'Group was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /groups/1
  # DELETE /groups/1.json
  def destroy
    @group.destroy

    respond_to do |format|
      format.html { redirect_to groups_url }
      format.json { head :no_content }
    end
  end

  def join
    invitee = @group.invitees.where(:token => params[:token])
    if invitee.empty?
      render 'invalid_invite'
    else
      unless @current_user.blank?
        invites = @current_user.group_invites.where(:token => params[:token])

        if invites.empty?
          render 'invalid_invite'
          return
        else
          invites.each do |invite|
            @current_user.group_invites.delete(invite)
          end

          @group.users.push @current_user
        end
      else 
        invitee = invitee.first
        @user = User.find_or_create_by(:email => invitee.email)
        sign_in_user @user

        @user.group_invites.where(:token => params[:token]).each do |invite|
          @user.group_invites.delete(invite)
        end

        @group.users.push @user
      end

      @group.invitees.where(:token => params[:token]).each do |invitee|
        @group.invitees.delete(invitee)
      end
      @group.save

      post_data = [] << { type: Post::Type::USER_JOIN,
                          data: @current_user.name }

      @post = @group.posts.create( created_at: Time.now,
                                 data: post_data.to_json )

      PubSub.publish "groups-#{@group.id}", 'new-post', { :html => render_to_string(:partial => 'posts/post', :locals => { :post => @post, :group => @group }) }

      redirect_to @group
    end
  end

  def show_reply
    @post = @group.find_post(params[:post_id])
  end

  private

  def group_from_id
    @group = Group.find(params[:id])
  end

  def member_of_group
    render "not_member" if @group.users.where(:email => @current_user.email).empty?
  end

  def no_cache
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end
end
