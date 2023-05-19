class NumericPollResponse < PollResponse
  def response
    read_attribute(:response).to_f
  end
end
