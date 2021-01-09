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
      sign_in s
      c = FactoryBot.create(:course, :name => "TEST")
      get '/x', :params => { 'c' => 'TEST', 't' => 'n', 'q' => 'enter a number'}
      expect(response).to have_http_status(:redirect)
      expect(c.active_poll).not_to eq nil
    end

    it "should successfully create a multichoice question and a new poll" do
      s = FactoryBot.create(:admin)
      sign_in s
      c = FactoryBot.create(:course, :name => "TEST")
      get '/x', :params => { 'c' => 'TEST', 't' => 'm', 'q' => 'pick an option', 'n' => 4}
      expect(response).to have_http_status(:redirect)
      expect(c.active_poll).not_to eq nil
    end

    it "should successfully create a multichoice question and a new poll with explicit opts" do
      s = FactoryBot.create(:admin)
      sign_in s
      c = FactoryBot.create(:course, :name => "TEST")
      get '/x', :params => { 'c' => 'TEST', 't' => 'm', 'q' => 'pick an option', 'o' => "one\ntwo\nthree", 'a' => 'two'}
      expect(response).to have_http_status(:redirect)
      expect(c.active_poll).not_to eq nil
    end

    it "should redirect if question type is invalid" do
      s = FactoryBot.create(:admin)
      sign_in s
      c = FactoryBot.create(:course, :name => "TEST")
      get '/x', :params => { 'c' => 'TEST', 't' => 'x' }
      expect(response).to have_http_status(:redirect)
      expect(c.active_poll).to be nil
    end

    it "should redirect if question save fails" do
      s = FactoryBot.create(:admin)
      sign_in s
      c = FactoryBot.create(:course, :name => "TEST")
      mc = double('multichoicequestion')
      expect(MultiChoiceQuestion).to receive(:new) { mc }
      expect(mc).to receive(:answer=)
      expect(mc).to receive(:course=)
      expect(mc).to receive(:qname=)
      expect(mc).to receive(:qcontent=)
      expect(mc).to receive(:save) { false }
      get '/x', :params => { 'c' => 'TEST', 't' => 'm', 'q' => 'pick an option', 'o' => ['one', 'two', 'three'], 'a' => 'two'}
      expect(response).to have_http_status(:redirect)
      expect(c.active_poll).to be nil
    end

    it "should redirect if question save fails" do
      s = FactoryBot.create(:admin)
      sign_in s
      c = FactoryBot.create(:course, :name => "TEST")
      mc = double('multichoicequestion')
      expect(MultiChoiceQuestion).to receive(:new) { mc }
      expect(mc).to receive(:answer=)
      expect(mc).to receive(:course=)
      expect(mc).to receive(:qname=)
      expect(mc).to receive(:qcontent=)
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

  describe "XHR requests" do
    it "should be successful with appropriate info in the POST" do
      s = FactoryBot.create(:student)
      sign_in s
      c = FactoryBot.create(:course)
      c.students << s
      q = c.questions.create(:qname => "question", :type => "NumericQuestion")
      p = q.new_poll(:round => 1, :isopen => true)
      p.save!
      post course_question_poll_poll_responses_path(c, q, p), :params => {:course_id => c.id, :question_id => q.id, :poll_id => p.id, :response => "1.0"}
      expect(response).to redirect_to(course_path(c))
      expect(PollResponse.where(:user => s, :poll => p).first.response).to eq(1.0)
    end

    it "should get poll responses over xhr" do
      s = FactoryBot.create(:admin)
      sign_in s
      c = FactoryBot.create(:course)
      q = c.questions.create(:qname => "question", :type => "NumericQuestion")
      p = q.new_poll(:round => 1, :isopen => true)
      p.save!
      get course_question_poll_path(c, q, p), :headers => headers
      expect(response).to have_http_status(:success)
    end

    it "should get poll status for open poll over xhr" do
      s = FactoryBot.create(:admin)
      sign_in s
      c = FactoryBot.create(:course)
      q = c.questions.create(:qname => "question", :type => "NumericQuestion")
      p = q.new_poll(:round => 1, :isopen => true)
      p.save!
      headers = {
        "ACCEPT" => "application/json",
        "HTTP_ACCEPT" => "application/json",
        'X-Requested-With' => 'XMLHttpRequest',
      }
      get poll_status_path(c, q, p), :headers => headers
      expect(response).to have_http_status(:success)
      expect(response.media_type).to eq("application/json")
      body = JSON.load(response.body)
      expect(body['status']).to eq('open')
    end

    it "should get poll status for closed poll over xhr" do
      s = FactoryBot.create(:admin)
      sign_in s
      c = FactoryBot.create(:course)
      q = c.questions.create(:qname => "question", :type => "NumericQuestion")
      p = q.new_poll(:round => 1, :isopen => false)
      p.save!
      headers = {
        "ACCEPT" => "application/json",
        "HTTP_ACCEPT" => "application/json",
        'X-Requested-With' => 'XMLHttpRequest',
      }
      get poll_status_path(c, q, p), :headers => headers
      expect(response).to have_http_status(:success)
      expect(response.media_type).to eq("application/json")
      body = JSON.load(response.body)
      expect(body['status']).to eq('closed')
    end

    it "should get poll status for newly activated poll over xhr" do
      s = FactoryBot.create(:admin)
      sign_in s
      c = FactoryBot.create(:course)
      q = c.questions.create(:qname => "question", :type => "NumericQuestion")
      p = q.new_poll(:round => 1, :isopen => false)
      p.save!
      p2 = q.new_poll(:round => 2, :isopen => true)
      p2.save!
      headers = {
        "ACCEPT" => "application/json",
        "HTTP_ACCEPT" => "application/json",
        'X-Requested-With' => 'XMLHttpRequest',
      }
      get poll_status_path(c, q, p), :headers => headers
      expect(response).to have_http_status(:success)
      expect(response.media_type).to eq("application/json")
      body = JSON.load(response.body)
      expect(body['status']).to be_nil # FIXME
    end

    it "should get redirect for non-xhr requests" do
      s = FactoryBot.create(:admin)
      sign_in s
      c = FactoryBot.create(:course)
      q = c.questions.create(:qname => "question", :type => "NumericQuestion")
      p = q.new_poll(:round => 1, :isopen => false)
      p.save!
      get poll_status_path(c, q, p)
      expect(response).to have_http_status(:redirect)
    end

    it "should get course status for open poll over xhr" do
      s = FactoryBot.create(:admin)
      sign_in s
      c = FactoryBot.create(:course)
      q = c.questions.create(:qname => "question", :type => "NumericQuestion")
      p = q.new_poll(:round => 1, :isopen => true)
      p.save!
      headers = {
        "ACCEPT" => "application/json",
        "HTTP_ACCEPT" => "application/json",
        'X-Requested-With' => 'XMLHttpRequest',
      }
      get course_status_path(c), :headers => headers
      expect(response).to have_http_status(:success)
      expect(response.media_type).to eq("application/json")
      body = JSON.load(response.body)
      expect(body['status']).to eq('open')
    end


    it "should get poll status for closed poll over xhr" do
      s = FactoryBot.create(:admin)
      sign_in s
      c = FactoryBot.create(:course)
      q = c.questions.create(:qname => "question", :type => "NumericQuestion")
      p = q.new_poll(:round => 1, :isopen => false)
      p.save!
      headers = {
        "ACCEPT" => "application/json",
        "HTTP_ACCEPT" => "application/json",
        'X-Requested-With' => 'XMLHttpRequest',
      }
      get course_status_path(c), :headers => headers
      expect(response).to have_http_status(:success)
      expect(response.media_type).to eq("application/json")
      body = JSON.load(response.body)
      expect(body['status']).to eq('closed')
    end


    it "should get redirect for non-xhr requests" do
      s = FactoryBot.create(:admin)
      sign_in s
      c = FactoryBot.create(:course)
      q = c.questions.create(:qname => "question", :type => "NumericQuestion")
      p = q.new_poll(:round => 1, :isopen => false)
      p.save!
      get course_status_path(c)
      expect(response).to have_http_status(:redirect)
    end
  end
end
