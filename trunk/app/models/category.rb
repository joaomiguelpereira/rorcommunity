class Category < ActiveRecord::Base

  has_and_belongs_to_many :posts
  
  def self.find_by_name(name)
    cat = Category.find(:first, :conditions=>["name=?",name])
    return nil if cat.nil?
    return cat.id
    
  end
  def self.get_all
    Category.find(:all, [:order=>"appear_order ASC"])
  end
end
