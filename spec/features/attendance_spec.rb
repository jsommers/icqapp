require 'rails_helper'

RSpec.feature "Attendance", type: :feature do
  include Devise::Test::IntegrationHelpers

  describe "basic attendance workflow - admin" do
    it "should show that attendance hasn't been taken if it hasn't" do
      admin = FactoryBot.create(:admin)
      sign_in admin
      c = FactoryBot.create(:course)
      visit course_path(c)
      expect(page.text).to match(/take attendance/i)
    end

    it "should open attendance when 'Take Attendance' is clicked" do
      admin = FactoryBot.create(:admin)
      sign_in admin
      c = FactoryBot.create(:course)
      visit course_path(c)
      click_on 'Take attendance'
      expect(page.current_path).to eq(course_questions_path(c))
      expect(c.attendance_active?).to be true
    end

    it "should close attendance when attendance has been active" do
      admin = FactoryBot.create(:admin)
      sign_in admin
      c = FactoryBot.create(:course)
      c.open_attendance
      visit course_path(c)
      click_on 'Close attendance'
      expect(page.current_path).to eq(course_questions_path(c))
      expect(c.attendance_active?).to be false
    end

    it "should show an attendance report" do
      admin = FactoryBot.create(:admin)
      sign_in admin
      c = FactoryBot.create(:course)
      s = FactoryBot.create(:student)
      c.students << s
      c.open_attendance
      c.close_attendance
      visit attendance_report_path(c)
      expect(page.text).to match(/0 0 \/ 1/)
    end
  end

  describe "basic attendance workflow - student" do
    it "should allow a student to check in if they haven't" do
      s = FactoryBot.create(:student)
      sign_in s
      c = Course.create!(:name => "One", :daytime => "TR 8:30-9:55")
      c.students << s
      c.open_attendance
      visit course_path(c)
      expect(page.text).to match(/attendance check-in/i)
      click_on "Attendance check-in"
      expect(page.text).to match(/you're checked in for today/i)
    end

    it "should allow a student to check in if they haven't" do
      s = FactoryBot.create(:student)
      sign_in s
      c = Course.create!(:name => "One", :daytime => "TR 8:30-9:55")
      c.students << s
      visit course_path(c)
      expect(page.text).to match(/attendance check-in is not open/i)
    end
  end
end
