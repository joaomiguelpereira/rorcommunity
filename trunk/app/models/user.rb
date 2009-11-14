require 'digest/sha2'




class User < ActiveRecord::Base
  
  #has_many :user_images
  has_one :user_image
  has_many :user_tags
  
  
  #belongs_to :friendship ,:class_name=>"User", :foreign_key=>"friendship_id"
  #has_many :friends, :class_name=>"User", :foreign_key=>"friendship_id"
  
  
  #belongs_to :fanship ,:class_name=>"User", :foreign_key=>"fanship_id"
  #has_many :fans, :class_name=>"User", :foreign_key=>"fanship_id"
  
  
  #has_and_belongs_to_many :usernetworks
  has_one :usernetwork
  
  #has_and_belong_to_many :friends, :class_name=>"User", :foreign_key=>"friend_id"
  
  has_one :user_preference
  
  attr_accessor :password
  attr_accessor :session_persistent
  attr_accessor :agree
  
  attr_accessor :ordering
  
  attr_accessible :id, :email, :first_name, :last_name, 
  :screen_name, :password, 
  :password_confirmation, 
  :email_confirmation,
  :is_admin,
  :session_persistent,
  :password_hash,:password_salt,
  :agree,
  :profile_compteled
  
  
  
  
  #Create Validations
  validates_length_of :password, :minimum=>6, :message=>"A password &eacute; muito curta!"
  validates_length_of :screen_name, :maximum=>20, :message=> "A password &eacute; muito longa!"
  validates_presence_of :screen_name, :message=>"Falta o nome de utilizador!"  
  validates_presence_of :password, :on =>:create, :message=> "Falta a password!"
  validates_confirmation_of :email, :message=>"O email e a confirma&ccedil;&atilde;o n&atilde;o coincidem!"
  validates_confirmation_of :password, :message=>"A password e a confirma&ccedil;&atilde;o n&atilde;o coincidem!"
  validates_acceptance_of :agree, :message => "Tens de aceitar os termos!"
  validates_presence_of :email, :message=>"Falta o email!"
  #validates_format_of(:screen_name, 
  #                    :with => /\A[[:alpha:]][-_.[:alpha:]]{2,28}[[:alpha:]]\z/,
  #:on => :create, 
  #:message=>"O nome de Utilizador &eacute; inv&aacute;lido!")
  
  validates_length_of :screen_name, :minimum=>4, :message=>"O nome de utiizador tem de ter entre 4 e 15 caracteres"
  validates_length_of :screen_name, :maximum=>15, :message=>"O nome de utiizador tem de ter entre 4 e 15 caracteres"
  validates_format_of(:screen_name, 
                      :with => /\A(?:[a-z\d](?:[a-z\d_]*[a-z\d])?)(?:[a-z\d](?:[a-z\d-]*[a-z\d])?)(?:\.[a-z\d](?:[a-z\d-]*[a-z\d])?)*\Z/i,
  :on => :create, 
  :message=>"O nome de Utilizador &eacute; inv&aacute;lido!")
  
  
  
  validates_format_of(:email, 
                      :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, 
  :on => :create, 
  :message=>"O email tem um formato inv&aacute;lido!")
  #validates the uniqueness of email and screen name
  
  validates_uniqueness_of :email, :message=>"O email j&aacute; est&aacute; a ser utilizado!" 
  validates_uniqueness_of  :screen_name, :message=>"Esse nome de Utilizador j&aacute; est&aacute; a ser utilizado!" 
  
  
  #Update validators
  #validates_presence_of :first_name,:on=>:update
  #validates_presence_of :last_name, :on=>:update
  
  def password=(pass)
    salt = [Array.new(6) {rand(256).chr}.join].pack("m").chomp
    self.password_salt, self.password_hash =
    salt, Digest::SHA256.hexdigest(pass+salt) 
    
    @password=pass
  end
  
  def after_save
    @password = nil
    @confim_pasword = nil
  end
  
  #Autheticate using cookie
  def self.authenticate_with_cookie(user_id, user_password, user_password_salt)
    tmp_user = User.find(:first, :conditions=>['id = ? and password_hash=? and password_salt=?',user_id,user_password,user_password_salt])
    if tmp_user
      return true
    end
    return false
    
  end
  
  #Autheticate with Open ID
  def self.find_by_openid(identity_url)
    user = User.find(:first, :conditions=>["open_id_url=?",identity_url])
    user
   end
  
  #Authenticate a user
  def self.authenticate(email, password)
    user = User.find(:first, :conditions => ['email = ?', email])
    
    if user.blank? || 
      Digest::SHA256.hexdigest(password+ user.password_salt) != user.password_hash      
      
      raise "UserName or password invalid"
    end
    user    
  end
  
  def self.get_user_name(user_id)
    user = User.find(user_id)
    return user.screen_name 
  end
  def self.get_id_from_scren_name(screen_name)
    user = User.find(:first, :conditions=>["screen_name = ?",screen_name])
    if user.nil?
      return nil
    end
    
    return user.id
    
  end
  
  
end
