# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  respond_to :json
  skip_before_action :authenticate_user!
  before_action :set_username, only: [:create]

  protected

  def set_username
    # TODO: Refactor this to be more Ruby-esque (i.e. use safe navigation operators):
    return unless params[:user] && params[:user][:email].present?

    params[:user][:username] = generate_username(params[:user][:email])
  end

  private

  def respond_with(resource, _opts = {})
    render json: UserSerializer.new(resource).serializable_hash and return if resource.persisted?

    # TODO: Refactor later on with a standardized error response pattern:
    render json: {
      status: { message: "User couldn't be created successfully. #{resource.errors.full_messages.to_sentence}" }
    }, status: :unprocessable_entity and return
  end

  # TODO: Refactor this into a DRYer method and use more Rails-y ways of writing the code (i.e. shorten it)
  def generate_username(email)
    username_base = email.split('@').first
    unique_username = "#{username_base}_#{SecureRandom.hex(9)}"

    # Ensure uniquity
    # Prevent infinite loops. Make 4 additional attempts (5th is a throwaway. Could be optimized to avoid entering 5th iteration):
    5.times do
      return unique_username unless User.exists?(username: unique_username)

      unique_username = "#{username_base}_#{SecureRandom.hex(9)}"
    end

    render json: {
      status: { message: "User couldn't be created successfully. Could not generate a unique username." }
    }, status: :unprocessable_entity
  end
end
