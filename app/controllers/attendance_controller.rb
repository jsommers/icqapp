class AttendanceController < ApplicationController
  before_action :verify_course_enrollment

  def create
    attendance = @course.attendance_today
    if attendance && !attendance.checked_in?(current_user)
      attendance.users << current_user
    end
    redirect_to course_path(@course)
  end
end
