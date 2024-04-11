module ApplicationHelper
  include Devise::Controllers::SignInOut
  include Devise::Controllers::StoreLocation

  def dynamic_reset_user_password_url(rpt)
    if Rails.env.development?
      reset_user_password_url(rpt:, port: 3000)
    else
      reset_user_password_url(rpt:)
    end
  end
end
