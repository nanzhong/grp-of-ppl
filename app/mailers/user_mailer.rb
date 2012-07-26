class UserMailer < ActionMailer::Base
  default :from => "no-reply@grpofppl.com", 
          :reply_to => "no-reply@grpofppl.com"

  def account_creation_email(user)
    @user = user
    mail(:to => @user.email, :subject => "You have created an account on grpofppl.com!")
  end

  def forgot_sign_in_email(user)
    @user = user
    mail(:to => @user.email, :subject => "Here's your sign in link to grpofppl.com")
  end

end
