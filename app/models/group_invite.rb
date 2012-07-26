class GroupInvite
  include Mongoid::Document

  field :token, type: String

  embedded_in :user
  belongs_to :group

  after_create do |invite|
    InviteMailer.group_invite_email(invite.user.email, invite.group, invite.token).deliver
  end
end
