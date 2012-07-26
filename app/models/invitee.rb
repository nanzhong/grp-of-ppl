class Invitee
  include Mongoid::Document

  field :email, type: String
  field :token, type: String
  field :invited_at, type: DateTime

  embedded_in :group
end
