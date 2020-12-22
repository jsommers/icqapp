class AttendanceController < ApplicationController

  def create
    @course = Course.find(params[:course_id])    
    @course.attendance_today.users << current_user
    flash[:notice] = "Attendance check-in successful"
    redirect_to course_path(@course)
  end
end
