class CategoryController < ApplicationController


  def index
    render :text=>"CXategories list"
  end
  def show_user_category
    render :text=>"Not implemented yet"
  end
  
  def show_posts_from_category
    cat = params[:category]
    if cat.nil?
      redirect_to :action=>"index"
      return
    end
    render :text=>cat+" Not implemented yet"
  end
end
