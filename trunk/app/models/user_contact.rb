class UserContact < ActiveRecord::Base

  def self.update_user_contact(user_id, emails)
    
    emails.each do |email|  
      contact = UserContact.find(:first, :conditions=>["user_id=? and contact_email=?",user_id,email])
      if contact.nil?
        contact = UserContact.new
        contact.contact_email = email
        contact.user_id = user_id
        contact.save
      end
    end
  end
  
  
end
