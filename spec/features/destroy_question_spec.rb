require 'rails_helper'

RSpec.feature "NewQuestions", type: :feature do
  include Devise::Test::IntegrationHelpers

  describe "destroy a question", js: true do
    before (:each) do
      admin = FactoryBot.create(:admin)
      @c = FactoryBot.create(:course)
      @c.instructors << admin
      sign_in admin
    end

    it "should succeed if qname is included for numeric response" do
      visit course_questions_path(@c)
      click_on "Create a new question"
      fill_in "question_qname", :with => "NEWQ"
      select "NumericQuestion", from: "question_type"
      find("trix-editor").set("question content")
      click_on "Create Question"
      expect(page.text).to match(/NEWQ/)
      expect(page.current_path).to eq(course_questions_path(@c))
      click_on "Delete"
      expect(page.text).to match(/NEWQ destroyed/)
      expect(page.current_path).to eq(course_questions_path(@c))
    end
  end
end
