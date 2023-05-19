class NumericPoll < Poll
  def new_response(h={})
    PollResponse.new(:type => "NumericPollResponse", :poll => self, **h)
  end

  def responses
    h = Hash.new(0)
    self.poll_responses.select(:response).each { |r| h[r.response] += 1 }
    h
  end
end
