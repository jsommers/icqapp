class Attendance < ApplicationRecord
    belongs_to :course
    has_and_belongs_to_many :users

    after_commit :update_attendance

    def checked_in?(student)
      self.users.include? student
    end

    protected

    def update_attendance
      broadcast_replace_later_to 'attendance_channel', partial: 'courses/attendance', target: 'attendance_checkin', locals: {course: self.course, checked_in: nil}
    end

end
