class MultiChoiceQuestion < Question
  def new_poll(h={})
    Poll.new(:type => "MultiChoicePoll", :question => self, **h)
  end

  def prompt
    "Submit response"
  end
end
