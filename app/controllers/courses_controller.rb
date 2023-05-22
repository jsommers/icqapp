class CoursesController < ApplicationController
  before_action :go_to_current_course, :only => [:index]
  before_action :verify_enrollment, :only => [:show]
  before_action :instructor_index, :only => [:show]

  def index
    @courses = current_user.courses
  end

  def show
    @course = Course.find(params[:id])
    @poll = @course.active_poll
    @question = @course.active_question
    @checked_in = false
    if @course.attendance_today
      @checked_in = @course.attendance_today.checked_in? current_user
    end

    if @poll
      @response = @poll.new_response
      current = PollResponse.where(:poll => @poll, :user => current_user).first
      if !current.nil?
        @response = current
      end
    end
    @activepoll = !!@poll
  end

  def open_attendance
    @course = Course.find(params[:course_id])
    @course.open_attendance
    flash[:notice] = "Opened attendance for today"
    redirect_to course_questions_path(@course) and return
  end

  def close_attendance
    @course = Course.find(params[:course_id])
    @course.close_attendance
    flash[:notice] = "Attendance closed for today"
    redirect_to course_questions_path(@course) and return
  end

  def attendance_report
    @course = Course.find(params[:id])
    redirect_to course_path(@course) if current_user.student? 
    @apolls = @course.attendance.order(:created_at)

    @attendance_matrix = []  
    @apolls.each do |att|
      thisrow = [ att.created_at.strftime("%Y-%m-%d") ]
      @course.students.each do |s|
        thisrow << att.users.where(:id => s.id).count
      end
      sum = thisrow[1..].sum
      thisrow << "#{sum} / #{thisrow.length-1}"
      @attendance_matrix << thisrow
    end
  end

  def question_report
    @course = Course.find(params[:id])
    redirect_to course_path(@course) if current_user.student? 

    pollids = @course.questions.where.not(:type => "AttendanceQuestion").joins(:polls).select("polls.id")

    @response_matrix = []  
    pollids.each do |pid|
      q = Poll.find(pid.id).question
      responseset = PollResponse.where(:poll_id => pid.id).joins(:user)
      thisrow = [ q.created_at.strftime("%Y-%m-%d"), q.id, pid.id, q.type[0] ]

      @course.students.each do |s|
        resp = responseset.where(:user_id => s.id).first 
        if resp
          thisrow << (q.answer ? (q.answer == resp.response ? "1" : "0") : "!")
        else
          thisrow << "-"
        end
      end
      @response_matrix << thisrow
    end
  end

 def create_and_activate
   course = params[:c]
   question = params[:q]
   answer = params[:a]
   opts = params[:o]
   numopts = params[:n].to_i
   t = params[:t] || 'm' # m, n, f
   t = t.to_sym
   @course = Course.where(:name => course).first
   if !@course
     flash[:notice] = "Course #{course} doesn't exist"
     redirect_to courses_path and return
   end

   @question = Question.new
   qtypes = {:m => MultiChoiceQuestion, :n => NumericQuestion, :f => FreeResponseQuestion }
   qt = qtypes[t]
   if qt.nil?
     flash[:notice] = "Question type #{params[:t]} doesn't exist"
     redirect_to course_path(@course) and return
   end

   if question.nil?
     flash[:notice] = "No question text given!"
     redirect_to course_path(@course) and return
   end

   @question = qt.send(:new)
   @question.answer = answer
   @question.qname = question
   if t == :m
     if opts
       optstr = opts.lines.join('<br>')
       @question.content = %Q{<div class-"trix-content">#{optstr}</div>}
     else
       alpha = ('A'..'J').to_a
       @question.content.body = '<div class="trix-content">' + alpha[0...numopts].join('<br>') + '</div>'
     end
   end

   @question.course = @course
   if !@question.save
     flash[:alert] = "Failed to save question #{question}"
     redirect_to course_questions_path(@course) and return
   end

   # close all other polls
   Poll.closeall(@course)
   num = @question.polls.maximum(:round).to_i
   @poll = @question.new_poll
   @poll.isopen = true
   @poll.round = num + 1
   if !@poll.save
     flash[:alert] = "Failed to save poll for question #{question}"
     redirect_to course_question_path(@course, @question) and return
   end

   flash[:notice] = "Started new poll"
   redirect_to course_question_poll_path(@course, @question, @poll) and return
 end

private

  def go_to_current_course
    return if current_user.admin?

    current_user.courses.each do |c|
      # if course is going on now, then return show page path for redirect
      if c.now?
        redirect_to course_path(c) and return
      end
    end
    # fall-through on index if there's no specific course to redirect to
  end

  def verify_enrollment
    @course = Course.find(params[:id])
    if !current_user.courses.include? @course
      errortype = if current_user.student? 
        'enrolled in' 
      else 
        'an instructor of' 
      end
      flash[:notice] = "You're not #{errortype} #{@course.name}"
      redirect_to courses_path and return
    end
  end

  def instructor_index
    if current_user.admin? 

      redirect_to course_questions_path(params[:id]) and return
    end
  end

end
