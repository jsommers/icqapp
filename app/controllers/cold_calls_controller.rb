class ColdCallsController < ApplicationController
  before_action :verify_course_enrollment
  before_action :redirect_if_student

  def index
    @coldcalls = ColdCall.where(course: @course)
  end

  def edit
    @coldcall = ColdCall.find(params[:id])
  end

  def update
    @coldcall = ColdCall.find(params[:id])
    respond_to do |format|
      if @coldcall.update(cold_call_params)
        format.html {
          redirect_to course_cold_calls_path(@course), notice: "Cold call count updated for #{@coldcall.user.email}" }
        format.turbo_stream { render turbo_stream: turbo_stream.replace(@coldcall) }
      else
        format.html {
          redirect_to course_cold_calls_path(@course), alert: "Error saving updated count for user #{@coldcall.user.email}" }
      end
    end
  end

private

  def cold_call_params
    params.require(:cold_call).permit(:count)
  end
end
