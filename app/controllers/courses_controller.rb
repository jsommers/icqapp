class CoursesController < ApplicationController
  before_action :go_to_current_course, only: [:index]
  before_action :verify_course_enrollment, only: [:show, :open_attendance, :close_attendance, :attendance_report, :question_report]
  before_action :instructor_index, only: [:show]
  before_action :redirect_if_student, only: [:open_attendance, :close_attendance, :create_and_activate, :attendance_report, :question_report]

  def index
    @courses = current_user.courses
  end

  def show
    @poll = @course.active_poll
    @question = @course.active_question
    att = @course.attendance_today
    @checked_in = att ? att.checked_in?(current_user) : false

    if @poll
      @response = @poll.new_response
      current = PollResponse.find_by(poll: @poll, user: current_user)
      @response = current if current
    end
    @activepoll = !!@poll
  end

  def open_attendance
    @course.open_attendance
    flash[:notice] = "Opened attendance for today"
    redirect_to course_questions_path(@course)
  end

  def close_attendance
    @course.close_attendance
    flash[:notice] = "Attendance closed for today"
    redirect_to course_questions_path(@course)
  end

  def attendance_report
    @apolls = @course.attendance.order(:created_at).includes(:users)
    students = @course.students.to_a
    student_summary = Hash.new(0)

    @attendance_matrix = @apolls.map do |att|
      checked_in_ids = att.users.map(&:id).to_set
      thisrow = [att.created_at.strftime("%Y-%m-%d")]
      students.each do |s|
        stdcount = checked_in_ids.include?(s.id) ? 1 : 0
        thisrow << stdcount
        student_summary[s.email] += stdcount
      end
      sum = thisrow[1..].sum
      thisrow << "#{sum} / #{thisrow.length - 1}"
      thisrow
    end

    lastrow = ['']
    students.each { |s| lastrow << "#{student_summary[s.email]} / #{@apolls.count}" }
    lastrow << ' '
    @attendance_matrix << lastrow
  end

  def question_report
    students = @course.students.to_a

    polls = Poll.joins(:question)
                .where(questions: { course_id: @course.id })
                .where.not(questions: { type: "AttendanceQuestion" })
                .includes(:question, :poll_responses)
                .order("questions.created_at")

    @response_matrix = polls.map do |poll|
      q = poll.question
      responses_by_user = poll.poll_responses.group_by(&:user_id)
      thisrow = [q.created_at.strftime("%Y-%m-%d"), q.id, poll.id, q.type[0]]
      students.each do |s|
        resp = responses_by_user[s.id]&.first
        thisrow << if resp
          q.answer ? (q.answer == resp.response ? "1" : "0") : "!"
        else
          "-"
        end
      end
      thisrow
    end
  end

  def create_and_activate
    course = params[:c]
    question = params[:q]
    answer = params[:a]
    opts = params[:o]
    numopts = params[:n].to_i
    t = params[:t] || 'm'
    t = t.to_sym
    @course = Course.find_by(name: course)
    if !@course
      flash[:notice] = "Course #{course} doesn't exist"
      redirect_to courses_path and return
    end

    unless current_user.courses.exists?(id: @course.id)
      flash[:notice] = "You're not an instructor of #{@course.name}"
      redirect_to courses_path and return
    end

    qtypes = { m: MultiChoiceQuestion, n: NumericQuestion, f: FreeResponseQuestion }
    qt = qtypes[t]
    if qt.nil?
      flash[:notice] = "Question type #{params[:t]} doesn't exist"
      redirect_to course_path(@course) and return
    end

    if question.nil?
      flash[:notice] = "No question text given!"
      redirect_to course_path(@course) and return
    end

    @question = qt.new
    @question.answer = answer
    @question.qname = question
    if t == :m
      if opts
        optstr = opts.lines.join('<br>')
        @question.content = %Q{<div class="trix-content">#{optstr}</div>}
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
    redirect_to course_question_poll_path(@course, @question, @poll)
  end

private

  def go_to_current_course
    return if current_user.admin?

    current_user.courses.each do |c|
      if c.now?
        redirect_to course_path(c) and return
      end
    end
  end

  def instructor_index
    redirect_to course_questions_path(@course) if current_user.admin?
  end
end
