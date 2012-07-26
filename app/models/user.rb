class User
  include Mongoid::Document

  AUTH_KEY = "passwordsftl"

  field :email, :type => String, default: ""
  field :name, :type => String, default: -> { self.email }
  field :auth_token, :type => String, default: -> { Digest::SHA2.hexdigest(self.email + AUTH_KEY) }

  validates_presence_of :email
  validates_uniqueness_of :email, :name
 
  has_and_belongs_to_many :groups
  embeds_many :group_invites

  after_create do |user|
    UserMailer.account_creation_email(user).deliver
  end
end
