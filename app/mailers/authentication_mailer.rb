class AuthenticationMailer < Devise::Mailer
    include Devise::Controllers::UrlHelpers
    default from: ENV['MAILER_DELIVERY_TESTING'] ? ENV['SMTP_FROM'] : "ArcEx Support <#{ENV['NO_REPLY_EMAIL']}>"
    layout 'mailer_v5'
  
    def send_confirmation_instructions(authentication, user)
      @user = user
      @authentication = authentication
      @show_do_not_share_message = true
      headers['arcex-notification-type'] = 'user-confirmation-instructions'
      make_bootstrap_mail(to: authentication.email, subject: 'Email Confirmation Instructions')
    end
  
    def reset_password_instructions(resource, token, _opts = {})
      @resource = resource
      @token = token
      headers['arcex-notification-type'] = 'user-reset-password-instructions'
      make_bootstrap_mail(to: @resource.email, subject: 'Reset Password Instructions')
    end
  
    def password_updated(resource)
      @resource = resource
      headers['arcex-notification-type'] = 'user-password-updated'
      make_bootstrap_mail(to: @resource.email, subject: 'ArcEx Password Changed')
    end
  
    def confirmation_instructions(resource, token, _opts = {})
      @resource = resource
      @token = token
      headers['arcex-notification-type'] = 'user-confirmation-instructions'
      make_bootstrap_mail(to: @resource.email, subject: 'Confirmation Instructions')
    end
  
    # send account recovery instructions to alternate email
    def account_recovery_instructions(owner_id, alternate_email, token)
      headers['arcex-notification-type'] = 'account-recovery-instructions'
      @owner = User.find(owner_id)
      @alternate_email = alternate_email
      @title = 'ArcEx account recovery processed'
      @token = token
      make_bootstrap_mail(to: @alternate_email, subject: 'ArcEx account recovery processed')
    end
  
    # send account recovery initiated information to owner
    def account_recovery_request_owner(owner_id, alternate_email)
      headers['arcex-notification-type'] = 'account-recovery-request-owner'
      @owner = User.find(owner_id)
      @alternate_email = alternate_email
      @title = 'ArcEx account recovery initiated'
      @manage_account_recovery_url =
        add_params_to_url(
          "#{ENV['DOMAIN']}settings/account-recovery",
          utm_source: 'Account Recovery',
          login_hint: @owner.email,
        )
      make_bootstrap_mail(to: @owner.email, subject: 'ArcEx account recovery initiated')
    end
  
    # send account recovery initiated information to alternate email
    def account_recovery_request_recipient(owner_id, alternate_email)
      headers['arcex-notification-type'] = 'account-recovery-request-recipient'
      @owner = User.find(owner_id)
      @alternate_email = alternate_email
      @title = 'ArcEx account recovery initiated'
      make_bootstrap_mail(to: @alternate_email, subject: 'ArcEx account recovery initiated')
    end
  end