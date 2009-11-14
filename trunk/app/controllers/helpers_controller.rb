class HelpersController < ApplicationController
  

  def render_helper
    @page = params[:page]
    @id = params[:id]
    
  end
end
