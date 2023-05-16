class Course < ApplicationRecord
  validates :name, :presence => true
  validates :daytime, :presence => true, :format => { with: /[MTWRF]{2,3} \d{1,2}:\d{2}-\d{1,2}:\d{2}/ }

  has_and_belongs_to_many :students, -> { where admin: false }, class_name: "User"
  has_and_belongs_to_many :instructors, -> { where admin: true}, class_name: "User"

  has_many :questions, :dependent => :destroy
  has_many :attendance, :dependent => :destroy

#  def active_question
#    questions.joins([:polls]).where("polls.isopen = ?", true).first
#  end

  def attendance_taken?
    !self.attendance_today.nil?
  end

  def attendance_active?
    self.attendance_today && self.attendance_today.active
  end

  def attendance_today
    now = Time.now
    self.attendance.where('created_at BETWEEN ? AND ?', Time.new(now.year, now.month, now.day), Time.new(now.year, now.month, now.day, 23, 59, 59)).first
  end

  def open_attendance
    att = self.attendance_today
    if att.nil? 
      att = Attendance.new(:active => true)
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

#  def active_poll
#    Poll.joins(:question).where("polls.isopen = ? AND polls.question_id = questions.id AND questions.course_id = ?", true, self.id).first
#  end

  def now?
    return false unless self.daytime =~ /([MTWRF]{2,3}) (\d{1,2}):(\d{2})-(\d{1,2}):(\d{2})/
    dow = %w{Su M T W R F Sa}
    n = Time.now
    day = dow[n.wday]
    return false if !$1.include? day

    xstart = $2.to_i * 60 + $3.to_i
    xend = $4.to_i * 60 + $5.to_i
    xnow = n.hour * 60 + n.min
    return xnow >= xstart && xnow <= xend 
  end
end
