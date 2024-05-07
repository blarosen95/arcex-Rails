# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  skip_before_action :authenticate_user!
  skip_before_action :verify_signed_out_user

  respond_to :json

  # ! TODO: Refactor this later:
  # ? TODO: Add caching to this method because it gets called frequently during a session
  # ? TODO: Also, ensure that logging out will clear the cache
  # ? TODO: Also, ensure that cache's TTL is equal to auto-logout time
  def me
    render json: UserSerializer.new(current_user).serializable_hash and return if current_user

    # TODO: We really shouldn't need the `and return` here, but it's good practice since we have workflows that do render and continue (i.e. order book services):
    # TODO: Also, more importantly, we should create an error response pattern and use it as the default convention throughout the app instead of this longer format:
    render json: {
      status: { code: 401, message: "Couldn't find an active session." }
    }, status: :unauthorized and return
  end

  private

  def respond_with(resource, _opts = {})
    render json: UserSerializer.new(resource).serializable_hash and return
  end

  def respond_to_on_destroy
    if current_user
      render json: {
        status: 200,
        message: 'Logged out successfully.'
      }, status: :ok
    else
      render json: {
        status: 401,
        message: "Couldn't find an active session."
      }, status: :unauthorized
    end
  end
end
