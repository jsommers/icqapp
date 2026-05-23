class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  rescue_from ActiveRecord::RecordNotFound, with: :invalid_id

protected

  def redirect_if_student
    redirect_to courses_path if current_user.student?
  end

  def verify_course_enrollment
    course_id = params[:course_id] || params[:id]
    @course = Course.find(course_id)
    unless current_user.courses.exists?(id: @course.id)
      errortype = current_user.student? ? 'enrolled in' : 'an instructor of'
      flash[:notice] = "You're not #{errortype} #{@course.name}"
      redirect_to courses_path
    end
  end

  def invalid_id
    flash[:warning] = "Invalid identifier"
    redirect_to courses_path
  end
end
