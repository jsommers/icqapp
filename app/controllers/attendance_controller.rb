class AttendanceController < ApplicationController

  def create
    @course = Course.find(params[:course_id])    

    attendance = @course.attendance_today
    if !attendance.checked_in? current_user
      attendance.users << current_user
    end
    redirect_to course_path(@course)
  end
end
