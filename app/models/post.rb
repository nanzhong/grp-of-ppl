class Post
  include Mongoid::Document

  module Type
    USER_IGNORE = -4
    USER_JOIN   = -3
    USER_INVITE = -2
    GROUP_BEGIN = -1

    TEXT    = 1
    LINK    = 2
    IMAGE   = 3
    YOUTUBE = 4
  end

  field :created_at,  type: DateTime
  field :data,        type: String
  field :post_data,   type: String

  embedded_in :group
  belongs_to :user
  recursively_embeds_many

  def nest_level
    level = 0
    post = self
    until post.parent_post.nil?
      level += 1
      post = post.parent_post
    end

    level
  end
end
