require 'rails_helper'

RSpec.feature "PollActivates", type: :feature do
  include Devise::Test::IntegrationHelpers
  
  describe "active poll for admin", js: false do 
    it "should allow for cold calling after poll is closed" do
      c = FactoryBot.create(:course)
      q = FactoryBot.build(:numeric_question, :qname => "Q1", :content => "question", :course => c)
      c.questions << q
      q.save
      p = q.new_poll(:isopen => true, :round => 1)
      p.save
      admin = FactoryBot.create(:admin)
      student = FactoryBot.create(:student)
      c.students << student
      c.instructors << admin
      sign_in admin
      visit course_question_poll_path(c, q, p)
      expect(page.text).to match(/Q1/)
      click_on "Cold call"
      expect(page.text).to match(/Random student: student\d+@colgate.edu/)
    end
  end

  describe "active poll visibility for student", js: false do
    it "an active numeric poll should be visible" do
      c = FactoryBot.create(:course)
      q = FactoryBot.build(:numeric_question, :qname => "Q1", :content => "question", :course => c)
      c.questions << q
      q.save
      p = q.new_poll(:isopen => true, :round => 1)
      p.save

      student = FactoryBot.create(:student)
      c.students << student
      c.instructors << admin
      sign_in student
      visit course_path(c)
      expect(page.text).to match(/Q1/)
      fill_in "response", :with => 1.0
      click_on "Enter a number"
      expect(page.current_path).to eq(course_path(c))
      expect(PollResponse.find(1).response).to eq(1.0)
    end

    it "an active numeric poll should be notifiable" do
      c = FactoryBot.create(:course)
      q = FactoryBot.build(:numeric_question, :qname => "Q1", :content => "question", :course => c)
      c.questions << q
      q.save
      p = q.new_poll(:isopen => true, :round => 1)
      p.save

      admin = FactoryBot.create(:admin)
      c.instructors << admin
      sign_in admin
      visit course_question_poll_path(c, q, p)
      expect(page.text).to match(/Q1/)
      #assert_emails 1 do
        click_on "Notify"
      #end
    end

    it "an active free response should be visible" do
      c = FactoryBot.create(:course)
      q = FactoryBot.build(:free_response_question, :qname => "Q1", :content => "question", :course => c)
      c.questions << q
      q.save
      p = q.new_poll(:isopen => true, :round => 1)
      p.save

      student = FactoryBot.create(:student)
      c.students << student
      sign_in student
      visit course_path(c)
      expect(page.text).to match(/Q1/)
      fill_in "response", :with => "some text"
      click_on "Enter a text response"
      expect(page.current_path).to eq(course_path(c))
      expect(PollResponse.find(1).response).to eq("some text")
    end

    it "an active multiple choice question should be visible" do
      c = FactoryBot.create(:course)
      q = FactoryBot.build(:multi_choice_question, :qname => "Q1", :content => "one\ntwo\nthree\nfour", :course => c)
      c.questions << q
      q.save
      p = q.new_poll(:isopen => true, :round => 1)
      p.save

      student = FactoryBot.create(:student)
      c.students << student
      sign_in student
      visit course_path(c)
      expect(page.text).to match(/Q1/)
      choose "response_two"
      click_on "Select one option"
      expect(page.current_path).to eq(course_path(c))
      expect(PollResponse.find(1).response).to eq("two")
    end

    it "update an multiple choice question with another response" do
      c = FactoryBot.create(:course)
      q = FactoryBot.build(:multi_choice_question, :qname => "Q1", :content => "one\ntwo\nthree\nfour", :course => c)
      c.questions << q
      q.save
      p = q.new_poll(:isopen => true, :round => 1)
      p.save

      student = FactoryBot.create(:student)
      c.students << student
      sign_in student
      visit course_path(c)
      expect(page.text).to match(/Q1/)
      choose "response_two"
      click_on "Select one option"
      expect(page.current_path).to eq(course_path(c))
      expect(PollResponse.find(1).response).to eq("two")

      choose "response_four"
      click_on "Select one option"
      expect(page.current_path).to eq(course_path(c))
      expect(PollResponse.find(1).response).to eq("four")
    end

    it "no poll should be visible if none are active" do
      c = FactoryBot.create(:course)
      q = FactoryBot.build(:numeric_question, :qname => "Q1", :content => "question", :course => c)
      c.questions << q
      q.save
      p = q.new_poll(:isopen => false, :round => 1)
      p.save

      student = FactoryBot.create(:student)
      c.students << student
      sign_in student
      visit course_path(c)
      expect(page.text).to match(/no question/i)
    end      
  end
end
