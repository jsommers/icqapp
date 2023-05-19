class ColdCallsController < ApplicationController
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
    respond_to do |format|
      if @coldcall.save
        format.html { 
          redirect_to course_cold_calls_path(@course), notice: "Cold call count updated for #{user_email}" }
        format.turbo_stream { render turbo_stream: turbo_stream.replace(@coldcall) }
      else
        format.html { 
          redirect_to course_cold_calls_path(@course), alert: "Error saving updated count for user #{user_email}" }
      end
    end
  end

private
  def user_email
    params.require(:email)
  end

  def count_param
    params.require(:count)
  end
end
