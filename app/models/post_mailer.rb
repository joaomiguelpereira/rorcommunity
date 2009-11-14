class PostMailer < ActionMailer::Base

  def send_post_notification_by_user(from_email,to_email, post_url, post_title)
    @subject    = post_title
    @body[:from_email] = from_email
    @body[:url] = post_url
    @recipients = to_email
    @from  = Configurations.sender_email
  end
end
