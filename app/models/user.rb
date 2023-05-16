class User < ApplicationRecord
  devise :database_authenticatable, 
         :omniauthable, omniauth_providers: [:google_oauth2]

  validates :email, presence: true, uniqueness: true
  has_and_belongs_to_many :courses

  #has_and_belongs_to_many :attendances
  #has_many :poll_responses, :dependent => :destroy
  #has_many :polls, :through => :poll_responses

  scope :students, ->() { where(admin: false).order(:email) }
  scope :instructors, ->() { where(admin: true).order(:email) }

  def self.from_omniauth(access_token)
    data = access_token.info
    user = User.where(email: data['email']).first
  end

  def student?
    !admin
  end

  def instructor?
    admin
  end
end
