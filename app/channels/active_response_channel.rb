class ActiveResponseChannel < ApplicationCable::Channel
  def subscribed
    stream_from 'active_response'
  end

  def unsubscribed
  end

  def self.update(responsecount)
  end
end
