class PollResponsesController < ApplicationController

  def create
    @course = Course.find(params[:course_id])

    if !@course.students.include? current_user
      flash[:alert] = "You aren't enrolled in #{@course.name}.  If that is a mistake, please contact the administrator."
      redirect_to courses_path and return
    end

    @question = Question.find(params[:question_id])
    @poll = Poll.find(params[:poll_id])

    if !@poll.isopen
      flash[:alert] = "Poll is not open"
      redirect_to course_path(@course) and return
    end

    @activepoll = true
    @poll_response = @poll.poll_responses.where(:user => current_user).first
    if !@poll_response
      @poll_response = @poll.new_response(:user => current_user)
    end
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
