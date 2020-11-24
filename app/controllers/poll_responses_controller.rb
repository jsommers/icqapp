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

    r = @poll.poll_responses.where(:user => current_user).first
  
    if !r
      r = @poll.new_response(:user => current_user)
    end
    r.response = params[:response]
    if r.save
      if @question.type == "AttendanceQuestion"
        flash[:notice] = "Attendance recorded!"
        redirect_to courses_path and return
      else 
        flash[:notice] = "Response recorded!"
      end
    else
      flash[:notice] = "Saving response failed"
    end
    if request.xhr?
      render json: {:message => "Response recorded" } and return
    else
      redirect_to course_path(@course) and return
    end
  end
end
