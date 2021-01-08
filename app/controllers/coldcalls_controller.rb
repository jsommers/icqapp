class ColdcallsController < ApplicationController
  before_action :redirect_if_student

  def edit
    @course = Course.find(params[:course_id])
    @coldcalls = ColdCall.where(course: params[:course_id])
  end

  def update
    @course = Course.find(params[:course_id])
    @coldcalls = ColdCall.where(course: params[:course_id])
  end
end
