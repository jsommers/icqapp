class Question < ApplicationRecord
  has_rich_text :content

  belongs_to :course
  has_many :polls, :dependent => :destroy
  validates :qname, presence: true
  validates_associated :course
  #validate :options_for_multichoice
  #enum content_type: %i(html markdown plain)
  #has_one_attached :image

  def active_poll
    polls.where(:isopen => true).first
  end

  def poll_responses_for(user)
    user.poll_responses
  end

protected
  def options_for_multichoice
    if type == "MultiChoiceQuestion" and qcontent.length < 2
      errors.add(:qcontent, "missing newline-separated options for multichoice question")
    end
  end

  def prompt; end
end

class MultiChoiceQuestion < Question
  def new_poll(h={})
    Poll.new(:type => "MultiChoicePoll", :question => self, **h)
  end

  def prompt
    "Select one option"
  end
end

class FreeResponseQuestion < Question
  def new_poll(h={})
    Poll.new(:type => "FreeResponsePoll", :question => self, **h)
  end

  def prompt
    "Enter a text response"
  end
end

class NumericQuestion < Question
  def new_poll(h={})
    Poll.new(:type => "NumericPoll", :question => self, **h)
  end

  def prompt
    "Enter a number"
  end
end
