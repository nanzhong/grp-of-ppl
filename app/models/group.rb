class Group
  include Mongoid::Document

  field :name, type: String
  field :description, type: String
  field :private, type: Boolean, default: false

  validates_presence_of :name

  has_and_belongs_to_many :users
  embeds_many :posts
  embeds_many :invitees

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
    invitees.each do |email|
      email.strip!

      next unless self.invitees.where(:email => email).empty? or self.users.where(:email => email).empty?

      now = Time.now
      token = Digest::MD5.hexdigest(now.to_s)
      
      self.invitees.create(:email => email, :token => token, :invited_at => now)
      User.where(:email => email).each do |user|
        invite = user.group_invites.build(:token => token)
        invite.group = self
        invite.save
      end

      InviteMailer.group_invite_email(email, self, token).deliver
    end
  end

  def invite_path(token)
    "/groups/#{self.id}/join/#{token}"
  end
end
