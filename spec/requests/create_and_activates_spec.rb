require 'rails_helper'

RSpec.describe "CreateAndActivates", type: :request do
  include Devise::Test::IntegrationHelpers

  describe "create and update" do
    it "should redirect for bad course" do
      s = FactoryBot.create(:admin)
      sign_in s
      get '/x'
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(courses_path)
    end

    it "should redirect for bad question type" do
      s = FactoryBot.create(:admin)
      sign_in s
      c = FactoryBot.create(:course, :name => "TEST")
      get '/x', :params => { 'c' => 'TEST' }
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(course_path(c))
    end

    it "should redirect with good question type but no question" do
      s = FactoryBot.create(:admin)
      sign_in s
      c = FactoryBot.create(:course, :name => "TEST")
      get '/x', :params => { 'c' => 'TEST', 't' => 'n'}
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(course_path(c))
      expect(c.active_poll).to be nil
    end

    it "should successfully create a numeric question and a new poll" do
      s = FactoryBot.create(:admin)
      c = FactoryBot.create(:course, :name => "TEST")
      c.instructors << s
      sign_in s
      get '/x', :params => { 'c' => 'TEST', 't' => 'n', 'q' => 'enter a number', 'o' => "question text"}
      expect(response).to have_http_status(:redirect)
      expect(c.active_poll).not_to eq nil
    end

    it "should successfully create a multichoice question and a new poll" do
      s = FactoryBot.create(:admin)
      c = FactoryBot.create(:course, :name => "TEST")
      c.instructors << s
      sign_in s
      get '/x', :params => { 'c' => 'TEST', 't' => 'm', 'q' => 'pick an option', 'n' => 4}
      expect(response).to have_http_status(:redirect)
      expect(c.active_poll).not_to eq nil
    end

    it "should successfully create a multichoice question and a new poll with explicit opts" do
      s = FactoryBot.create(:admin)
      c = FactoryBot.create(:course, :name => "TEST")
      c.instructors << s
      sign_in s
      get '/x', :params => { 'c' => 'TEST', 't' => 'm', 'q' => 'pick an option', 'o' => "one\ntwo\nthree", 'a' => 'two'}
      expect(response).to have_http_status(:redirect)
      expect(c.active_poll).not_to eq nil
    end

    it "should redirect if question type is invalid" do
      s = FactoryBot.create(:admin)
      c = FactoryBot.create(:course, :name => "TEST")
      c.instructors << s
      sign_in s
      get '/x', :params => { 'c' => 'TEST', 't' => 'x' }
      expect(response).to have_http_status(:redirect)
      expect(c.active_poll).to be nil
    end

    it "should redirect if question save fails" do
      s = FactoryBot.create(:admin)
      c = FactoryBot.create(:course, :name => "TEST")
      c.instructors << s
      sign_in s
      mc = double('multichoicequestion')
      expect(MultiChoiceQuestion).to receive(:new) { mc }
      expect(mc).to receive(:answer=)
      expect(mc).to receive(:course=)
      expect(mc).to receive(:qname=)
      expect(mc).to receive(:content=).at_least(:once)
      expect(mc).to receive(:save) { false }
      get '/x', :params => { 'c' => 'TEST', 't' => 'm', 'q' => 'pick an option', 'o' => ['one', 'two', 'three'], 'a' => 'two'}
      expect(response).to have_http_status(:redirect)
      expect(c.active_poll).to be nil
    end

    it "should redirect if question save fails" do
      s = FactoryBot.create(:admin)
      c = FactoryBot.create(:course, :name => "TEST")
      c.instructors << s
      sign_in s
      mc = double('multichoicequestion')
      expect(MultiChoiceQuestion).to receive(:new) { mc }
      expect(mc).to receive(:answer=)
      expect(mc).to receive(:course=)
      expect(mc).to receive(:qname=)
      expect(mc).to receive(:content=).at_least(:once)
      expect(mc).to receive(:save) { true }
      x = double('polls')
      expect(x).to receive(:maximum) { 0 }
      expect(mc).to receive(:polls) { x }
      p = double('poll')
      expect(p).to receive(:isopen=)
      expect(p).to receive(:round=)
      expect(p).to receive(:save) { false }
      expect(mc).to receive(:new_poll) { p }

      get '/x', :params => { 'c' => 'TEST', 't' => 'm', 'q' => 'pick an option', 'o' => ['one', 'two', 'three'], 'a' => 'two'}
      expect(response).to have_http_status(:redirect)
      expect(c.active_poll).to be nil
    end
  end
end
