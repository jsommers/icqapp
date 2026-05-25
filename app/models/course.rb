class Course < ApplicationRecord
  validates :name, :presence => true
  validates :daytime, presence: true, format: { with: /[MTWRF]{1,3} \d{1,2}:\d{2}-\d{1,2}:\d{2}/ }

  has_and_belongs_to_many :students, -> { where(admin: false) }, class_name: "User",
      after_add: :create_coldcall, after_remove: :remove_coldcall
  has_and_belongs_to_many :instructors, -> { where(admin: true) }, class_name: "User"

  has_many :questions, dependent: :destroy
  has_many :attendance, dependent: :destroy
  has_many :cold_calls, dependent: :destroy

  def active_question
    questions.joins([:polls]).where("polls.isopen = ?", true).first
  end

  def attendance_taken?
    !self.attendance_today.nil?
  end

  def attendance_active?
    self.attendance_today && self.attendance_today.active
  end

  def attendance_today
    self.attendance.where(created_at: Time.current.all_day).first
  end

  def attendance_for(m, d, year: Time.current.year)
    date = Time.zone.local(year, m, d)
    self.attendance.where(created_at: date.all_day).first
  end

  def open_attendance
    att = self.attendance_today
    if att.nil?
      att = Attendance.new(active: true)
      self.attendance << att
    end
    att.active = true
    att.save
  end

  def close_attendance
    att = self.attendance_today
    if att
      att.active = false
      att.save
    end
  end

  def active_poll
    Poll.joins(:question).where("polls.isopen = ? AND polls.question_id = questions.id AND questions.course_id = ?", true, self.id).first
  end

  def now?
    m = self.daytime.match(/([MTWRF]{1,3}) (\d{1,2}):(\d{2})-(\d{1,2}):(\d{2})/)
    return false unless m
    dow = %w{Su M T W R F Sa}
    n = Time.now
    day = dow[n.wday]
    return false unless m[1].include?(day)

    xstart = m[2].to_i * 60 + m[3].to_i
    xend   = m[4].to_i * 60 + m[5].to_i
    xnow   = n.hour * 60 + n.min
    xnow >= xstart && xnow <= xend
  end

  def create_coldcall(student)
    ColdCall.create!(course: self, user: student, count: 0)
  end

  def remove_coldcall(student)
    ColdCall.where(course: self, user: student).first&.destroy
  end
end
