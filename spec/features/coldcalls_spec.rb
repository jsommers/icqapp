require 'rails_helper'

RSpec.feature "Coldcalls", type: :feature do
  include Devise::Test::IntegrationHelpers

  context "cold call view/editing" do
    before :each do 
      @c = FactoryBot.create(:course)
      q = FactoryBot.build(:numeric_question, :qname => "Q1", :course => @c)
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
      visit edit_course_coldcall_path(@c,0)
      expect(page.text).to match(/student\d+@colgate.edu\s+1\s*/)
      fill_in :count, :with => "13"
      click_on "Save"
      expect(page.text).to match(/student\d+@colgate.edu\s+13\s*/)
    end
  end
end
