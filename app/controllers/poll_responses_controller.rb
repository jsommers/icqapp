class PollResponsesController < ApplicationController
  before_action :verify_course_enrollment

  def create
    @question = Question.find(params[:question_id])
    @poll = Poll.find(params[:poll_id])

    if !@poll.isopen
      flash[:alert] = "Poll is not open"
      redirect_to course_path(@course) and return
    end

    @activepoll = true
    @poll_response = @poll.poll_responses.find_by(user: current_user)
    @poll_response ||= @poll.new_response(user: current_user)
    @poll_response.response = params[:response]
    if @poll_response.save
      flash[:notice] = "Response recorded"
      respond_to do |format|
        format.html { redirect_to course_path(@course) }
        format.turbo_stream
      end
    else
      flash[:alert] = "Saving response failed"
      respond_to do |format|
        format.html { redirect_to course_path(@course) }
        format.turbo_stream
      end
    end
  end
end
