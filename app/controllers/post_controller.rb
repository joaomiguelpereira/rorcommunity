require 'uri'
require 'open-uri'
require 'hpricot'
require 'mofo'

class PostController < BaseController
  helper :tag_cloud
  
  def search
    @keywords = params[:search_keywords]
    #search in title as well in tags
    
    #strip the keywords
    tags = @keywords.split(" ")
    
    
    conditions_text = "original=1"
    condition_params = Hash.new
    
    
    conditions_text << " and title like :in_title OR "
    condition_params[:"in_title"]= "%#{@keywords}%"    
    
    
    
    count = 0   
    tags.each do |tag|
      count = count +1
      
      conditions_text << "url_has_label(link_url, :label_#{count}) "
      condition_params[:"label_#{count}"]= tag    
      if count != tags.size
        conditions_text << " OR "
      end
      
    end
    
    #    conditions_text << ""
    #    condition_params
    
    
    order_clause = "rank DESC"
    @post_pages, @posts = paginate(:user_post_v, :per_page=>10, :conditions=>[conditions_text,condition_params], :order=>order_clause)
    
    
  end
  
  def save_feed_channel
    
    order_by = params[:rss_channel][:order_by]
    limit_popular_by = params[:rss_channel][:limit_popular_by]
    name = params[:rss_channel][:name]
    tags_operator = params[:rss_channel][:tags_operator]
    filter_tags = params[:rss_channel][:filter_tags]
    use_groups = params[:rss_channel][:use_groups]
    user_id = session[:logged_user]
    
    if user_id.nil?
      user_id = 0
    end
    
    @error = Array.new
    @user_channel = nil
    if name.rstrip().lstrip().size() == 0
      @error << {:id=>"rss_channel_name_error", :msg=>"O nome da tag &eacute; obrigat&oacute;rio"}  
    else
      #create on channel
      @user_channel = UserChannel.new
      @user_channel.order_by = order_by
      @user_channel.limit_popular_by = limit_popular_by
      @user_channel.name = name
      @user_channel.tags_operator = tags_operator
      @user_channel.filter_tags = filter_tags
      @user_channel.user_groups = use_groups
      @user_channel.user_id = user_id
      @user_channel.save()
    end
    
  end
  
  def who_voted
    permalink = params[:permalink]
    if permalink.nil?
      redirect_to not_found_url
      return 
    end
    @post = Post.find(:first, :conditions=>["permalink = ?",permalink])
    
    #verify if this post is the original
    if !@post.nil? && @post.original != "1"
      #try to find the original
      post_original = Post.find(:first, :conditions=>["link_url = ? and original=?",@post.link_url,"1"])
      unless post_original.nil?
        @post = post_original
      end
    end
    if @post.nil?
      redirect_to not_found_url
      return
    end
    
    
    #verify order_by
    order_req = params[:order]
    #logger.info("---------------------"+order_req)
    
    if ( order_req.nil? ) 
      #try the session 
      if session[:order_users_voted_by].nil?
        order_req = "users_voted_order_1"
        session[:order_users_voted_by] = "users_voted_order_1"
        
      else
        order_req = session[:order_users_voted_by]
      end
    else
      session[:order_users_voted_by] = order_req
    end
    
    order_clause = "voted_at ASC"
    if order_req  == "users_voted_order_1"
      order_clause = "voted_at ASC"
    end
    if order_req  == "users_voted_order_2"
      order_clause = "voted_at DESC"
    end
    
    viewonly_req = params[:viewonly]
    if ( viewonly_req.nil? ) 
      #try the session 
      if session[:order_users_view_only].nil?
        viewonly_req = "users_votes_view_only_1"
        session[:order_users_view_only] = "users_votes_view_only_1"
        
      else
        viewonly_req = session[:order_users_view_only]
      end
    else
      session[:order_users_view_only] = viewonly_req
    end
    
    view_only_clause = "vote > -2 "
    
    if viewonly_req   == "users_votes_view_only_1"
      view_only_clause = "vote > -2 "
    end
    if viewonly_req   == "users_votes_view_only_2"
      view_only_clause = "vote > 0 "
    end
    if viewonly_req   == "users_votes_view_only_3"
      view_only_clause = "vote < 0 "
    end
    
    
    
    #@posts_saved
    @votes_pages, @votes = paginate(:user_votes, :per_page=>10, :conditions=>["post_id in (select p.id from posts p where #{view_only_clause} and p.link_url = ?)",@post.link_url],:order=>order_clause)
    
    @menu_active = "who_voted"
    
  end
  def who_saved
    #find by permalink
    permalink = params[:permalink]
    if permalink.nil?
      redirect_to not_found_url
      return 
    end
    @post = Post.find(:first, :conditions=>["permalink = ?",permalink])
    
    #verify if this post is the original
    if !@post.nil? && @post.original != "1"
      #try to find the original
      post_original = Post.find(:first, :conditions=>["link_url = ? and original=?",@post.link_url,"1"])
      unless post_original.nil?
        @post = post_original
      end
    end
    if @post.nil?
      redirect_to not_found_url
      return
    end
    
    
    #verify order_by
    order_req = params[:order]
    #logger.info("---------------------"+order_req)
    
    if ( order_req.nil? ) 
      #try the session 
      if session[:order_users_by].nil?
        order_req = "users_order_1"
        session[:order_users_by] = "users_order_1"
        
      else
        order_req = session[:order_users_by]
      end
    else
      session[:order_users_by] = order_req
    end
    
    order_clause = "created_at ASC"
    if order_req  == "users_order_1"
      order_clause = "created_at ASC"
    end
    if order_req  == "users_order_2"
      order_clause = "created_at DESC"
    end
    #@posts_saved
    @post_pages, @posts = paginate(:posts, :per_page=>10, :conditions=>["link_url=?",@post.link_url], :order=>order_clause)
    
    @menu_active = "who_saved"
  end
  
  def view_post
    #find by permalink
    permalink = params[:permalink]
    if permalink.nil?
      redirect_to not_found_url
      return 
    end
    @post = Post.find(:first, :conditions=>["permalink = ?",permalink])
    
    #verify if this post is the original
    if !@post.nil? && @post.original != "1"
      #try to find the original
      post_original = Post.find(:first, :conditions=>["link_url = ? and original=?",@post.link_url,"1"])
      unless post_original.nil?
        @post = post_original
      end
    end
    if @post.nil?
      redirect_to not_found_url
      return
    end
    #@post_comments = Comment.find(:all, :conditions=>["post_id = ?",@post.id], :order=>[""])
    #redirect_to :controller=>"community", :action=>"not_found"
    
    #render :controller=>"community", :action=>"not_found", :status => 404
    #raise params.inspect
    #render :text =>permalink
    @menu_active = "show_comments"
  end
  def feed_rss
    
    channel = params[:use_channel]
    
    #if !channel.nil?
    #  redirect_to :action=>"rss_use_channel", :channel_name=>channel
    #  return
    #end
    
    #@posts = Post.find(:all)
    
    #@the_channel = UserChannel.find(channel)
    where_clause = "original=1"
    #"DATE_SUB(CURDATE(),INTERVAL 1 DAY) <= created_at"
    order_clause = "order by rank asc"
    
    @posts = UserPostV.find_by_sql("select * from user_posts_v where #{where_clause} #{order_clause} limit 50")
    
    
    
    render :action=>"feed_rss", :layout=>false
  end
  
  def rss_use_channel
    
    channel = params[:channel_name]
    
    if channel.nil?
      redirect_to :action=>"feed_rss"
      return
    end
    
    #if 0 then must create one
    if channel=="0"
      redirect_to :action=>"rss_create_new_channel"  
      return
    end
    
    render :text=> channel
  end
  
  
  def rss_create_new_channel
    rss_channel = nil
    step = params[:step]
    @feed_url = nil
    
    if !step.nil? && step == "1"
      render :action=>"rss_create_new_channel_step1"  
      return
    end
    
    #get the feed_id
    feed_id = params[:feed_id]
    #get the feed from DB 
    user_channel = UserChannel.find(feed_id)
    user_name = "anonymous"
    #gte the user 
    
    if user_channel.user_id > 0
      user = User.find(user_channel.user_id)
      user_name = user.screen_name  
    end
    
    @feed_name = user_channel.name
    
    @feed_url = personalized_rss_url(:permalink=>user_channel.permalink,:user_screen_name=>user_name)
    
    # if session[:logged_user].nil?  
    #   rss_channel = RssChannel.new
    #   rss_channel.save
    #   rss_channel.name = "anonymous-rss-"+rss_channel.id.to_s
    #   rss_channel.url = anonymous_rss_url(:channel_name=>rss_channel.name)
    #   rss_channel.update
    #   @feed_url = rss_channel.url
    # else
    #   if !step.nil? && step == "1"
    #     render :action=>"rss_create_new_channel_step1"  
    #     return
    #   end
    # end
    
  end
  
  #def rss_create_new_channel_step1
  #    render :text =>"ttte"
  #end
  
  def front_page
    
    #filtering tags
    label = params[:label]
    change_tag_op = params[:change_tag_op]
    #check if there's any ordering in the request
    re_order = params[:order]
    top = nil
    
    if !label.nil?
      #try to get from session the filterting
      post_filter = session[:post_filter]
      if post_filter.nil?
        post_filter = PostFilter.new
        session[:post_filter] = post_filter
      end
      
      if !label.nil?
        post_filter.update_fp_filter(label)
      end
    end
    
    
    post_filter = session[:post_filter]
    
    if post_filter.nil?
      session[:post_filter] = PostFilter.new
      post_filter = session[:post_filter]
    end
    
    new_order = nil
    
    
    if !re_order.nil?  
      new_order = 2
      
      if re_order == "popular"
        #get also the top param
        top = params[:top]
        
        post_filter.fp_order = 2
        new_order = 2
        if top.nil? 
          top = "24"
          session[:front_page_top_stories] = top 
        else
          session[:front_page_top_stories] = top
        end
        
      end
      
      
      if re_order == "less_popular"
        
        post_filter.fp_order = 3
        new_order = 3
      end
      
      if re_order == "recent"
        
        post_filter.fp_order = 1
        new_order = 1
      end
      
      UserPreference.update_fp_order(session[:logged_user],new_order)
      
    else #if the req is null
      #try to get it from user prefs
      user_pref_order = UserPreference.get_fp_order(session[:logged_user])
      if user_pref_order.nil?
        
        
        new_order = post_filter.fp_order
      else
        new_order = user_pref_order
        post_filter.fp_order = user_pref_order
      end
    end
    
    
    if !change_tag_op.nil? &&  !post_filter.nil?
      if change_tag_op == "1"
        post_filter.tags_operator_op = "OR"
      else
        post_filter.tags_operator_op = "AND"
      end
    end
    conditions_text = "original=1"
    condition_params = Hash.new
    
    
    #filtering by tags
    if !post_filter.nil? && !post_filter.tags_fp.nil? 
      if post_filter.tags_fp.size > 0
        conditions_text << " and ("
      end
      count = 0
      post_filter.tags_fp.each do |filt_tag|
        count = count +1
        conditions_text << "url_has_label(link_url, :label_#{count}) "
        condition_params[:"label_#{count}"]= filt_tag    
        if count != post_filter.tags_fp.size
          conditions_text << "#{post_filter.tags_operator_op} "
        end
      end
      if post_filter.tags_fp.size > 0
        conditions_text << ")"
      end
    end
    
    order_clause = "created_at DESC"
    #top_clause = ""
    if new_order == 2
      
      top  = session[:front_page_top_stories]
      
      if top.nil?
        top = "24"
        session[:front_page_top_stories] = top
      end
      
      if !top.nil?
        if top != "24" && top != "7" && top != "30" && top != "365"
          top = "24"
          session[:front_page_top_stories] = top
        end
        top_txt = top 
        if top == "24"
          top_txt = 1
        end
        conditions_text << " and DATE_SUB(CURDATE(),INTERVAL #{top_txt} DAY) <= created_at"
        #condition_params[:created_at]= 
        #top_clause = "DATE_SUB(CURDATE(),INTERVAL #{top} DAY) <= created_at"    
      end
      order_clause = "rank DESC"
    end
    if new_order == 3
      order_clause = "rank ASC"
    end
    
    if new_order == 1
      order_clause = "created_at DESC"
    end
    
    #select * from user_posts_v where date_sub(CURDATE(), INTERVAL 4 DAY) <= created_at order by rank desc
    
    #end filtering by tags
    #@posts = Post.find(:all, :conditions=>["original=1"], :order=>"created_at DESC")
    @post_pages, @posts = paginate(:user_post_v, :per_page=>10, :conditions=>[conditions_text,condition_params], :order=>order_clause)
    
    #@post_pages, @posts = paginate(:posts, :per_page=>10, :conditions=>["original=1"], :order=>"created_at DESC")
  end
  
  
  
  #####################################################
  #confirm_delete_link
  #######################################################  
  def confirm_delete_link
    id = params[:id]
    
    unless id.nil?
      @div_name= "link_details_#{id}"
    else
      return
    end
    
    
    
    
    #get the post 
    post = Post.find(id)
    next_original = nil
    new_saved_by = 0
    new_votes = 0
    if post.original == "1"
      logger.info("This post is the original")
      #get the next original post
      next_original = Post.find(:first, :order=>["created_at DESC"],:conditions=>["link_url=? and id <> ?",post.link_url,id])
      UserVote.remove_user_vote(session[:logged_user],post.id)
      
      if next_original.nil?
        UserVote.clear_post_votes(post.id)
        logger.info("The next original post was not found")
      else
        logger.info("The next original post was found"+next_original.id.to_s)  
        UserVote.update_post_votes(post.id,next_original.id)
        #new_saved_by = post.saved_by- 1
        new_votes = post.votes-1
        #Post.update_saved_by(link_url,new_saved_by,post.id)
      end
    end
    
    removed_labels = Array.new
    
    post.labels.each do |label|
      removed_labels << label
      logger.info("the post have the label: "+label.name)
    end 
    
    post.destroy()
    
    unless next_original.nil?
      next_original.original = "1"
      #next_original.saved_by = new_saved_by
      next_original.votes = new_votes
      next_original.parent_post = nil
      next_original.update()
      Post.set_new_original(id, next_original.id)     
    end
    
    removed_labels.each do |label|
      Label.transaction do
        label_to_update = Label.find(label.id, :lock=>true)
        label_to_update.label_count += -1
        label_to_update.update()
        if label_to_update.label_count == 0
          Label.destroy(label.id)
        end
      end
      #unless next_original.nil?
      #  Post.remove_original_label(next_original,label)
      #end
    end
    
    #remove 
  end
  #####################################################
  #EDIT LINK
  #######################################################
  def edit_link
    
    post_id = params[:id]
    @post = Post.find(post_id)
    
    #scrap_url(@post.link_url)
    @post.old_tags = @post.user_labelled
    @found_tags = Array.new
    user = User.find(session[:logged_user])
    user_tags = user.user_tags
    @your_tags = Array.new
    
    user_tags.each do |your_tags|
      @your_tags<< {:tag_key=>"your_tag_#{your_tags.id}", :tag=>your_tags.name}
    end
    
    unless @post.labels.nil?
      tags = Array.new
      @post.labels.each do |label|
        tags <<  label.name
      end
      @post.temp_tags = tags.join(" ") 
    end
    @post.old_tags = @post.temp_tags
    
    #categories
    @post.temp_cats = ""
    @post.categories.each do |cat|
      @post.temp_cats += "#{cat.id},"
    end
    
    #get suggested tags
    #session[:your_tags] = user_your_tags
    #session[:your_tags] = user_your_tags
    original_post = Post.find_original_by_url(@post.link_url)   
    reco_tags = Array.new
    i = 0
    unless original_post.nil?
      post_lbs = Post.get_sum_labels(original_post.id)
      post_lbs.each do |rec|
        reco_tags << {:tag_key=>"rec_tag_#{i}", :tag=>rec}
        i +=1
      end
    end
    @recommended_tags = reco_tags
    
    
    
    
    @original = false
    @saved_by = Post.count_saved_by(original_post.link_url)
    
    @is_update = true
    render :action=>"submit_step_two"
  end
  
  
  ########################################################################
  ##SUBMIT
  ########################################################################
  def submit
    if session[:logged_user].nil?
      flash[:notice] = "Por favor faz login antes de submeter um link"
      session[:intended_controller] = "post"
      session[:intented_action] = "submit"
      redirect_to login_url
    end
    
    if request.post?
      
      
      #verify if the user already saved the link
      post = Post.find_by_url_by_user(params[:post][:link_url],session[:logged_user])
      
      #if already exists
      unless post.nil? 
        redirect_to :action=>"edit_link", :id=>post.id    
        return
      end
      
      
      
      #get the user posts
      user =  User.find(session[:logged_user])
      
      #If new######################
      original_post = Post.find_original_by_url(params[:post][:link_url])      
      @original = false
      if original_post.nil?
        @original = true
      else
        @voted_by = original_post.votes
        @saved_by = original_post.saved_by
      end
      @already_voted = false
      @post = Post.new(params[:post])
      unless original_post.nil?
        vote = UserVote.find_vote(user.id,original_post.id)
        if vote
          @already_voted = true    
        end
      end
      
      #try this url
      link_url = @post.link_url
      @found_tags = Array.new
      if (original_post || exists_url(link_url))
        if original_post.nil?
          scrap_url(link_url)
        end
        
        if original_post.nil?
          @post.title = @title
          @post.description = @description
          #session[:found_tags] = @found_tags
          #@found_tags = @found_tags
        else
          @post.title = original_post.title
          @post.description = original_post.description
          #session[:found_tags] = Array.new
          @found_tags = Array.new
        end
        @post.make_vote_on_submit = "yes"
        user = User.find(session[:logged_user])
        user_tags = user.user_tags
        user_your_tags = Array.new
        user_tags.each do |your_tags|
          user_your_tags << {:tag_key=>"your_tag_#{your_tags.id}", :tag=>your_tags.name}
        end
        
        #get your tags
        @your_tags = user_your_tags
        
        reco_tags = Array.new
        i = 0
        unless original_post.nil?
          post_lbs = Post.get_sum_labels(original_post.id)
          post_lbs.each do |rec|
            reco_tags << {:tag_key=>"rec_tag_#{i}", :tag=>rec}
            i +=1
          end
        end
        @recommended_tags = reco_tags
        
        @is_update = false
        render :action=>"submit_step_two"
        return
      else
        @post.errors.add(:link_url,"Esse link parece n&atilde;o ser v&aacute;lido. Verifica se o link existe.")
        render :action=>"submit"
        return
      end
      
      
    else
      @post = Post.new
      @post.link_url = "http://"
      
    end
    
  end
  ########################################################
  #submit_step_two
  #########################################################
  def submit_step_two
    #check if is logged
    if session[:logged_user].nil?
      redirect_to login_url
    end
    
  end
  #####################################################
  # is_permalink_valid(pemalink)
  #######################################################  
  def is_permalink_valid(pemalink)
    logger.info("verifing "+pemalink)
    post_url(:permalink=>Post.get_permalink(pemalink))  
    logger.info("ret true") 
    return true
  rescue 
    logger.info("ret false")
    return false
    
  end
  
  ################################################
  #UPDATE LINK
  ##################################################
  def update_link
    @post = Post.find( params[:id] )
    
    unless @post.update_attributes(params[:post])  
      @is_update = true
      flash[:notice] = "Ocorreram alguns erros durante a valida&ccedil;&atilde;o.<br/>Por favor verifica a informa&ccedil;&atilde;o! submetida"
      render :action=>"submit_step_two"
      return
    end
    
    #@post.user_labelled = remove_strange_chars(params[:post][:temp_tags])
    
    #update categories
    @post.categories.clear
    post_cats = @post.temp_cats
    post_cats_ids = post_cats.split(",")    
    post_cats_ids.each do |cat_id|
      @post.categories << Category.find(cat_id)
    end
    
    old_tags = params[:post][:old_tags]
    new_tags = remove_duplicates(remove_strange_chars(params[:post][:temp_tags]))
    
    #unless @post.parent_post.nil?
    
    #  @post.parent_post.update_text_tags(new_tags)
    #  @post.parent_post.update()
    #else
    
    #  @post.update_text_tags(new_tags)
    #  @post.update()
    #end
    
    #update user tags
    unless( new_tags.nil? && old_tags.nil?)
      
      old_tags_array = old_tags.split(" ")
      new_tags_array = new_tags.split(" ")
      
      #if old_tags_array.size >= new_tags_array.size
      
      removed_tags = Array.new
      
      old_tags_array.each do |old_tag|
        #verify if already exists in user 
        not_exists = true
        
        new_tags_array.each do |new_tag|
          if new_tag == old_tag
            not_exists = false
          end
          
          
        end
        
        if not_exists 
          removed_tags << old_tag
        end
        
        
        
      end
      
      added_tags = Array.new
      
      new_tags_array.each do |new_tag|
        not_exists = true
        
        old_tags_array.each do |old_tag|
          
          if old_tag == new_tag
            not_exists = false
          end
        end
        
        if not_exists
          added_tags << new_tag
        end
      end
      
    end
    
    user = @post.user
    
    removed_tags.each do |temp|
      user_tag = user.user_tags.find_user_tag(temp)
      
      unless user_tag.nil?
        user_tag.tag_count += -1
        user_tag.update()
        if user_tag.tag_count == 0
          #user.user_tags.delete_tag(user_tag)
          UserTag.delete_tag(user_tag.id)
        end
      end
      #user_tags.remove_user_tag(temp,user.id)
      #logger.info("You removed TAG "+temp)
      #now remove from labels_post
      label = Label.get_by_name(temp)
      unless label.nil?
        #############3
        #if @post.parent_post.nil?
        #  Post.remove_original_label(@post,label)
        #else
        #  Post.remove_original_label(@post.parent_post,label)
        #end
        ##############
        if (@post.labels.exists?(label.id))
          
          @post.labels.delete(label)
          Label.transaction do
            label = Label.find(label.id, :lock=>true)
            label.label_count += -1
            #label.updated_at = Time.now()
            label.update()
            if label.label_count == 0
              Label.destroy(label.id)
            end
          end
        end        
      end 
    end
    
    added_tags.each do |temp|
      user_tag = user.user_tags.find_user_tag(temp)
      
      if user_tag.nil?
        user_tag = UserTag.new(:name=>temp, :tag_count=>1)
        #user_tag.save()
        user.user_tags << user_tag
      else
        
        user_tag.tag_count += 1
        user_tag.update()
      end
      logger.info("You Added TAG "+temp)
      #update the original
      #unless @post.parent_post.nil?
      
      #  @post.parent_post.update_text_tags(new_tags)
      #  @post.parent_post.update()
      #else
      
      #  @post.update_text_tags(new_tags)
      #  @post.update()
      #end
      
      #Now it's time for Post_labels
      label = Label.get_by_name(temp)
      if label.nil?
        label = Label.new(:name=>temp, :label_count=>1);
        label.save()
      else
        Label.transaction do
          label = Label.find(label.id, :lock=>true)
          label.label_count +=1
          #label.updated_at = Time.now
          label.update()
        end #transaction
      end
      
      @post.labels << label    
      
      #if @post.parent_post.nil?
      #  Post.add_original_label(@post,label)
      #else
      #  Post.add_original_label(@post.parent_post,label)
      #end
    end
    
    
    session[:found_tags] = nil
    session[:your_tags] = nil
    session[:recommended_tags] = nil
    
    
    flash[:message_success] = "Link alterado com sucesso!"
    redirect_to home_url
  end
  
  
  ####################################################
  # sink_link
  ####################################################
  
  def sink_link
    id = params[:id]
    
    @logged = true
    if session[:logged_user].nil?
      @logged = false
    end
    @post_id = id
    @votes = 0
    @already_voted = false
    @vote_ul_element_id = "voting_ul_"+id
    @vote_href_element_id = "href_vote_"+id
    @vote_permalink = "#"
    @thumbs_el = "votes_thumbs_#{id}"
    @get_sink_el = "get_it_sink_#{id}"
    if @logged
      #Create a vote
      #verify if already voted
      
      vote = UserVote.find_vote(session[:logged_user], id)
      if vote.nil?
        @already_voted = false  
        vote = UserVote.new(:user_id=> session[:logged_user], :post_id=>id, :vote=>-1)
        vote.save()
      else
        @already_voted = true
      end
      #vote = UserVote.new(:user_id=> session[:logged_user], :post_id=>id)
      #vote.save()
      unless @already_voted
        Post.transaction do
          post = Post.find(id, :lock=>true)
          @vote_permalink = post.permalink
          post.votes += -1
          @votes = post.votes
          post.update()
        end
      end
    end
    @href_element_id = "voting_number_#{id}"
    @element_id = "voting_wrapper_#{id}"
    
  end
  ####################################################
  # remove_vote_link
  ####################################################
  def remove_vote_link
    id = params[:id]
    @logged = true
    if session[:logged_user].nil?
      @logged = false
    end
    
    @post_id = id
    @votes = 0
    @already_removed_voted = false
    @vote_ul_element_id = "voting_ul_"+id
    @vote_href_element_id = "href_vote_"+id
    @href_element_id = "voting_number_#{id}"
    @element_id = "voting_wrapper_#{id}"
    @thumbs_el = "votes_thumbs_#{id}"
    @get_sink_el = "get_it_sink_#{id}"
    
    if @logged
      vote = UserVote.find_vote(session[:logged_user], id)
      cont = -1
      if vote.vote == 1
        cont = -1  
      else
        cont = 1
      end
      if vote.nil?
        @already_removed_voted = true
      else
        UserVote.remove_user_vote(session[:logged_user], id)
        Post.transaction do
          post = Post.find(id, :lock=>true)
          post.votes += cont
          @votes = post.votes
          post.update()
        end
      end
      
    end
    
  end
  
  ################################################
  #Vote_link
  ################################################
  def vote_link
    id = params[:id]
    
    @logged = true
    if session[:logged_user].nil?
      @logged = false
    end
    @post_id = id
    @votes = 0
    @already_voted = false
    @vote_ul_element_id = "voting_ul_"+id
    @vote_href_element_id = "href_vote_"+id
    @vote_permalink = "#"
    @thumbs_el = "votes_thumbs_#{id}"
    @get_sink_el = "get_it_sink_#{id}"
    if @logged
      #Create a vote
      #verify if already voted
      
      vote = UserVote.find_vote(session[:logged_user], id)
      if vote.nil?
        @already_voted = false  
        vote = UserVote.new(:user_id=> session[:logged_user], :post_id=>id)
        vote.save()
      else
        @already_voted = true
      end
      #vote = UserVote.new(:user_id=> session[:logged_user], :post_id=>id)
      #vote.save()
      unless @already_voted
        Post.transaction do
          post = Post.find(id, :lock=>true)
          @vote_permalink = post.permalink
          post.votes += 1
          @votes = post.votes
          post.update()
        end
      end
    end
    @href_element_id = "voting_number_#{id}"
    @element_id = "voting_wrapper_#{id}"
    
  end
  
  ################################################
  #SAVE LINK
  ################################################
  def save_link
    #check if is logged
    
    if session[:logged_user].nil?
      redirect_to login_url
    end
    #verify is is the original already exists
    original_post = Post.find_original_by_url(params[:post][:link_url])
    #get the params
    @post = Post.new(params[:post])
    if !is_permalink_valid(@post.permalink)
      flash[:notice] = "O t&iacute;tulo do link &eacute; inv&aacute;lido. Tenta remover os caract&eacute;res que te pare&ccedil;am estranhos ;)<br/>Por favor verifica a informa&ccedil;&atilde;o! submetida"
      render :action=>"submit_step_two"
      return    
    end
    
    #get the domain
    @post.url_domain = scrap_domain(@post.link_url)
    #handle cats
    post_cats = @post.temp_cats
    new_saved_by = 0
    post_cats_ids = post_cats.split(",")    
    post_cats_ids.each do |cat_id|
      @post.categories << Category.find(cat_id)
      logger.info(cat_id)
    end
    
    #remove - from start and end of permalink
    
    @post.user_labelled = remove_duplicates(remove_strange_chars(@post.temp_tags)) 
    @post.votes = 0
    #if there's no original, then this will be the original
    if original_post.nil?
      @post.original = "1"
      @post.saved_by = 1
      
      if @post.make_vote_on_submit=="yes"
        @post.votes = 1 
      end
      
      #@post.parent_post = @post
      #if I'm the original I'll keep the tags of this post
    else
      @post.parent_post = original_post
      @post.original = "0"
      @post.saved_by = original_post.saved_by+1
      
      #Post.update_saved_by(link_url,@post.saved_by,original_post.id)
      
      Post.transaction do
        original_post = Post.find(original_post.id, :lock=>true)
        original_post.saved_by +=1
        if @post.make_vote_on_submit=="yes"
          #original_post.votes +=1 
          vote = UserVote.find_vote(session[:logged_user],original_post.id)
          if vote.nil?
            #ah ah and if I did already voted in the link??
            vote = UserVote.new(:user_id=> session[:logged_user], :post_id=>original_post.id)
            vote.save()
            original_post.votes +=1 
            #else
            #  original_post.votes =original_post.votes
          end
          
        end
        #update tags
        #original_post.update_text_tags(@post.user_labelled)
        original_post.update()
      end
      
    end
    
    #if original_post.nil?
    #  @post.sum_labels = @post.user_labelled
    #end
    
    @post.user = User.find(session[:logged_user])
    if @post.save
      
      #update the User Tags
      unless @post.user_labelled.empty?
        user = User.find(session[:logged_user])
        @post.user_labelled.split(" ").each do |tag|
          #check if tag exists
          #add the tag to the user
          
          
          
          user_tag = user.user_tags.find_user_tag(tag)
          
          if user_tag.nil?
            user_tag = UserTag.new(:name=>tag, :tag_count=>1)
            user.user_tags << user_tag
          else
            UserTag.transaction do
              user_tag = UserTag.find(user_tag.id, :lock=>true)
              user_tag.tag_count += 1
              user_tag.update()
            end #end transaction
          end #end if user_tag.nil?
          
          
          
          ##UPDATE POST_LABELS
          
          label = Label.get_by_name(tag)
          if label.nil?
            label = Label.new(:name=>tag, :label_count=>1)
            label.save()
          else
            Label.transaction do
              label = Label.find(label, :lock=>true)
              label.label_count +=1
              #label.updated_at = Time.now
              label.update()  
            end #end transaction
          end #label.nil?
          
          @post.labels << label
          #Update original post labels 
          #if original_post.nil?
          # Post.add_original_label(@post,label);
          
          #@post.update()
          #else
          #@post.parent_post.update()
          # Post.add_original_label(@post.parent_post,label);
          #end
          
          #add also the tag to the parent? no no no
        end #end each
        
      end #end unless
      #if new_saved_by > 0
      #  Post.update_saved_by(@post.link_url,new_saved_by,original_post.id)
      #end
      
      flash[:message_success] = "Link submetido com sucesso!"
      session[:found_tags] = nil
      session[:your_tags] = nil
      session[:recommended_tags] = nil
      if @post.original=="1" && @post.make_vote_on_submit=="yes"
        vote = UserVote.new(:user_id=> session[:logged_user], :post_id=>@post.id)
        vote.save()
      end
      
      redirect_to home_url
    else
      logger.error("Something was wrong here --------------------------------------- ")
      #flash[:notice] = "Ocorreram alguns erros durante a valida&ccedil;&atilde;o.<br/>Por favor verifica a informa&ccedil;&atilde;o! submetida"
      flash[:notice] = "Ocorreu um erro ao executar a tua tarefa. <br/>Infelizmente n&atilde;o foi poss&iacute;vel recuperar um estado consistente. <br/>Pedimos desculpa pelo inc&oacute;modo. Fomos notificados deste erro e em breve ser&aacute; corrigido."
      
      redirect_to  home_url
      #:action=>"submit_step_two"
    end
  rescue
    logger.error("Something was wrong here --------------------------------------- 1")
    #flash[:notice] = "Que cat&aacute;strofe. Algo correu muito mal por aqui!<br/>Por favor verifica a informa&ccedil;&atilde;o! submetida"
    flash[:notice] = "Ocorreu um erro ao executar a tua tarefa. <br/>Infelizmente n&atilde;o foi poss&iacute;vel recuperar um estado consistente. <br/>Pedimos desculpa pelo inc&oacute;modo. Fomos notificados deste erro e em breve ser&aacute; corrigido."
    redirect_to  home_url
    #redirect_to :action=>"submit_step_two"    
  end
  
  
  #######
  private
  #######
  def remove_strange_chars(str)
    
    str.gsub(/[<>'"]/,'')
    
  end
  
  def remove_duplicates(text)
    tags = Array.new
    unless text.nil?
      
      text.split(" ").each do |tag|
        contains = false
        
        tags.each do |new_tag|
          logger.info "comparing #{new_tag} with #{tag}"
          if new_tag.downcase == tag.downcase
            contains = true
          end
        end  
        
        unless contains
          tags << tag
        end
        
      end
      
    end 
    tags.join(" ")  
  end
  def scrap_domain(url)
    #http://www.google.com/skdj/sdkjsk/
    uri = URI.parse(url)
    
    uri.host
  end
  
  def exists_url(url)
    open(url)
    return true
    
  rescue
    return false
  end
  
  
  
  def scrap_url(url)
    @title = ""
    @description = ""
    @found_tags = Array.new
    
    
    doc = Hpricot(open(url))
    
    @title = doc.at("title").inner_html
    #@title = @title.gsub(/\W/,"-")
    #NKF.nkf('-wxm0', @title)
    
    
    @title = @title.delete("^a-zA-Z0-9 -_.:")
    
    #try to get the description
    logger.info(doc.search("//meta[@name='description]"))
    desc_el= doc.search("//meta[@name='description]")
    if ( desc_el )   
      unless desc_el[0].nil?
        @description = desc_el[0].attributes['content']
        #@description = @description.gsub(/\W/,"-")
        @description = @description.delete("^a-zA-Z0-9 -_.:")
        #NKF.nkf('-wxm0', @description)
      end
    end
    
    #Try get all tags
    rel_tags = RelTag.find(url)
    i = 0;
    rel_tags.each do |tag| 
      unless tag.empty?
        @found_tags << {:tag_key=>"found_#{i}", :tag=>"#{tag}"}
        #@found_tags << tag
        i = i + 1
      end
    end
    
  rescue Exception
    logger.info("*****Could not open #{url} for Scrapping*****")
    #open(url) {
    #  |page| page_content = page.read()
    #  #title = page_content.scan(/<title)
    #  ti = page_content.scan(%r{<title>(.+?)</title>}).flatten
    #  desc = page_content.scan(%r{<description>(.+?)</description>}).flatten
    #  @title = ti
    #  ti.each {|ti| logger.info ti}
    #}
    
    
    
  end
end
