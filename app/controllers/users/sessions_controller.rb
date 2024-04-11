# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  skip_before_action :verify_signed_out_user

  respond_to :json

  # ! TODO: Refactor this later:
  # ? TODO: Add caching to this method because it gets called frequently during a session
  # ? TODO: Also, ensure that logging out will clear the cache
  # ? TODO: Also, ensure that cache's TTL is equal to auto-logout time
  def me
    if current_user
      render json: {
        status: { code: 200, message: 'Current user fetched.' },
        data: UserSerializer.new(current_user).serializable_hash[:data]
      }, status: :ok
    else
      render json: {
        status: { code: 401, message: "Couldn't find an active session." }
      }, status: :unauthorized
    end
  end

  private

  def respond_with(resource, _opts = {})
    render json: {
      status: { code: 200, message: 'Logged in successfully.' },
      data: UserSerializer.new(resource).serializable_hash[:data]
    }, status: :ok
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
