class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  rescue_from ActiveRecord::RecordNotFound, :with => :invalid_id

protected
  def redirect_if_student
    redirect_to courses_path if current_user.student? 
  end

  def invalid_id
    flash[:warning] = "Invalid identifier"
    redirect_to courses_path
  end
end
