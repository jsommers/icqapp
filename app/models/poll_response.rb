class PollResponse < ApplicationRecord
  belongs_to :user
  belongs_to :poll
  validates_associated :user
  
  
  def is_right?()
    if self.response!=nil
      @current_poll = Poll.where("id = ?", self.poll_id).first
      @current_question = Question.where("id = ?",@current_poll.question_id).first
      if @current_question.answer == self.response
        return true
      end
    else 
      return false
    end
  end
  
end

class MultiChoicePollResponse < PollResponse
end

class FreeResponsePollResponse < PollResponse
end

class NumericPollResponse < PollResponse
  def response
    read_attribute(:response).to_f
  end
end

class AttendancePollResponse < PollResponse
end
