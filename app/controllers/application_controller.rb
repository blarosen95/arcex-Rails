class ApplicationController < ActionController::Base
  # ! TODO: Replace this line with a secure solution (slow to implement, so this is faster to write rn):
  skip_before_action :verify_authenticity_token

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_current_user
  before_action :set_current_session

  def configure_permitted_parameters
    # devise_parameter_sanitizer.permit('g-recaptcha-response')
    devise_parameter_sanitizer.permit(:sign_up) do |u|
      u.permit(
        :email,
        :password,
        :password_confirmation,
        :username
      )
    end
    # devise_parameter_sanitizer.permit(:sign_in) do |u|
    #   u.permit(
    #     :email,
    #     :password,
    #   )
    # end
    # devise_parameter_sanitizer.permit(:account_update) do |u|
    #   u.permit(
    #     :slug,
    #     :email,
    #     :name,
    #     :password,
    #     :password_confirmation,
    #     :current_password,
    #   )
    # end
  end

  def current_user
    return super if warden.authenticated?(scope: :user)

    Current.user || @current_user
  end

  def set_current_user
    Current.user ||= current_user
  end

  def set_current_session
    Current.session ||= request.session
  end
end
