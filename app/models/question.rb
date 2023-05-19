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

protected
  def content_length
    if content.to_plain_text.length < 3
      errors.add(:content, "missing sufficient length")
    end
  end

  def prompt; end
end
