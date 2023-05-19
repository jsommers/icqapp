require 'rails_helper'

RSpec.feature "Coldcalls", type: :feature do
  include Devise::Test::IntegrationHelpers

  context "cold call view/editing" do
    before :each do 
      @c = FactoryBot.create(:course)
      q = FactoryBot.build(:numeric_question, :qname => "Q1", :content => "question content", :course => @c)
      @c.questions << q
      q.save
      p = q.new_poll(:isopen => true, :round => 1)
      p.save
      admin = FactoryBot.create(:admin)
      student = FactoryBot.create(:student)
      @c.students << student
      sign_in admin
      visit course_question_poll_path(@c, q, p)
      expect(page.text).to match(/Q1/)
      click_on "Cold call"
      expect(page.text).to match(/Random student: student\d+@colgate.edu/)
    end

    it "should allow editing of existing cold calls" do
      visit course_cold_calls_path(@c)
      expect(page.text).to match(/student\d+@colgate.edu\s+1\s*/)
      click_on "Edit"
      fill_in :count, :with => "13"
      click_on "Save"
      expect(page.text).to match(/student\d+@colgate.edu\s+13\s*/)
    end

    it "should redirect to cold calls index on edit/update failure" do
      visit course_cold_calls_path(@c)
      expect(page.text).to match(/student\d+@colgate.edu\s+1\s*/)
      click_on "Edit"
      fill_in :count, :with => "-1"
      click_on "Save"
      # NB: no change on count w/invalid count
      expect(page.text).to match(/student\d+@colgate.edu\s+1\s*/)
    end
  end
end
