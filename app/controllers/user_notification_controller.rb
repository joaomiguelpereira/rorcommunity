class UserNotificationController < ApplicationController
  
  
  def send_emails
    #get the emails
    emails = params[:email_content]
    sender_email = params[:my_email]
    post_id = params[:post_id]
    
    #don,t know how it works, but it works.,if remove it'll not work anymore
    email_array =  parse_emails(emails)
    post = Post.find(post_id)
    permalink = post.permalink
    post_title = post.title
    
    url = post_url(:permalink=>permalink)
    #verify if any user is logged
    if session[:logged_user]
      UserContact.update_user_contact(session[:logged_user],email_array)
    end
    
    if email_array.size() == 0 
      @summary = " <span style=\"color:#FF0000\">Nenhum dos emails que especificas-te &eacute; v&aacute;lido. <br/>Nenhum Email enviado.</span>"
    else
      
      @summary = "O link foi enviado por email com sucesso para:<br/>"
      count = 0
      email_array.each do |email|
        count +=1
        
        PostMailer.deliver_send_post_notification_by_user(sender_email,email,url,post_title)
        @summary << email
        if count < email_array.size()
          @summary << ", "
        end
      end
    end
    @summary << "<br/>"
    rescue
    @summary = " <span style=\"color:#FF0000\">Ocorreu um erro ao enviar os emails. <br/>Pedimos desculpa pelo inc&oacute;modo. Tentaremos resolver o problema com a maior brevidade poss&iacute;vel.<br/></span>"
    
  end
  
  def choose_recipients
    @user_id = params[:user_id]
    @post_id = params[:post_id]
    
    @my_email = "insere o teu email"
    if @user_id 
      @my_email = User.find(@user_id).email
    end
    
    @user_contacts = Array.new
    if @user_id
      contacts = UserContact.find(:all, :conditions=>["user_id=?",@user_id])
      if !contacts.nil?
        contacts.each do |contact|
           @user_contacts << {:contact_key=>"contact_key_#{contact.id}", :email=>contact.contact_email}
        end
      end
    end
      
  end
  
  private
  
  def parse_emails(str)
    emails_array = Array.new
    emails = str.split(/\s*,\s*/)
    emails.each do |single_str|
      my_str = String.new(single_str)
      #emails_array << single_str
      logger.info("verifying : "+my_str)
      #tmp = single_str[/^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i]  
      tmp = String.new()
      tmp = my_str[/^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i]
      
      #/^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
      #logger.info(tmp)
      if !tmp.nil? 
        logger.info("adding "+tmp)
        emails_array << tmp  
        
      end
      #single_str.end_regexp()
    end
    return emails_array
    
  end
end
