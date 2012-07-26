class Invitee
  include Mongoid::Document

  field :email, type: String
  field :token, type: String
  field :invited_at, type: DateTime

  embedded_in :group

  after_create do |invitee|
    InviteMailer.group_invite_email(invitee.email, invitee.group, invitee.token).deliver
  end
end
