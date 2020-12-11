require 'rails_helper'

RSpec.feature "NewQuestions", type: :feature do
  include Devise::Test::IntegrationHelpers

  describe "create a new question" do
    before (:each) do
      admin = FactoryBot.create(:admin)
      sign_in admin
      @c = FactoryBot.create(:course)
    end

    it "should fail if qname isn't included" do
      visit course_questions_path(@c)
      click_on "Create a new question"
      click_on "Create question"
      expect(page.current_path).to eq(new_course_question_path(@c))
      expect(page.text).to match(/qname can't be blank/i)
    end

    it "should fail for multichoice question if qcontent isn't included" do
      visit course_questions_path(@c)
      click_on "Create a new question"
      fill_in "question_qname", :with => "A new question"
      select "MultiChoiceQuestion", from: "question_type"
      click_on "Create question"
      expect(page.current_path).to eq(new_course_question_path(@c))
      expect(page.text).to match(/qcontent missing newline-separated options for multichoice question/i)
    end

    it "should succeed if qname is included for numeric response" do
      visit course_questions_path(@c)
      click_on "Create a new question"
      fill_in "question_qname", :with => "NEWQ"
      select "NumericQuestion", from: "question_type"
      click_on "Create question"
      expect(page.current_path).to eq(course_questions_path(@c))
      expect(page.text).to match(/NEWQ/)
    end

    it "should succeed if qname and image are included for free response" do
      visit course_questions_path(@c)
      click_on "Create a new question"
      fill_in "question_qname", :with => "NEWQ"
      select "FreeResponseQuestion", from: "question_type"
      attach_file('Image', 'testimg.png')
      click_on "Create question"
      expect(page.current_path).to eq(course_questions_path(@c))
      expect(page.text).to match(/NEWQ/)
    end

    it "should succeed if both qname and qcontent are included for multichoice" do
      visit course_questions_path(@c)
      click_on "Create a new question"
      fill_in "question_qname", :with => "NEWQ"
      fill_in "question_qcontent", :with => "a\nb\nc"
      select "MultiChoiceQuestion", from: "question_type"
      click_on "Create question"
      expect(page.current_path).to eq(course_questions_path(@c))
      expect(page.text).to match(/NEWQ/)
    end
    
    it "should display the options inputs for multichoice" do
      visit course_questions_path(@c)
      click_on "Create a new question"
      select "MultiChoiceQuestion", from: "question_type"
      expect(page).to have_css("button#add_option")
      expect(page).to have_content("Options:")
    end
    
    it "should add another option field when add option is clicked for multichoice" do
      visit course_questions_path(@c)
      click_on "Create a new question"
      select "MultiChoiceQuestion", from: "question_type"
      click_on "Add Option"
      expect(page).to have_css("span#optspan1")
    end
    
    
    it "should display remove option button after an option has been added" do
      visit course_questions_path(@c)
      click_on "Create a new question"
      select "MultiChoiceQuestion", from: "question_type"
      expect(page).not_to have_css("button#remove_option")
      click_on "Add Option"
      expect(page).to have_css("button#remove_option")
    end
    
    it "should remove the last option field if remove option is clicked" do 
      visit course_questions_path(@c)
      click_on "Create a new question"
      select "MultiChoiceQuestion", from: "question_type"
      click_on "Add Option"
      click_on "Add Option"
      click_on "Remove Option"
      expect(page).not_to have_css("span#optspan2")
    end
    
    it "should not show remove option button if there are currently no option input fields" do 
      visit course_questions_path(@c)
      click_on "Create a new question"
      select "MultiChoiceQuestion", from: "question_type"
      click_on "Add Option"
      click_on "Add Option"
      click_on "Remove Option"
      click_on "Remove Option"
      expect(page).not_to have_css("button#remove_option")
    end
    
    
    it "should not display the options inputs for numeric" do
      visit course_questions_path(@c)
      click_on "Create a new question"
      select "NumericQuestion", from: "question_type"
      expect(page).not_to have_css("button#add_option")
      expect(page).not_to have_content("Options:")
    end
    
    it "should display correct answer input for numeric" do
      visit course_questions_path(@c)
      click_on "Create a new question"
      select "NumericQuestion", from: "question_type"
      expect(page).to have_css("input#question_answer")
      expect(page).to have_content("Correct answer")
    end
    
    it "should not display the options or correct answer inputs for free response" do
      visit course_questions_path(@c)
      click_on "Create a new question"
      select "FreeResponseQuestion", from: "question_type"
      expect(page).not_to have_css("button#add_option")
      expect(page).not_to have_content("Options:")
      expect(page).not_to have_css("input#question_answer")
      expect(page).not_to have_content("Correct answer")
    end
    
    
    
  end
end
