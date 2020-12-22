class AttendanceController < ApplicationController

  def create
    @course = Course.find(params[:course_id])    
    # FIXME
    byebug
  end
end
