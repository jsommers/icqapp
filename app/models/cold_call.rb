class ColdCall < ApplicationRecord
  belongs_to :user
  belongs_to :course
  validates :count, numericality: { greater_than_or_equal_to: 0 }

  def self.random_student(course)
    mincount = ColdCall.where(course: course).minimum(:count).to_i
    candidates = ColdCall.where(course: course, count: mincount).to_a
    return nil if candidates.empty?

    lucky_cc = candidates.sample
    lucky_cc.increment!(:count)
    lucky_cc.user
  end
end
