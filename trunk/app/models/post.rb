
class Post < ActiveRecord::Base
  
  #acts_as_taggable
  before_create :create_permalink
  has_and_belongs_to_many :categories
  has_and_belongs_to_many :labels
  has_many :comments
  belongs_to :user
  belongs_to :parent_post, :class_name=>"Post", :foreign_key => "post_id"
  has_many :post_tags
  attr_accessor :temp_tags
  attr_accessor :temp_cats
  attr_accessor :old_tags
  attr_accessor :make_vote_on_submit
  attr_accessor :vote
  
  validates_presence_of :link_url, :message=>"Sem o URL do link não se pode fazer nada :("
  validates_presence_of :title, :message=>"O t&iacute;tulo &eacute; obrigat&oacute;rio!"
  validates_presence_of :temp_cats, :message=>"Selecciona pelo menos uma categoria"
  
  
  
  def self.find_original_by_url(url) 
    Post.find(:first, :conditions=>["link_url=? and original=1", url])
  end
  
  def self.find_by_url_by_user(url, user_id)
    Post.find(:first, :conditions=>["link_url=? and user_id=?", url,user_id])
  end
  def self.find_by_url(url) 
    Post.find(:first, :conditions=>["link_url=?", url])
  end
  
  def self.get_count_submited_for_user(user_id)
    Post.count(:conditions=>["user_id=?",user_id])
  end
  def self.count_votes_on_user_links(user_id)
    Post.count_by_sql("select sum(votes) from posts where user_id=#{user_id}")
  end
  
  def self.count_user_submited_links_duplicated(user_id)
    Post.count_by_sql("select count(*) from posts p left join posts pp on (p.link_url = pp.link_url) where p.user_id=#{user_id} and p.user_id <> pp.user_id")
  end
  
  def self.update_saved_by(link_url,new_saved_by,post_id)
    sql = "update posts set saved_by=#{new_saved_by} where link_url=#{link_url} and id<>#{post_id}" 
    ActiveRecord::Base.connection.execute(sql)
  end
  
  def self.count_saved_by(post_url) 
    Post.count(:conditions=>["link_url = ?",post_url])
  end
  
  
  def count_saved_by
    post_v = UserPostV.find(:first, :conditions=>["link_url=?", self.link_url])
    return post_v.saved_by
  end
  
  def voted(user_id)
    user_vote = UserVote.find_vote(user_id, self.id)
    if ( user_vote )
      self.vote = user_vote.vote 
      return true
    else
      self.vote = 0
      return false
    end
  end
  #  def update_label(tag)
  #    logger.info("updating tag"+tag)
  #    #verify if the label exists in DB
  #    label = Label.get_by_name(tag)
  #    
  #    #if the tag does not exists, then create if 
  #    if label.nil?
  #      label = Label.new(:name=>tag, :label_count=>0)
  #      label.save()
  #    end
  #    
  #    #Now I have the Label
  #    #verify if the label already exists in collection
  #    if self.labels.exists?(label.id)  
  #      logger.info("The original Post "+self.id.to_s+" Already contains the TAG")
  #      sql = "update labels_posts set label_count=label_count+1 where label_id=#{label.id} and post_id=#{self.id}"
  #      ActiveRecord::Base.connection.execute(sql)
  #    else
  #      Label.transaction do
  #        label = Label.find(label.id, :lock=>true)
  #        label.label_count +=1
  #        label.update()
  #      end
  #      self.labels.push_with_attributes(label, :label_count=>1) 
  #    end
  #    
  #  end
  #  def add_tag
  #    
  #    
  #  end
  #  
  def self.get_sum_labels(post_id)
    sql = "select label_count, post_id, label_id from original_post_labels where post_id=#{post_id}"
    result = ActiveRecord::Base.connection.select_all(sql)
    ret = Array.new
    result.each do |temp|
      ret <<   Label.find(temp["label_id"]).name
    end
    ret
  end
  
  
  def self.remove_original_label(post,label)
    sql = "select label_count, post_id, label_id from original_post_labels where post_id=#{post.id} and label_id=#{label.id}"
    result = ActiveRecord::Base.connection.select_all(sql)
    if result.nil? || result.empty?
      logger.info("Nothing to do:"+label.name)
      return
    end
    
    count = ""
    label_id = ""
    post_id = ""
    result.each do |temp|
      label_id = temp["label_id"]
      count = temp["label_count"]
      post_id =  temp["post_id"]
    end
    
    if count.to_i > 1
      sql = "update original_post_labels set label_count=label_count-1 where post_id=#{post.id} and label_id=#{label.id}"
    else
      sql = "delete from original_post_labels where post_id=#{post.id} and label_id=#{label.id}"
    end
    ActiveRecord::Base.connection.execute(sql)
  end
  
  def self.set_new_original(old_id, new_id)
    sql = "update original_post_labels set post_id=#{new_id} where post_id=#{old_id}"  
    ActiveRecord::Base.connection.execute(sql)
  end
  
  def self.add_original_label(post,label)
    
    sql = "select label_count, post_id, label_id from original_post_labels where post_id=#{post.id} and label_id=#{label.id}"
    
    result = ActiveRecord::Base.connection.select_all(sql)
    
    if (result.nil?)
    else
      if result.empty?
        sql = "insert into original_post_labels(post_id,label_id,label_count) values('#{post.id}','#{label.id}',1)"
        result = ActiveRecord::Base.connection.execute(sql)
        #add this to the sum_labels
      else
        sql = "update original_post_labels set label_count=label_count+1 where post_id=#{post.id} and label_id=#{label.id}" 
        result = ActiveRecord::Base.connection.execute(sql)
        #post.sum_labels +=" "+label.name
      end
    end
    #verifies if te label already exists in the sum
    
  end
  
  
  def self.get_permalink(str)
    str = str.strip
    #accents = { 'ã' => 'a', 'é' => 'e' }
    #accents.each do |accent, replacement|
    # str.gsub!(accent, replacement)
    #end
    #str = str.tr("ae","ae")
    ret_permalink =""
    
    temp_permalink = str.gsub(/\W/,"-").gsub(/-{2,}/,"-")
    
    #remove any - from end and start
    
    if temp_permalink[-1,1] == "-"
      temp_permalink[-1] =""
      
    end
    if temp_permalink[0,1] == "-"
      temp_permalink[0] =""
    end
    
    #temp_permalink = temp_permalink.gsub()
    temp_permalink_full = temp_permalink+".html"
  
    post = Post.find(:first, :conditions=>["permalink=?",temp_permalink_full])
    if post.nil?
      ret_permalink = str.gsub(/\W/,"-").gsub(/-{2,}/,"-")
      
      if ret_permalink[-1,1] == "-"
        ret_permalink[-1]=""
      end
      if ret_permalink[0,1] == "-"
        ret_permalink[0]=""
      end
      
      
      ret_permalink += ".html"
    else
      count = Post.count(:conditions=>["permalink like ?",temp_permalink+"-%.html"])
      ret_permalink = str.gsub(/\W/,"-").gsub(/-{2,}/,"-")
      
      if ret_permalink[-1,1] == "-"
        ret_permalink[-1]=""
      end
      if ret_permalink[0,1] == "-"
        ret_permalink[0]=""
      end
      
      ret_permalink += "-#{count}.html"
      
    end
    ret_permalink
  
  end
  
  def create_permalink
    self.permalink = Post.get_permalink(self.permalink)
  end
  
end
