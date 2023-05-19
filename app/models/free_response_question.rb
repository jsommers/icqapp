class FreeResponseQuestion < Question
  def new_poll(h={})
    Poll.new(:type => "FreeResponsePoll", :question => self, **h)
  end

  def prompt
    "Enter a text response"
  end
end
