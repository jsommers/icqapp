require 'rails_helper'

RSpec.feature "QuestionIndices", type: :feature do
  include Devise::Test::IntegrationHelpers
  describe "question#index" do
    it "should allow an admin to see course questions" do
      admin = FactoryBot.create(:admin)
      sign_in admin
      c = FactoryBot.create(:course)
      c.instructors << admin
      q = FactoryBot.build(:numeric_question, :qname => "Q1")
      c.questions << q
      q.save!
      visit course_questions_path(c)
      ymd = Time.now.strftime "%Y/%m/%d"
      expect(page.text).to match(/Q1.*#{ymd}/im)
    end
  end
end
