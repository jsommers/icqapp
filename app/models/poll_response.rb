class PollResponse < ApplicationRecord
  belongs_to :user
  belongs_to :poll
  validates_associated :user
end
