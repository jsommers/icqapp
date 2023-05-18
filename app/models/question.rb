class Question < ApplicationRecord
  has_rich_text :content

  belongs_to :course
  has_many :polls, :dependent => :destroy
  validates :qname, presence: true
  validates_associated :course
  validate :content_length

  def active_poll
    polls.where(:isopen => true).first
  end

  def poll_responses_for(user)
    user.poll_responses
  end

protected
  def content_length
    if content.to_plain_text.length < 5
      errors.add(:content, "missing sufficient length")
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
