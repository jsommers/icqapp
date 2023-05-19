class ColdCall < ApplicationRecord
  belongs_to :user
  belongs_to :course
  validates :count, numericality: { greater_than_or_equal_to: 0 }

  def self.random_student(course)
    # assumes that student has been initialized in cold_calls table with count of 0
    # NB: happens as a callback in Course when student is associated
    mincount = ColdCall.where(course: course).minimum(:count).to_i
    cc = ColdCall.where(course: course, count: mincount)
    lucky = User.find(cc.shuffle()[0].user_id)
    cc = ColdCall.where(course: course, user: lucky).first
    cc.count += 1
    cc.save
    lucky
  end
end
