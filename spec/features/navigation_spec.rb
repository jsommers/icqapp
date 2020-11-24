require 'rails_helper'

RSpec.feature "NavigationFeatures", type: :feature do
  include Devise::Test::IntegrationHelpers
  describe "Try out navigation features" do
      before (:each) do
          @student = FactoryBot.create(:student)
          sign_in @student
          @c = FactoryBot.create(:course)
        end
    
    it "should not see current question button if the student does not have an active course" do
        visit courses_path
        allow(@c).to receive(:now?) {false}
        allow(@student).to receive(:has_active_class?) {false}
        expect(page.text).to_not match("Current question")
    end
    
    it "should see current question button if the student does have an active course" do
        visit courses_path
        user = instance_double("User")
        sign_in user
        allow(@c).to receive(:now?) {true}
        allow(user).to receive(:has_active_class?) {true}
        expect(page.text).to match("Current question")
    end
    
    it "should see a button that will rediect to main list of courses" do
        visit course_questions_path(@c)
        expect(page.text).to match("My courses")
        click_on "My courses"
        expect(page.current_path).to eq(courses_path)
    end
    
    end
end