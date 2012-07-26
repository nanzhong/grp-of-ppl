class GroupInvite
  include Mongoid::Document

  field :token, type: String

  embedded_in :user
  belongs_to :group

=begin not working as expected for some reason? mongoid bug?
  after_create do |invite|
    GrpOfPpl::Push.publish "users-#{invite.user.id}", 'invite-add', { :badge => invite.user.group_invites.count, :id => invite.id }
  end

  after_destroy do |invite|
    GrpOfPpl::Push.publish "users-#{invite.user.id}", 'invite-del', { :badge => invite.user.group_invites.count, :id => invite.id }
  end
=end
end
