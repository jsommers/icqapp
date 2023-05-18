require 'rails_helper'

RSpec.feature "NewQuestions", type: :feature do
  include Devise::Test::IntegrationHelpers

  describe "create a new question (no js)", js: false do
    before (:each) do
      admin = FactoryBot.create(:admin)
      @c = FactoryBot.create(:course)
      @c.instructors << admin
      sign_in admin
    end

    it "should fail if qname isn't included" do
      visit course_questions_path(@c)
      click_on "Create a new question"
      click_on "Create Question"
      expect(page.current_path).to eq(new_course_question_path(@c))
      expect(page.text).to match(/qname can't be blank/i)
    end

    it "should fail for multichoice question if content isn't included" do
      visit course_questions_path(@c)
      click_on "Create a new question"
      fill_in "question_qname", :with => "A new question"
      select "MultiChoiceQuestion", from: "question_type"
      click_on "Create Question"
      expect(page.current_path).to eq(new_course_question_path(@c))
      expect(page.text).to match(/missing sufficient length/i)
    end
  end

  describe "create a new question (with js)", js: true do
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
      # fill_in "question_content", :with => "question content"
      click_on "Create Question"
      expect(page.text).to match(/NEWQ/)
      expect(page.current_path).to eq(course_questions_path(@c))
    end

    it "should succeed if qname and question are included for free response" do
      visit course_questions_path(@c)
      click_on "Create a new question"
      fill_in "question_qname", :with => "NEWQ"
      select "FreeResponseQuestion", from: "question_type"
      find("trix-editor").set("question content")
      click_on "Create Question"
      expect(page.current_path).to eq(course_questions_path(@c))
      expect(page.text).to match(/NEWQ/)
    end

    it "should succeed if both qname and qcontent are included for multichoice" do
      visit course_questions_path(@c)
      click_on "Create a new question"
      fill_in "question_qname", :with => "NEWQ"
      select "MultiChoiceQuestion", from: "question_type"
      find("trix-editor").set("question content")
      click_on "Create Question"
      expect(page.current_path).to eq(course_questions_path(@c))
      expect(page.text).to match(/NEWQ/)
    end
  end
end
