        class UserController < BaseController
          helper :post, :tag_cloud, :feed
          
          def change_list_page_in_dialog
            
            order_by = params[:order_by]
            direction = params[:direction]
            page = params[:page]
            filter = params[:filter]
            logged_user=session[:logged_user]
            
            
            if filter!= "all" && filter!= "network"
              filter = "all";
            end
            
            if order_by.nil?
              order_by = "screen_name"  
            else
              if order_by!= "screen_name" && order_by!= "activated_at" && order_by!= "rank"
                order_by = "screen_name" 
              end
            end
            
            if direction.nil?
              
              direction = "up"
            else
              if direction!="up" && direction!="down"
                direction = "up"
              end
            end
            
            if direction == "up"
              direction = "ASC"
            else
              direction = "DESC"
            end
            
            #if order_by == "screen_name"
            #  if direction == "ASC"
            #    direction == "DESC"
            #  else
            #    direction == "ASC"
            #  end
            
            #end
            where_clause = "1=1"
            
            if filter=="all"
              where_clause = "1=1"
            end
            
            if logged_user
              if filter=="network"
                where_clause = "is_friend(id, #{logged_user},false)"
              end
            end
            
            if logged_user
              where_clause += " and id <> #{logged_user}"
            end
            
            order_by_clause = order_by+" "+direction
            
            
            logger.info("-----------------------"+order_by_clause)
            #here I'll get the order_by and direction
            @users_pages, @users = paginate(:user_v , :per_page=>2, :conditions=>where_clause, :order=>order_by_clause)
            
          end
          
          def show_list_in_dialog
            logged_user=session[:logged_user]
            where_clause = "1=1"
            direction = "ASC"
            
            order_by = "screen_name "+direction  
            if logged_user
              where_clause += " and id <> #{logged_user}"
            end
            
            
            @users_pages, @users = paginate(:user_v , :per_page=>2, :order=>order_by, :conditions=>where_clause) 
            render :action=>"show_list_in_dialog", :layout=>false
            
          end
          
          def index
            redirect_to home_url
          end
          def list_users
            #get the order
            order_req = params[:order]
            the_order = 1
            
            if !order_req.nil?
              if order_req == "most_active"
                the_order = 1
              end
              if order_req == "most_popular"
                the_order = 2
              end
              
              if order_req == "most_recent"
                the_order = 3
              end
              if order_req == "oldest"
                the_order = 4
              end
              session[:user_list_order] = the_order 
            else
              
              the_order = session[:user_list_order]
              if the_order.nil?
                the_order = 1
                session[:user_list_order] = the_order
              end
              #update from session
            end
            #pop = n links_sub + n amigos + n_votos_links_dele + n_links_votados + n comentários
            #activity = last_post > last_comment > last vote  
            order_clause = "activated_at asc" 
            where_clause = "is_active = '1'"  
            
            if the_order == 1
              order_clause = "last_activity  DESC"
            end
            
            if the_order == 2
              order_clause = "rank  DESC"
            end
            
            if the_order == 3
              order_clause = "activated_at asc"
            end
            if the_order == 4
              order_clause = "activated_at desc"
            end
            
            
            @users_pages, @users = paginate(:user_v , :per_page=>20, :conditions=>where_clause, :order=>order_clause)
            
          end
          
          def refuse_friendship
            user_id = params[:id]
            fan_id = params[:fan_id]
            @logged = true
            @fan = nil 
            
            if fan_id.nil?
              @logged = false 
            else
              @user = User.find(user_id)
              is_fan_or_friend = UserFriends.is_fan_or_friend(user_id,fan_id)
              if !is_fan_or_friend
                @not_fan = true
              else
                @fan = User.find(fan_id)
                UserFriends.reject_friendship_to_fan(user_id, fan_id)        
              end
            end    
            
            
            
          end
          
          def promote_to_fan
            #get the user
            #get the friend
            user_id = params[:id]
            fan_id = params[:fan_id]
            @logged = true
            @fan = nil 
            
            if fan_id.nil?
              @logged = false 
            else
              @user = User.find(user_id)
              is_fan_or_friend = UserFriends.is_fan_or_friend(user_id,fan_id)
              if !is_fan_or_friend
                @not_fan = true
              else
                @fan = User.find(fan_id)
                UserFriends.promote_friend_to_fan(user_id, fan_id)    
                UserFriends.remove_friend(fan_id,user_id)
              end
            end
            
          end
          
          def accept_friendship
            #get the user
            #get the friend
            user_id = params[:id]
            fan_id = params[:fan_id]
            @logged = true
            @fan = nil 
            @not_fan = false
            
            if fan_id.nil?
              @logged = false 
            else
              logger.info("user_id #{user_id}   --  fan_id #{fan_id}")
              
              @user = User.find(user_id)
              
              is_fan_or_friend = UserFriends.is_fan_or_friend(user_id,fan_id)   
              
              if !is_fan_or_friend
                @not_fan = true
                #fan = User.find(fan_id)
                #UserFriends.create_fan(user_id, fan_id)
                #send email to the user, telling him that it have a new message in the inbox
                #UserAccountMailer.deliver_send_notification(@user,"O ${fan.screen_name} agora é tua fã. Ele pediu para pertencer à tua rede. Para o adicionares à tua rede vai a pagina da tua rede e clica sobre o nome do fan e seçlecciona aceitar como amigo. ")
              else
                #@already_fan = true
                #do the jerk
                @fan = User.find(fan_id)
                UserFriends.promote_fan_to_friend(user_id, fan_id)
                UserFriends.add_friend(fan_id,user_id)
                
              end
            end
            
            
          end
          
          def request_friendship
            user_id = params[:id]
            fan_id = params[:fan_id]
            @logged = true
            @fan = nil
            @already_fan = false
            
            if fan_id.nil?
              @logged = false 
            else
              logger.info("user_id #{user_id}   --  fan_id #{fan_id}")
              @user = User.find(user_id)
              is_fan_or_friend = UserFriends.is_fan_or_friend(user_id,fan_id)   
              
              if !is_fan_or_friend
                @fan = User.find(fan_id)
                UserFriends.create_fan(user_id, fan_id)
                #send email to the user, telling him that it have a new message in the inbox
                UserAccountMailer.deliver_send_notification(@user,"O ${@fan.screen_name} agora é tua fã. Ele pediu para pertencer à tua rede. Para o adicionares à tua rede vai a pagina da tua rede e clica sobre o nome do fan e seçlecciona aceitar como amigo. ")
              else
                @already_fan = true    
              end
            end
            
            
            #render :text=>"Friend ship req from #{fan_id} to #{user_id}"  
          end
          
          
          
          
          def reorder_net_tag_cloud
            user_id = params[:id]
            
            
            return if user_id.nil?
            
            @user = User.find(user_id)
            session_filter = SessionFilter.get_from_session(session)
            session_filter.update_from_params(params,session)
            
            
          end
          
          
          def user_friends
            screen_name = params[:user_screen_name]
            session_filter = SessionFilter.get_from_session(session)
            
            if params[:label]
              session_filter.add_tag(params[:label])
            end
            
            if params[:tag_filter_user_nw_order]
              session_filter.update_tags_operator(params[:tag_filter_user_nw_order])
            end
            
            #session_filter.update_from_params(params,session)
            
            
            the_order = session[:user_network_post_order]
            the_order_req = params[:order]
            
            if the_order.nil?
              if !session[:logged_user].nil?
                the_order = UserPreference.get_user_network_post_order(session[:logged_user])      
              end
              if the_order.nil?
                the_order = 1  
              end
              session[:user_network_post_order] = the_order  
            end
            
            
            
            #check the params
            if !the_order_req.nil? 
              the_order = 1
              
              if the_order_req == "popular"
                the_order = 2
              end
              if the_order_req == "less_popular"
                the_order = 3
              end
              
              if the_order_req == "recent"
                the_order = 1
              end
              
              if !session[:logged_user].nil?  
                UserPreference.update_user_network_post_order(session[:logged_user],the_order)   
              end   
              
              session[:user_network_post_order] = the_order  
            end
            
            #save if logged
            
            
            include_my_own_posts_req = params[:include_my_own_posts] 
            
            if screen_name.nil?
              redirect_to :action=>"user_not_found"
              return
            end
            #find the user by its screen_name
            @user = User.find(:first, :conditions=>["screen_name=?",screen_name])
            if @user.nil?
              redirect_to :action=>"user_not_found", :user_name=>screen_name
              return
            end
            
            do_filter_1 = false
            if session[:logged_user] && @user.id.to_s == session[:logged_user].to_s
              do_filter_1 = true    
            end
            
            if do_filter_1
              
              if  include_my_own_posts_req.nil?
                #try the session
                
                include_my_own_posts_req = session[:include_my_own_posts]
                
                if include_my_own_posts_req.nil?
                  #try the userpreference
                  include_my_own_posts_req = UserPreference.get_include_my_own_posts(@user.id)
                  session[:include_my_own_posts] = include_my_own_posts_req   
                end
              else
                if include_my_own_posts_req != "true" && include_my_own_posts_req != "false"
                  include_my_own_posts_req = "1"
                end
                
                if include_my_own_posts_req == "true"
                  include_my_own_posts_req = "1"
                end
                
                if include_my_own_posts_req == "false"
                  include_my_own_posts_req = "0"
                end
                
                if ( include_my_own_posts_req != UserPreference.get_include_my_own_posts(@user.id))
                  UserPreference.update_include_my_own_posts(@user.id,include_my_own_posts_req)  
                end 
                session[:include_my_own_posts] = include_my_own_posts_req  
                
              end
              
            end
            include_my_own_posts = "TRUE"
            
            if !include_my_own_posts_req.nil?
              if include_my_own_posts_req.to_s == "1"
                include_my_own_posts = "TRUE"
              else
                include_my_own_posts = "FALSE"
              end
            end
            
            order_text = "created_at DESC" 
            if the_order == 2
              order_text = "rank DESC"
            end
            
            if the_order == 3
              order_text = "rank ASC"
            end
            
            conditions = ""
            params = Hash.new
            
            #conditions = "is_friend(user_id,:user_id, #{include_my_own_posts})"
            
            params[:user_id]=@user.id
            
            
            
            if session_filter.user_friend_network_tag.size > 0
              conditions << " and ("
            end
            count = 0
            session_filter.user_friend_network_tag.each do |filtered_tag|
              count = count + 1
              conditions << " has_label(id,'#{filtered_tag}') "
              if count < session_filter.user_friend_network_tag.size
                conditions << session_filter.user_friend_network_tag_operator
                #logger.info("----------------------------------------------------Operator is "+session_filter.user_friend_network_tag_operator)
              end
            end
            if session_filter.user_friend_network_tag.size > 0
              conditions << ") "
            end
            #is_friend(upv.user_id,4, TRUE);
            
            #is_friend(upv.user_id,4, TRUE);
            
            #{conditions}
            #esclude repeated URLs
            
            
            the_sql = "select * from user_posts_v where is_friend(user_id,#{@user.id}, #{include_my_own_posts}) #{conditions}  group by link_url order by #{order_text}" 
            #render :text=>the_sql
            #@post_pages, @posts = paginate(:user_post_v, :per_page=>10, :conditions=>[conditions,params],:order=>order_text, :select=>["group","link_url"])
            @post_pages, @posts = paginate_by_sql UserPostV, the_sql, 10
            #get all posts
            
          end
          
          
          def show_voted_links
            screen_name = params[:user_screen_name]
            if screen_name.nil?
              redirect_to :action=>"user_not_found"
              return
            end
            #find the user by its screen_name
            @user = User.find(:first, :conditions=>["screen_name=?",screen_name])
            if @user.nil?
              redirect_to :action=>"user_not_found", :user_name=>screen_name
              return
            end
            
            the_order = params[:order]
            
            order_clause = "voted_at DESC"
            
            if the_order.nil?
              the_order = session[:view_user_votes_order]
              
              if the_order.nil?
                session[:view_user_votes_order] = "1"
                the_order = "1"
              end
            end
            
            if !the_order.nil?
              if the_order == "1"
                
                order_clause = "voted_at DESC"
              end
              
              if the_order == "2"
                order_clause = "voted_at ASC"
              end
              session[:view_user_votes_order] =the_order
            end
            
            inex_req = params[:inex]
            if  inex_req.nil?
              inex_req = session[:inc_exc_voted_user_links] 
            else
              session[:inc_exc_voted_user_links] = inex_req 
            end
            
            if inex_req.nil?
              inex_req = "exclude_user_saved"
              session[:inc_exc_voted_user_links] = inex_req 
            end
            
            where_clause_1 = "and post_id not in (select p.id from posts p where p.user_id = ?)"
            
            if  inex_req == "exclude_user_saved"
              where_clause_1 = "and post_id not in (select p.id from posts p where p.user_id = ?)"
            end
            
            if  inex_req == "include_user_saved"
              where_clause_1 = "and user_id = ?"
            end
            
            view_only = params[:view_only]
            
            if view_only.nil?
              view_only = session[:view_user_votes_only]
            else
              
              session[:view_user_votes_only] = view_only
              
            end
            
            if view_only.nil?
              view_only = "view_user_votes_only_1"
              session[:view_user_votes_only] = view_only
            end
            
            where_clause_2 = "and (vote = 1 or vote = -1)"
            
            if view_only == "view_user_votes_only_1"
              where_clause_2 = "and (vote = 1 or vote = -1)"
            end
            
            if view_only == "view_user_votes_only_2"
              where_clause_2 = "and vote = 1"
            end
            if view_only == "view_user_votes_only_3"
              where_clause_2 = "and vote = -1"
            end
            
            #    @post_pages, @posts = paginate(:user_votes, :per_page=>2, :conditions=>["user_id=?",@user.id])
            #    and post_id not in (select p.id from posts p where p.user_id <> 4) 
            @post_pages, @posts = paginate(:user_votes, :per_page=>10, :conditions=>["user_id=? #{where_clause_2} and post_id in (select p.id from posts p where p.original = 1) #{where_clause_1}",@user.id,@user.id],:order=>order_clause)
          end
          
          def public_user_posts
            screen_name = params[:user_screen_name]
            if screen_name.nil?
              redirect_to :action=>"user_not_found"
              return
            end
            #find the user by its screen_name
            @user = User.find(:first, :conditions=>["screen_name=?",screen_name])
            if @user.nil?
              redirect_to :action=>"user_not_found", :user_name=>screen_name
              return
            end
            
            
            
            
            redirect_to :action=>"user_posts", :id=>@user.id
            
          end
          
          def user_posts
            
            user_id = params[:id]
            
            
            #verify if there's any label present´
            label = params[:label]
            category = params[:category]
            
            if !label.nil? || !category.nil?
              
              post_filter = session[:post_filter]
              
              if post_filter.nil?
                post_filter = PostFilter.new
                session[:post_filter] = post_filter 
              end
              if !category.nil?
                post_filter.update_filter_with_cat(category,user_id)
              end
              if !label.nil?
                post_filter.update_filter(label, user_id)
              end
              
            end
            #end label verification
            
            @user = nil
            
            if user_id.nil?
              screen_name = params[:user_screen_name]
              
              if screen_name.nil?
                redirect_to front_page
                return
              end
              
              
              @user = User.find(:first, :conditions=>["screen_name=?",screen_name])
              
              if @user.nil?
                redirect_to :action=>"user_not_found", :user_name=>screen_name
                return
              end
              user_id = @user.id
            else
              @user = User.find(user_id)
            end
            
            #logged user
            logged_user = nil
            
            if session[:logged_user]
              logged_user = User.find(session[:logged_user])  
              
            end
            
            order = 0
            
            if !logged_user.nil?
              
              if logged_user.user_preference.nil?
                
                user_preference = UserPreference.new
                user_preference.view_order = 1
                logged_user.user_preference = user_preference 
                order = 1
              else
                order = logged_user.user_preference.view_order
                if order.nil?
                  user_preference.view_order = 1
                  logged_user.user_preference.update()
                end 
              end
            end
            
            req_order = params[:order]
            
            if !req_order.nil? && req_order.to_s != order.to_s
              if !logged_user.nil?
                logged_user.user_preference.view_order = req_order
                logged_user.user_preference.update()
              end
              order = req_order
            end
            
            if req_order.nil?
              order = session[:order_by_tmp]
            end
            
            
            
            post_filter = session[:post_filter]
            
            if !post_filter.nil?
              #verify if is any parameter
              tag_operator = params[:change_tag_op]
              if !tag_operator.nil?
                if tag_operator == "2"
                  post_filter.operator = "AND"
                else
                  post_filter.operator = "OR"
                end
                
              end
            end
            
            
            
            order_clause = "created_at DESC"
            
            if !order.nil?
              session[:order_by_tmp] = order.to_s
              #verify id the user has already a preference
              if order.to_s == "1"
                order_clause = "created_at DESC"
                
              end
              
              if order.to_s == "2"
                order_clause = "created_at ASC"
                
              end
              
              if order.to_s == "3"
                order_clause = "votes DESC"
              end
              
              if order.to_s == "4"
                order_clause = "votes ASC"
              end
              
              if order.to_s == "5"
                order_clause = " rank DESC"
              end
              if order.to_s == "6"
                order_clause = "rank ASC"
              end
              
            end
            
            view_only = params[:view_only]
            
            if view_only.nil?
              #trye the session
              view_only = session[:view_user_posts_only]
              
              if ( view_only.nil? )
                session[:view_user_posts_only] = "view_user_posts_only_1"
              else
                view_only = session[:view_user_posts_only]  
              end
            else
              session[:view_user_posts_only] = view_only
            end
            
            
            view_only_clause = "original > -1"
            
            if view_only == "view_user_posts_only_1"
              view_only_clause = "original > -1"
            end
            
            if view_only == "view_user_posts_only_2"
              view_only_clause = "original = 1"
            end
            if view_only == "view_user_posts_only_3"
              view_only_clause = "original <> 1"
            end
            
            conditions_txt = "#{view_only_clause} and user_id=:user_id "
            params = Hash.new
            params[:user_id]=user_id
            
            
            
            #verify if have any label to apply
            if !post_filter.nil? && !post_filter.tags.nil? 
              if post_filter.tags.size > 0
                conditions_txt << " and ("
              end
              count = 0
              post_filter.tags.each do |filt_tag|
                count = count +1
                conditions_txt << "has_label(id, :label_#{count}) "
                params[:"label_#{count}"]= filt_tag    
                if count != post_filter.tags.size
                  conditions_txt << "#{post_filter.operator} "
                end
              end
              if post_filter.tags.size > 0
                conditions_txt << ")"
              end
            end
            
            #now see if there's any category
            #if !post_filter.nil? && !post_filter.cats.nil? 
            #  if post_filter.cats.size > 0
            #    conditions_txt << " and ("
            #  end
            #  count = 0
            #  post_filter.cats.each do |filt_cat|
            #    count = count +1
            #    conditions_txt << "has_category(id, :cat_#{count}) "
            #    params[:"cat_#{count}"]= filt_cat    
            #    if count != post_filter.cats.size
            #      conditions_txt << "#{post_filter.cats_operator} "
            #    end
            #  end
            #  if post_filter.cats.size > 0
            #    conditions_txt << ")"
            #  end
            #end
            
            
            
            #logger.info(",,,,,,,,,,,,,,,,,,,,,,,,,,,"+params.join(","))
            
            #@posts = Post.find(:all, :conditions=>["user_id=?",user_id], :order=>"created_at DESC")
            
            #@post_pages, @posts = paginate(:posts, :per_page=>10, :conditions=>["user_id=?",user_id], :order=>order_clause)
            #@post_pages, @posts = paginate(:user_post_v, :per_page=>2, :conditions=>["#{view_only_clause} and user_id=?",user_id], :order=>order_clause)
            @post_pages, @posts = paginate(:user_post_v, :per_page=>10, :conditions=>[conditions_txt,params], :order=>order_clause)
          end
          
          def view_public_profile_by_id
            user_id = params[:user_id]
            @user = User.find(user_id)
            render "user/view_public_profile"
          end
          
          def view_public_profile
            screen_name = params[:user_screen_name]
            if screen_name.nil?
              redirect_to :action=>"user_not_found"
              return
            end
            #find the user by its screen_name
            @user = User.find(:first, :conditions=>["screen_name=?",screen_name])
            if @user.nil?
              redirect_to :action=>"user_not_found", :user_name=>screen_name
              return
            end
            
          end 
          
          def user_not_found
            @user_name = params[:user_name]
            if @user_name.nil?
              @user_name = ""
            end
            response.headers["Status"] = "404"
            
          end
          def register
            
          end
          
          def pre_register
            if request.post?
              @user = User.new(params[:user])
              
              @user.activation_key = Guid.new.to_s
              @user.is_active = "0"
              if @user.save()
                UserAccountMailer.deliver_confirm_registration(@user)
                UserImage.create_default_image_for(@user)
                
                redirect_to :action =>'register_confirm', :id=>@user.id
                
              else
                render :action=>'register'
                
              end
            else
              redirect_to register_url
            end
            
          end
          def confirm_registration
            activation_key = nil
            #if not a post
            if request.post?
              activation_key = params[:user_activation][:activation_key]
            else
              activation_key = params[:activation_key]
            end
            
            if activation_key.nil?
              redirect_to register_url 
              return
            end
            
            
            #try to find a user with activation key = activation_key
            
            user = User.find(:first, :conditions=>['activation_key=?',activation_key.strip])
            
            if user.nil? || user.is_active == "1"
              redirect_to :action=>"activation_failed", :activation_key=>activation_key.strip
              return
            end
            
            
            ##Check if the user is already registered
            user.is_active = "1"
            user.activation_key = nil
            user.activated_at = Time.now()
            user.profile_compteled  = 0;
            user.update()
            
            redirect_to :action=>"activation_sucess", :activation_key=>activation_key.strip
          end
          def activation_sucess
            activation_key = params[:activation_key]
            if activation_key.nil?
              redirect_to home_url
              return
            end 
          end
          #
          #LOST PASSWORD
          #
          def lost_password
            unless request.post?
              redirect_to login_url
              return
            end
            
            #get the email from params
            email = params[:lost_user][:email]
            if email.nil?
              redirect_to login_url
              return
            end    
            
            #get the user with the email
            
            @user = User.find(:first, :conditions=>["email=?",email])
            if @user.nil?
              redirect_to :action=>"password_reseted", :email=>email,:status=>"fail" and return
            end
            @user.retrieve_pwd_key = Guid.new.to_s
            @user.update()
            UserAccountMailer.deliver_reset_pwd(@user)
            @user = nil
            redirect_to :action=>"password_reseted", :email=>email,:status=>"ok"
          end
          
          def change_lost_password
            retrieve_pwd_key = nil
            from_email = false
            
            if request.post?
              retrieve_pwd_key = params[:user_lostpwd][:retrieve_pwd_key]
            else
              retrieve_pwd_key = params[:lostpass_key]
              from_email = true
            end
            
            if retrieve_pwd_key.nil?
              log.info("retrieve_pwd_key is nil")
              
              redirect_to login_url 
              return
            end
            
            #try to find a user with that key in retrieve_pwd_key
            user = User.find(:first, :conditions=>["retrieve_pwd_key=?",retrieve_pwd_key.strip])
            if user.nil?
              
              flash[:notice] = "Chave inv&aacute;lida"
              logger.info("user is nil")
              if from_email
                redirect_to login_url 
                return
              end
              redirect_to :back 
              return
            end
            redirect_to :action=>"show_redefine_pwd", :id=>user.id, :retrieve_pwd_key=>retrieve_pwd_key
            
          end
          def update_password
            @user = User.find(params[:id])
            if @user.nil?
              redirect_to login_url
              return
            end
            
            @user.retrieve_pwd_key = nil
            if @user.update_attributes(params[:user])
              flash[:message_success] = "Password alterada com sucesso"
              redirect_to login_url 
            else
              flash[:notice] = "Ocorreram alguns erros.<br/>Verifica os dados."
              render :action=>"show_redefine_pwd", :id=>@user.id, :retrieve_pwd_key=>@user.retrieve_pwd_key
            end   
          end
          
          def show_redefine_pwd
            user_id = params[:id]
            retrieve_pwd_key = params[:retrieve_pwd_key]
            
            if user_id.nil? || retrieve_pwd_key.nil?
              logger.info("Failed attemp to reset passw. Nil params")
              redirect_to login_url
              return
            end
            
            @user = User.find(:first, :conditions=>["id=? and retrieve_pwd_key=?",user_id,retrieve_pwd_key])
            
            if @user.nil?
              logger.info("Failed attemp to reset passw")
              redirect_to login_url
              return
            end
            
          end
          
          
          def password_reseted
            
            status = params[:status]
            @email = params[:email]
            if status.nil? || @email.nil?
              redirect_to login_url
            end
            if status == "ok"
              render :action=>"password_reset_ok"
            else
              render :action=>"password_reset_fail"
            end
          end
          #
          #END PASSWORD LOST
          #
          def activation_failed
            @activation_key = params[:activation_key]
            if @activation_key.nil?
              redirect_to home_url
              return
            end
            
          end
          
          def invalid_registration
            user_id = params[:id]
            if user_id.nil?
              redirect_to home_url
              return
            end
            
            #find the user
            @user = User.find(user_id)
          end
          
          def register_confirm
            #find the user
            unless params[:id]
              redirect_to register_url
              return
            end
            @user = User.find(params[:id])
            rescue
            redirect_to register_url
            logger.info "Attempt to confirm registration for user id: "+params[:id]+" Failed"
            
          end
          def reactivate_account
            #user_screen_name = params[:screen_name_tmp]
            user_id = params[:user]
            return if user_id.nil?
            #get the user
            @user = User.find(user_id)
            @user.activation_key = Guid.new.to_s
            @user.update()
            UserAccountMailer.deliver_confirm_registration(@user)
            render :text =>"<div class='small_sucess'>Enviado email para <strong>"+@user.email+"</strong> com sucesso!</div>"
            
            rescue
            render :text =>"<div class='small_fail'>Erro ao enviar email para <strong>"+@user.email+"</strong>!</div>"
          end
          
          def check_availability
            user_screen_name = params[:screen_name_tmp]
            user = User.find(:first, :conditions=> ["screen_name = ?",user_screen_name])
            if user
              render :text =>"<div class='red_outter'><div class='red_inner'>Infelizmente o nome <strong>"+user_screen_name+"</strong> n&atilde;o est&aacute; dispon&iacute;vel :-(</div></div>"
            else
              render :text =>"<div class='green_outter'><div class='green_inner'> Porreiro! O nome <strong>"+user_screen_name+"</strong> est&aacute; dispon&iacute;vel</div></div>"
            end
          end
          ###Protetect actions  
          def first_login
            check_is_logged        
            @user = get_logged_user
          end
          
          
          def update_pasword
            check_is_logged
            @user = get_logged_user
            if @user.update_attributes(params[:user_pw])
              flash[:message_success] = "Password alterada com sucesso"
            else
              flash[:notice] = "Erro ao alterar a password"
            end
            render :action =>"edit_profile"
          end
          
          def update_profile
            check_is_logged 
            @user = get_logged_user
            #just want to updtate some of the fields
            #I know is shit, but...
            @user.first_name = params[:user][:first_name]
            @user.last_name = params[:user][:last_name]
            @user.localization = params[:user][:localization]
            @user.website = params[:user][:website]
            
            #google maps
            @user.gmap_zoom_level = params[:user][:gmap_zoom_level]
            @user.gmap_lat = params[:user][:gmap_lat]
            @user.gmap_long = params[:user][:gmap_long]
            
            
            if @user.update()
              flash[:message_success] = "Perfil actualizado com sucesso"
              
            else
              flash[:notice] = "Erro ao actualizar perfil"
            end
            render :action =>"edit_profile"
          end
          
          def edit_profile
            check_is_logged 
            
            @user = get_logged_user
            rescue
            flash[:notice] = "Utilizador n&atilde;o autenticado<br/>"
            redirect_to login_url
            return
          end
          
          
          def change_photo
            check_is_logged 
            @user = get_logged_user
            render :action=>"change_photo", :layout=>"upload_photo_layout"
          end
          
          private 
          def get_logged_user
            
            User.find(session[:logged_user])
            
            
          end
          
          def check_is_logged
            if session[:logged_user].nil?
              
              flash[:notice] = "Utilizador n&atilde;o autenticado<br/>"
              
              
            end
          end
        end
