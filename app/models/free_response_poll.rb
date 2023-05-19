class FreeResponsePoll < Poll
  def new_response(h={})
    PollResponse.new(:type => "FreeResponsePollResponse", :poll => self, **h)
  end

  def responses
    self.poll_responses.group(:response).count
  end
end
