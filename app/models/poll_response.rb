class PollResponse < ApplicationRecord
  belongs_to :user
  belongs_to :poll
  validates_associated :user

  after_commit :update_poll_responses

  protected

  def update_poll_responses
    broadcast_replace_later_to 'poll_responses', partial: 'polls/poll_response_count', target: 'poll_response_count', locals: {poll_response_count: self.poll.poll_responses.count } 
  end
end
