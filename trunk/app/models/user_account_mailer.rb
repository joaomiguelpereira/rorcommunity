class UserAccountMailer < ActionMailer::Base
  
  def confirm_registration(user)
    url = url_for :host=>Configurations.host, :controller=>'user', :action=>'confirm_registration', :activation_key=>user.activation_key
    @subject    = 'Registo em Logo.com'
    @body[:user] = user
    @body[:url] = url
    @recipients = user.email
    @from  = Configurations.sender_email
  end
  
  
  def send_notification(user,notification)
    @subject    = 'Alerta'
    @body[:user] = user
    @body[:notif] = notification
    @recipients = user.email
    @from  = Configurations.sender_email
    
  end
  def reset_pwd(user)    
    
    url = url_for :host=>Configurations.host, :controller=>'user', :action=>'change_lost_password', :lostpass_key=>user.retrieve_pwd_key
    @subject    = 'Recuperar password'
    @body[:user] = user
    @body[:url] = url
    @recipients = user.email
    @from  = Configurations.sender_email
  end
end
