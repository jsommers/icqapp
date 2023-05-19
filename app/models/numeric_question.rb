class NumericQuestion < Question
  def new_poll(h={})
    Poll.new(:type => "NumericPoll", :question => self, **h)
  end

  def prompt
    "Enter a number"
  end
end
