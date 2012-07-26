class GroupInvite
  include Mongoid::Document

  field :token, type: String

  embedded_in :user
  belongs_to :group
end
