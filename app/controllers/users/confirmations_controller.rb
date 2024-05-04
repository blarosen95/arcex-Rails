# frozen_string_literal: true

class Users::ConfirmationsController < Devise::ConfirmationsController
  skip_before_action :authenticate_user!
end
