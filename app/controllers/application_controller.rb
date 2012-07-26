class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :authenticate

  protected 

  def authenticate
    @current_user = nil
    unless cookies[:auth_token].blank?
      user = User.where(:auth_token => cookies[:auth_token])
      unless user.empty?
        @current_user = user.first
      end
    end
  end

  def require_sign_in
    redirect_to root_path if @current_user.blank?
  end

  def sign_in_user(user)
    cookies[:auth_token] = { :value => user.auth_token, :expires => 10.days.from_now }
  end

  def redirect_to_back
    redirect_to session[:sign_in_return_to].blank? ? root_path : session[:sign_in_return_to]
  end
end
