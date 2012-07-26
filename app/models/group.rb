class Group
  include Mongoid::Document

  field :name, type: String
  field :description, type: String
  field :private, type: Boolean, default: false

  validates_presence_of :name

  has_and_belongs_to_many :users
  embeds_many :posts
  embeds_many :invitees

  after_create do |group|
    data = { type: Post::Type::GROUP_BEGIN, 
             data: group.name }
    group.posts.create( created_at: Time.now,
                        data: [data].to_json )
  end

  def find_post(id)
    children = self.posts.where(:id => id)
    return children.first unless children.empty?

    to_search = []
    to_search += self.posts

    until to_search.empty?
      next_post = to_search.shift
      next if next_post.child_posts.empty?

      match = next_post.child_posts.where(:id => id)
      if match.empty?
        to_search += next_post.child_posts
      else
        return match.first
      end
    end
  end

  def invite(invitees)
    invited = []
    invitees.each do |email|
      email.strip!

      if self.invitees.where(:email => email).count > 0 ||
         self.users.where(:email => email).count > 0
        next
      end

      now = Time.now
      token = Digest::MD5.hexdigest(now.to_s)
      
      self.invitees.create(:email => email, :token => token, :invited_at => now)
      User.where(:email => email).each do |user|
        invite = user.group_invites.build(:token => token)
        invite.group = self
        invite.save

        # XXX see GroupInvite model
        PubSub.publish "users-#{invite.user.id}", 'invite-add', { :badge => invite.user.group_invites.count, :id => invite.id }
      end

      invited << email
    end

    if invited.count > 0
      invited_str = 
        if invited.count == 1
          invited.first
        else
          invited[0..-1].join(', ') + ', and ' + invited[-1]
        end

      post_data = [] << { type: Post::Type::USER_INVITE,
                          data: invited_str }

      self.posts.create( created_at: Time.now,
                          data: post_data.to_json )
    end
  end

  def invite_path(token)
    "/groups/#{self.id}/join/#{token}"
  end
end
