require "openid"
class OpenidsessionController < BaseController
  include OpenIdAuthentication
  def new
    render :text=>"NEW"
  end
  
  
  def account_created
    user_id = params[:user_id]
    @user = User.find(:first, :conditions=>["id=?",user_id])
    
    if @user.nil?
      
      redirect_to "/"
      return
    end
    
  end
  
  def create_account_from_openid
    email = params[:email]
    screen_name = params[:user_screenname]
    openid = params[:openid]
    password = generate_pass
    @screen_name_error = nil 
    @has_errors = false
    #verify the screen_name
    # /\A(?:[a-z\d](?:[a-z\d_]*[a-z\d])?)(?:[a-z\d](?:[a-z\d-]*[a-z\d])?)(?:\.[a-z\d](?:[a-z\d-]*[a-z\d])?)*\Z/i
    
    if screen_name[/\A(?:[a-z\d](?:[a-z\d_]*[a-z\d])?)(?:[a-z\d](?:[a-z\d-]*[a-z\d])?)(?:\.[a-z\d](?:[a-z\d-]*[a-z\d])?)*\Z/i].nil?
      @screen_name_error = "O formato do nome de utilizador &eacute; inv&aacute;lido!"  
      @has_errors = true
    end
    
    #verify if the user name is already registered
    
    if (User.find(:first, :conditions=>["screen_name=?",screen_name]))
      @screen_name_error = "J&aacute; existe um membro Blorkut registado com esse nome de utiliazador!!"  
      @has_errors = true
    end
    
    
    #verify if there is anyt user with the same email
    if (User.find(:first, :conditions=>["email=?",email]))
      @email_error = "J&aacute; existe um membro Blorkut registado com esse email!!"
      @has_errors = true
    end
    
    
    if email[/^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i].nil?
      @email_error =  "O formato do email &eacute; inv&aacute;lido!"
      @has_errors = true
    end
    
    
    if !@has_errors
      @user = User.new
      @user.email = email
      @user.email_confirmation = email
      @user.screen_name = screen_name
      @user.open_id_url = openid
      @user.password = password
      @user.password_confirmation = password
      @user.is_active = 1
      @user.activated_at = Time.now()
      @user.profile_compteled = 0
      @user.gmap_zoom_level = nil
      @user.gmap_lat = nil
      @user.gmap_long = nil
      
      @user.create
      
      #do the login
      login_with_open_id(@user)
      UserImage.create_default_image_for(@user)
      
    end
    
    
    
    
  end
  
  def create
    
    if using_open_id?
      
      #verify if any record for this login
      logger.info("------------------IM HERE 1")
      if !params[:openid_url].nil?
        if !OpenidLogin.ishappening_login( OpenIdAuthentication.normalize_url(params[:openid_url]) ) 
          logger.info("------------------IM HERE 2")
          session_persistence = params[:session_persistent]  
          if session_persistence.nil?
            session_persistence = 0
          end
          OpenidLogin.create_login(OpenIdAuthentication.normalize_url(params[:openid_url]),session_persistence)
        end
      end
      logger.info("------------------IM HERE 3")
      
      
      open_id_authentication
    else
      password_authentication
    end
    rescue
    @error_open_id_msg = "Oops! Erro ao tentar validar a identidade OpenID!"
    render "openidsession/authfailed"
  end
  
  def destroy
    render :text=>"DESTROY"  
    #   self.current_user.forget_me if logged_in?
    #   cookies.delete :auth_token
    #   reset_session
    #   flash[:notice] = "You have been logged out."
    #   redirect_back_or_default('/')
  end
  
  protected
  
  def password_authentication
    render :text=>"password_authentication"
    #self.current_user = User.authenticate(login, password)
    #if logged_in?
    #  if params[:remember_me] == "1"
    #    self.current_user.remember_me
    #    cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
    #  end
    #  successful_login
    #else
    #  failed_login('Invalid login or password')
    #end
  end
  def import_open_id_data(email, nickname,openid_url, persistent)
    @email = email
    @openid_url = openid_url
    @nickname = nickname
    
    if !@nickname.nil?
      if @nickname.length> 20
        @nickname = nickname[0..20]
      end
    else
      @nickname = "[introduz um nome utilizador]"
    end
    
    if @email.nil?
      @email = "[introduz o teu email]"
    end
    
    render "openidsession/import_open_id_data"
  end
  
  def open_id_authentication
    # Pass optional :required and :optional keys to specify what sreg fields you want.
    # Be sure to yield registration, a third argument in the #authenticate_with_open_id block.
    openid_url = params[:openid_url]
    authenticate_with_open_id(openid_url, :required => [ :nickname, :email ]) do |result, identity_url, registration|
      if result.successful?
        
        #check if the user is already registered in our servide
        user = User.find_by_openid(identity_url)
        if user.nil?
          
          #logger.info("EMAIL-------------------"+registration['email'])
          #logger.info("NIVK-------------------"+registration['nickname'])
          persistence = "1"
          import_open_id_data(registration['email'], registration['nickname'],identity_url,persistence)
          return
        end
        
        login_with_open_id(user)
        #verify if profile is completed
        if user.profile_compteled == 0
          redirect_to :controller=>"user", :action=>"first_login"
          return
        else
          redirect_to home_url
          return;
        end
        #render :text=>"LOGIN SUCCESSFULLY "+registration['nickname']+" -- "+registration['email']
        
      else
        @error_open_id_msg = result.message
        render "openidsession/authfailed"
        #render :text=>result.message || "Sorry could not log in with identity URL: #{identity_url}"
        #failed_login(result.message || "Sorry could not log in with identity URL: #{identity_url}")
      end
    end
  end
  
  # registration is a hash containing the valid sreg keys given above
  # use this to map them to fields of your user model
  def assign_registration_attributes!(registration)
    { :login => 'nickname', :email => 'email' }.each do |model_attribute, registration_attribute|
      #unless registration[registration_attribute].blank?
      #  @user.send("#{model_attribute}=", registration[registration_attribute])
      #end
    end
    @user.save!
  end
  
  private
  
  def generate_pass
    pass = Guid.new.to_s
    return pass[0..15]
  end
  
  def successful_login
    #redirect_back_or_default('/')
    #flash[:notice] = "Logged in successfully"
  end
  
  
  def login_with_open_id(user)
    
    session[:logged_user] = user.id
    session[:post_filter] = nil
    session[:user_network_post_order] = nil
    session[:include_my_own_posts] = nil  
    session[:user_name] = user.screen_name  
    persistence = OpenidLogin.get_persistence_login_value(user.open_id_url)
    logger.info("Persistence login already during loggin is ------"+persistence.to_s)
    if persistence.to_s == "1"
      cookies[:logged_user] = {:value =>user.id.to_s, :expires => 720.hours.from_now }  
      cookies[:p] = {:value =>user.password_hash, :expires => 720.hours.from_now }
      cookies[:s] = {:value =>user.password_salt, :expires => 720.hours.from_now }
      cookies[:user_name] = {:value =>user.screen_name, :expires => 720.hours.from_now }
    end
    OpenidLogin.clear_login(user.open_id_url)
    rescue
    logger.info("Failed to set the Cookies---------")
    
    
  end
  
  def failed_login(message)
    #flash.now[:error] = message
    #render :action => 'new'
  end
  
end
