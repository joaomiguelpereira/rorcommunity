class PostFilter
  
  attr_accessor :tags
  attr_accessor :affected_user_id
  attr_accessor :filter_owner
  attr_accessor :operator
  attr_accessor :cats
  attr_accessor :cats_operator
  
  
 
  
  
  attr_accessor :tags_fp
  attr_accessor :tags_operator_op
  
  
  attr_accessor :fp_order
  
  def initialize
    self.fp_order = 2

    self.operator = Constants.or_operator
    self.tags = Array.new
    self.cats = Array.new
    self.tags_fp = Array.new
    self.tags_operator_op = Constants.or_operator
    self.cats_operator = Constants.or_operator
  end
  
  
  def update_filter_with_cat(cat,user_id)
    return if cat.nil?
    if self.cats.nil? 
      self.cats = Array.new
      
    end
    self.affected_user_id = user_id
    if !self.cats.include?(cat)
      self.cats << cat
    else
      self.cats.delete(cat)
    end
     
  end
  
  def update_fp_filter(tag)
    return if tag.nil?
    if self.tags_fp.nil?
      self.tags_fp = Array.new
      self.tags_operator_op = Constants.or_operator
    end
    
    if !self.tags_fp.include?(tag)
      self.tags_fp << tag
    else
      self.tags_fp.delete(tag)
    end
    
  end

 


  def update_filter(tag, user_id)
    return if tag.nil?
    
    self.affected_user_id = user_id
    if !self.tags.include?(tag)
      self.tags << tag
    else
      self.tags.delete(tag)
    end
  end
end
