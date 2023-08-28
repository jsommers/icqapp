require 'rails_helper'

RSpec.feature "Attendance", type: :feature do
  include Devise::Test::IntegrationHelpers

  describe "question report spec" do
    it "should show a report for admins (no responses)" do
      admin = FactoryBot.create(:admin)
      sign_in admin
      c = FactoryBot.create(:course)
      s = FactoryBot.create(:student)
      c.students << s
      q = FactoryBot.build(:numeric_question, :qname => "Q1", :course => c)
      c.questions << q
      q.save
      p = q.new_poll(:isopen => false, :round => 1)
      p.save
      visit question_report_path(c)
      expect(page.text).to match(/Question report for A Course/)
    end

    it "should show a report for admins (with response)" do
      admin = FactoryBot.create(:admin)
      sign_in admin
      c = FactoryBot.create(:course)
      s = FactoryBot.create(:student)
      c.students << s
      q = FactoryBot.build(:numeric_question, :qname => "Q1", :course => c)
      c.questions << q
      q.save
      p = q.new_poll(:isopen => false, :round => 1)
      p.save
      pr = p.new_response(:response => "stuff")
      pr.user = s
      pr.save
      visit question_report_path(c)
      expect(page.text).to match(/Question report for A Course/)
    end

    it "should not allow a student to get to the question report" do
      admin = FactoryBot.create(:admin)
      c = FactoryBot.create(:course)
      s = FactoryBot.create(:student)
      c.students << s
      sign_in s
      visit question_report_path(c)
      expect(page.current_path).to eq(courses_path)
    end
  end

  describe "student question report" do
    it "should show past poll responses (no response)" do
      admin = FactoryBot.create(:admin)
      c = FactoryBot.create(:course)
      s = FactoryBot.create(:student)
      sign_in s
      c.students << s
      q = FactoryBot.build(:numeric_question, :qname => "Q1", :course => c)
      c.questions << q
      q.save
      p = q.new_poll(:isopen => false, :round => 1)
      p.save
      visit course_path(c)
      click_on "Review past questions"
      expect(page.current_path).to eq(course_questions_path(c))
      expect(page.text).to match(/Your Response\(s\)/)
      expect(page.text).to match(/No responses/)
    end

    it "should show past poll responses (with response)" do
      admin = FactoryBot.create(:admin)
      c = FactoryBot.create(:course)
      s = FactoryBot.create(:student)
      sign_in s
      c.students << s
      q = FactoryBot.build(:numeric_question, :qname => "Q1", :course => c, :answer => "42")
      c.questions << q
      q.save
      p = q.new_poll(:isopen => false, :round => 1)
      p.save
      pr = p.new_response(response: "42")
      pr.user = s
      pr.save
      visit course_path(c)
      click_on "Review past questions"
      expect(page.current_path).to eq(course_questions_path(c))
      expect(page.text).to match(/Your Response\(s\)/)
      expect(page.text).to match(/1 response/)
    end
  end
end
