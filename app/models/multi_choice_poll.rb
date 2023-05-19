class MultiChoicePoll < Poll
  def new_response(h={})
    PollResponse.new(:type => "MultiChoicePollResponse", :poll => self, **h)
  end

  def options
    self.question.content.to_plain_text.split
  end

  def responses
    outhash = {}
    h = self.poll_responses.group(:response).count
    opts = self.options
    0.upto(opts.length-1) do |i|
      outhash[opts[i]] = h[opts[i]].to_i
    end
    outhash
  end
end
