class ApplicationController < ActionController::Base
  # ! TODO: Replace this line with a secure solution (slow to implement, so this is faster to write rn):
  skip_before_action :verify_authenticity_token

  before_action :authenticate_user!

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_current_user
  before_action :set_current_session

  # Should eventually be extended to return early if valid API token is present (possibly by signing in as that user, or by controlling token access levels at a granular level)
  def authenticate_user!
    return if current_user.present?

    # TODO: We should probably at least include the attempted action in the error message if not more. But revisit once we have an error logging platform in place (i.e. Sentry/Datadog):
    render_unauthorized! and return
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up) do |u|
      u.permit(
        :email,
        :password,
        :password_confirmation,
        :username
      )
    end
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

  def render_unauthorized!
    render json: { error: 'Unauthorized' }, status: :unauthorized
  end
end
