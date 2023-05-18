class PollsController < ApplicationController
  before_action :redirect_if_student

  def index
    @course = Course.find(params[:course_id])
    @question = Question.find(params[:question_id])
    @polls = @question.polls
  end

  def show
    @course = Course.find(params[:course_id])
    @question = Question.find(params[:question_id])
    @poll = Poll.find(params[:id])
    if params[:coldcall] 
      @lucky = ColdCall.random_student(@course)
      flash[:notice] = "Random student: #{@lucky.email}"
    end
    @qoptionspacked = @poll.responses.keys.join('!!!!!')
    @presponsespacked = @poll.responses.values.join('!!!!!')
  end

  def notify
    @poll = Poll.find(params[:id])
    @question = @poll.question
    @course = @question.course
    PollNotifyMailer.with(user: current_user, poll: @poll).notify_email.deliver_now
    redirect_to course_question_poll_path(@course, @question, @poll) and return
  end

  def create
    @course = Course.find(params[:course_id])
    @question = Question.find(params[:question_id])
    Poll.closeall(@course)
    num = @question.polls.maximum(:round).to_i
    @poll = @question.new_poll
    @poll.isopen = true
    @poll.round = num + 1
    if @poll.save
      flash[:notice] = "Poll started for #{@question.qname}"
      redirect_to course_question_poll_path(@course, @question, @poll)
    else
      flash[:warning] = "Failed to start poll for #{@question.qname}"
      redirect_to course_questions_path(@course)
    end
  end

  def update
    @course = Course.find(params[:course_id])
    @question = Question.find(params[:question_id])
    @poll = Poll.find(params[:id])
    @poll.update(:isopen => false)
    flash[:notice] = "Poll stopped for #{@question.qname}"
    redirect_to course_question_poll_path(@course, @question, @poll)
  end

  def destroy
    @course = Course.find(params[:course_id])
    @question = Question.find(params[:question_id])
    @poll = Poll.find(params[:id])
    @poll.destroy
    flash[:notice] = "Poll #{@poll.round} for #{@question.qname} destroyed"
    redirect_to course_question_polls_path(@course, @question)
  end
end
