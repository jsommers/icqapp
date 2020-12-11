class User < ApplicationRecord
  devise :database_authenticatable, 
         :omniauthable, omniauth_providers: [:google_oauth2]

  validates :email, presence: true, uniqueness: true

  has_and_belongs_to_many :courses
  has_many :poll_responses, :dependent => :destroy
  has_many :polls, :through => :poll_responses

  def self.from_omniauth(access_token)
    data = access_token.info
    user = User.where(email: data['email']).first
  end

  def student?
    return !self.admin
  end
  
  
  def get_active_class
    @user_classes = Course.where('id != -1')
    @user_classes.each do |c|
      if c.now? && c.students.include?(self)
        return c
      end
    end
    return nil
  end
  
  def has_active_class?
    @class = self.get_active_class
    return @class != nil
  end
end
