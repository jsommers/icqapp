class ColdcallsController < ApplicationController
  before_action :redirect_if_student

  def index
    @course = Course.find(params[:course_id])
    @coldcalls = ColdCall.where(course: params[:course_id])
  end

  def edit
    @course = Course.find(params[:course_id])
    @coldcall = ColdCall.find(params[:id])
  end

  def update
    @course = Course.find(params[:course_id])
    @coldcall = ColdCall.find(params[:id])
    @coldcall.count = count_param
    if @coldcall.save
      flash[:notice] = "Cold call count updated for #{user_email}"
    else
      flash[:alert] = "Error saving updated count for user #{user_email}"
    end
    redirect_to course_coldcalls_path(@course)
  end

private
  def user_param
    params.require(:user)
  end

  def user_email
    params.require(:email)
  end

  def count_param
    params.require(:count)
  end
end
