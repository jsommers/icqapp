class Poll < ApplicationRecord
  belongs_to :question
  has_many :poll_responses, :dependent => :destroy
  has_many :users, :through => :poll_responses

  validates_associated :question

  # on create/update: broadcast to active question
  after_create_commit :activate_question
  after_update_commit :deactivate_question

  def self.closeall(course)
    Poll.joins(:question).where("polls.isopen = ? AND polls.question_id = questions.id AND questions.course_id = ?", true, course.id).update_all(:isopen => false)
  end


  protected
  def activate_question
    pr = self.new_response.save
    broadcast_replace_later_to 'active_question', partial: 'courses/activequestion', target: 'activequestion', locals: {course: self.question.course, question: self.question, poll: self, poll_response: pr, activepoll: true}
  end

  def deactivate_question
    broadcast_replace_later_to 'active_question', partial: 'courses/activequestion', target: 'activequestion', locals: {course: self.question.course, question: self.question, poll: self, activepoll: false}
  end
end
