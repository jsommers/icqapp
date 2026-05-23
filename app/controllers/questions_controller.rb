class QuestionsController < ApplicationController
  before_action :verify_course_enrollment
  before_action :redirect_if_student, only: [:new, :create, :destroy]

  def index
    @questions = @course.questions.order(:type)
    if !current_user.admin?
      render 'student_index' and return
    end
  end

  def new
    @question = Question.new
  end

  def create
    @question = @course.questions.create(create_update_params)
    if @question.persisted?
      flash[:notice] = "#{@question.qname} created"
      redirect_to course_questions_path(@course)
    else
      msg = @question.errors.full_messages.join('; ')
      @question = Question.new
      flash[:warning] = "No question created: #{msg}"
      redirect_to new_course_question_path(@course) and return
    end
  end

  def destroy
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
