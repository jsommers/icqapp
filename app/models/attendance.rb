class Attendance < ApplicationRecord
    belongs_to :course
    has_and_belongs_to_many :users

    def checked_in?(student)
      self.users.include? student
    end
end
