class PostsController < ApplicationController

  before_filter :require_sign_in , :except => [:permalink]
  before_filter :group_from_id
  before_filter :member_of_group, :only => [:create]

  VALID_URI_REGEX = /(https?:\/\/[\S]+)/
  YOUTUBE_REGEX = /(?:https?:\/\/)?(?:www\.)?youtu(?:\.be|be\.com)\/(?:watch\?v=)?(\w{10,})/

  def create
    post_data = parse_post(params[:post][:post_data])

    unless params[:parent_id].nil?
      @parent = @group.find_post(params[:parent_id])
      @post = @parent.child_posts.build(params[:post].merge({ :created_at => Time.now }))
      @post.data = post_data.to_json
      @post.user = @current_user

      @post.save

      render 'create_reply'
    else
      @post = Post.new(params[:post])

      @post.created_at = Time.now
      @post.user = @current_user
      @post.data = post_data.to_json
      @post.group = @group

      @post.save

      render 'create'
    end
  end

  def permalink
    @post = @group.posts.find(params[:post_id])

    render :layout => 'clean'
  end

  private 

  def parse_post(data)
    post_data = []

    tokens = data.split(VALID_URI_REGEX)

    tokens.each do |token|
      data_hash = {}
      if token =~ VALID_URI_REGEX
        if token =~ YOUTUBE_REGEX
          data_hash = { :data => token.match(YOUTUBE_REGEX)[1], :type => Post::Type::YOUTUBE }
        else
          begin
            response = HTTParty.get(token)
            if response.headers["content-type"] =~ /^image/
              data_hash = { :data => token, :type => Post::Type::IMAGE }
            else
              data_hash = { :data => token, :type => Post::Type::LINK }
            end
          rescue Exception => e
            data_hash = { :data => token, :type => Post::Type::LINK }
          end
        end
      else
        data_hash = { :data => token, :type => Post::Type::TEXT }
      end

      post_data << data_hash
    end

    post_data
  end

  def group_from_id
    @group = Group.find(params[:group_id])
  end

  def member_of_group
    render "/groups/not_member" if @group.users.where(:email => @current_user.email).empty?
  end
end
