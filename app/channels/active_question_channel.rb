class ActiveQuestionChannel < ApplicationCable::Channel
  def subscribed
    stream_from 'active_question'
  end

  def unsubscribed
  end

  def question_update
  end
end
