class QuestionsController < ApplicationController
  before_action :redirect_if_student, :only => [:new, :create, :destroy]

  def index
    @course = Course.find(params[:course_id])    
    @questions = @course.questions.order(:type)
    if !current_user.admin?
      render 'student_index' and return
    end
  end

  def new
    @course = Course.find(params[:course_id])    
    @question = Question.new
  end

  def create
    @course = Course.find(params[:course_id])    
    @question = @course.questions.create(create_update_params)
    if @question.persisted?
      respond_to do |format|
        format.html do
          flash[:notice] = "#{@question.qname} created"
          redirect_to course_questions_path(@course) and return
        end
        format.turbo_stream 
      end
    else
      msg = @question.errors.full_messages.join('; ')
      @question = Question.new
      flash[:warning] = "No question created: #{msg}"
      redirect_to new_course_question_path(@course, @question) and return
    end
  end

  def destroy
    @course = Course.find(params[:course_id])    
    q = @course.questions.find(params[:id])
    q.destroy
    flash[:notice] = "#{q.qname} destroyed"
    redirect_to course_questions_path(@course)
  end

private
  def create_update_params
    params.require(:question).permit(:qname, :type, :content, :answer)
  end
end
