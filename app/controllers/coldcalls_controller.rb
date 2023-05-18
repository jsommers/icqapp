class ColdcallsController < ApplicationController
  before_action :redirect_if_student

  def edit
    @course = Course.find(params[:course_id])
    @coldcalls = ColdCall.where(course: params[:course_id])
  end

  def update
    @course = Course.find(params[:course_id])
    user = user_param
    @coldcalls = ColdCall.where(course: params[:course_id])
    cc = ColdCall.where(course: params[:course_id], user: user).first
    count = count_param
    cc.count = count
    if cc.save
      flash[:notice] = "Cold call count updated for #{user_email}"
      render 'edit'
    else
      flash[:alert] = "Error saving updated count for user #{user_email}"
      render 'edit'
    end
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
