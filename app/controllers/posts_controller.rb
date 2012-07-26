class PostsController < ApplicationController

  VALID_URI_REGEX = /(https?:\/\/[\S]+)/
  YOUTUBE_REGEX = /(?:https?:\/\/)?(?:www\.)?youtu(?:\.be|be\.com)\/(?:watch\?v=)?(\w{10,})/

  def create
    @group = Group.find(params[:group_id])

    post_data = parse_post(params[:post][:data])

    unless params[:parent_id].nil?
      @parent = @group.find_post(params[:parent_id])
      @post = @parent.child_posts.build(params[:post].merge({ :created_at => Time.now }), MessagePost)
      @post.data = post_data.to_json
      @post.user = @current_user

      @post.save

      render 'create_reply'
    else
      @post = MessagePost.new(params[:post])

      @post.created_at = Time.now
      @post.user = @current_user
      @post.data = post_data.to_json
      @post.group = @group

      @post.save

      render 'create'
    end
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
end
