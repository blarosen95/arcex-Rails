class BaseMailer < ActionMailer::Base
    include ActionView::Helpers::TextHelper
    include ActionView::Helpers::DateHelper
    include ActionView::Helpers::AssetTagHelper
    include ActionView::Helpers::NumberHelper
    include MailerHelper
  
    SUPPORT_FROM = "ArcEx <#{SUPPORT_EMAIL}>"
    default from: ENV['MAILER_DELIVERY_TESTING'] ? ENV['SMTP_FROM'] : ENV['NO_REPLY_EMAIL']
  
    helper(ApplicationHelper)
    helper(MailerHelper)
  
    # class << self
      # def add_ses_info_to_record(message, record)
      #   record.ses_message_uid = message.message_id&.to_s&.email_address_local_part
      #   record.pending_emails = [message.to].flatten
      #   record.save
      # end
  
      # def create_new_email_record(message, email_record_params)
      #   email_record_params[:to] ||= message.to.to_a.flatten.join(', ')
      #   email_record_params[:cc] ||= message.cc.to_s
      #   email_record_params[:bcc] ||= message.bcc.to_s
      #   email_record_params[:subject] ||= message.subject.to_s
      #   email_record_params[:attachment_type] ||= :NO_ATTACHMENT
      #   email_record_params[:ses_statuses] = { pending: [email_record_params[:to]].flatten }.to_json
      #   email_record_params[:ses_message_uid] = message.message_id&.to_s&.email_address_local_part
      #   EmailRecord.create!(email_record_params)
      # end
  
      # def wait_for_bounces(_message, record)
      #   i = 0
      #   until !record.bounced_emails.blank? || record.pending_emails.blank? || i > 3
      #     sleep(0.5)
      #     i += 1
      #     record.reload
      #   end
  
      #   unless record.bounced_emails.blank?
      #     record.update(status: :ERROR)
      #     record.signer&.update_columns(status: 8) unless record.signer&.finalized_or_rejected?
      #     raise EmailDeliveryBouncedError,
      #       "Email delivery to #{record.bounced_emails.join(', ')} bounced.  Please verify the email address and retry."
      #   end
      # end
    # end
  end