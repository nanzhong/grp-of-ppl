class InviteMailer < ActionMailer::Base
  default from: "no-reply@grpofppl.com"

  def group_invite_email(email, group, token)
    @group = group
    @token = token

    mail(:to => email, :subject => "You have been invited to #{@group.name}!")
  end
end
