require 'rails_helper'

RSpec.feature "ProfessorDashboard", type: :feature do
  include Devise::Test::IntegrationHelpers
  
  describe "professor dashboard functionality" do
      
    it "should display a no responses messages for a question report without responses" do
      c = FactoryBot.create(:course)
      # q = FactoryBot.build(:multi_choice_question, :qname => "Q1", :course => c)
      q = Question.new(:qname => "Test", :type => "MultiChoiceQuestion", :answer => "a", :breakout => 1)
      p = q.new_poll(:isopen => true, :round => 1)
      p.save

      admin = FactoryBot.create(:admin)
      sign_in admin
      visit "courses/#{c.id}/question_report"
      expect(page.text).to match("No Responses!")
    end
    
    
    it "should display a report card for a question's poll" do
      # c = FactoryBot.create(:course)
      c = Course.create(:name => "test", :daytime => "TR 8:30-9:45", :id => 3)
      # q = FactoryBot.build(:multi_choice_question, :qname => "Q1", :course => c)
      q1 = MultiChoiceQuestion.new(:qname => "Test", :answer => "a", :breakout => 1, :course => c)
      c.question
      p1 = q1.new_poll(:isopen => true, :round => 1)
      p1.new_response(:response => "a")
      p1.new_response(:response => "b")
      p1.save

      admin = FactoryBot.create(:admin)
      sign_in admin
      visit "courses/#{c.id}/question_report"
      # page.should have_css('div.report_card')
      expect(page).to have_selector :css, 'div.card.bg-light.report_card'
      expect(page.text).to match("Heyyyy!")
    end
    
    
    it "should display 3 cards for 3 question reports" do
      # c = FactoryBot.create(:course)
      c = Course.create(:name => "test", :daytime => "TR 8:30-9:45", :id => 3)
      # q = FactoryBot.build(:multi_choice_question, :qname => "Q1", :course => c)
      
      3.times do 
        q = MultiChoiceQuestion.new(:qname => "Test", :answer => "a", :breakout => 1, :course => c)
        p = q.new_poll(:isopen => true, :round => 1)
        p.new_response(:response => "a")
        p.new_response(:response => "b")
        p.save
      end
      
      admin = FactoryBot.create(:admin)
      sign_in admin
      visit "courses/#{c.id}/question_report"
      expect(page).to have_selector('div.card.bg-light.report_card', count: 3)
      
    end
    
    
    
  end
  
  
  
end
