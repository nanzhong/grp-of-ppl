class InviteMailer < ActionMailer::Base
  default from: "together@nan.enflick.com"

  def group_invite_email(email, group, token)
    @group = group
    @token = token

    mail(:to => email, :subject => "You have been invited to a group!")
  end
end
