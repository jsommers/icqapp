require 'rails_helper'

RSpec.describe PollsController, type: :controller do
  include Devise::Test::ControllerHelpers
  
  describe "GET #index" do
    it "returns http success" do
      sign_in FactoryBot.create(:admin)
      c = FactoryBot.create(:course) 
      q = c.questions.create(:qname => "question", :type => "NumericQuestion")
      get :index, :params => {:course_id => c.id, :question_id => q.id}
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #show" do
    it "should return http success" do
      sign_in FactoryBot.create(:admin)
      c = FactoryBot.create(:course) 
      q = c.questions.create(:qname => "question", :type => "NumericQuestion")
      p = q.new_poll(:isopen => false, :round => 1)
      p.save
      get :show, :params => {:course_id => c.id, :question_id => q.id, :id => p.id}
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST #create" do
    it "should make a new poll with round 1 for the first poll" do
      sign_in FactoryBot.create(:admin)
      c = FactoryBot.create(:course) 
      q = c.questions.create(:qname => "question", :type => "NumericQuestion")
      post :create, :params => {:course_id => c.id, :question_id => q.id}
      expect(response).to have_http_status(:redirect)
      p = Poll.find(1)
      expect(response).to redirect_to(course_question_poll_path(c, q, p))
      expect(p.round).to eq(1)
      expect(p.isopen).to be true
    end

    it "should make a new poll with round 2 for the second poll, and deactive any other polls" do
      sign_in FactoryBot.create(:admin)
      c = FactoryBot.create(:course) 
      q = c.questions.create(:qname => "question", :type => "NumericQuestion")
      p = q.new_poll(:isopen => true, :round => 1)
      p.save
      post :create, :params => {:course_id => c.id, :question_id => q.id}
      expect(response).to have_http_status(:redirect)
      p2 = Poll.find(2)
      expect(response).to redirect_to(course_question_poll_path(c, q, p2))
      expect(p2.round).to eq(2)
      expect(p2.isopen).to be true
      expect(Poll.find(p.id).isopen).to be false
    end

    it "should redirect to course_questions on failure" do
      sign_in FactoryBot.create(:admin)
      c = FactoryBot.create(:course) 
      q = c.questions.create(:qname => "question", :type => "NumericQuestion")
      fakepoll = double('poll')
      expect(fakepoll).to receive(:save).and_return(nil)
      expect(fakepoll).to receive(:isopen=).with(true)
      expect(fakepoll).to receive(:round=).with(1)
      expect(Poll).to receive(:new).and_return(fakepoll)
      post :create, :params => {:course_id => c.id, :question_id => q.id}
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(course_questions_path(c))
      expect(Poll.all.count).to eq(0)
    end
  end

  describe "PUT #update" do
    it "should close the poll on update and redirect to the Poll#show page" do
      sign_in FactoryBot.create(:admin)
      c = FactoryBot.create(:course) 
      q = c.questions.create(:qname => "question", :type => "NumericQuestion")
      p = q.new_poll(:isopen => true, :round => 1)
      p.save
      put :update, :params => {:course_id => c.id, :question_id => q.id, :id => p.id}
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(course_question_poll_path(c, q, p))
      expect(Poll.find(p.id).isopen).to be false
    end
  end

  describe "DELETE #destroy" do
    it "should delete the poll and redirect to the Poll#index page" do
      sign_in FactoryBot.create(:admin)
      c = FactoryBot.create(:course) 
      q = c.questions.create(:qname => "question", :type => "NumericQuestion")
      p = q.new_poll(:isopen => false, :round => 1)
      p.save
      delete :destroy, :params => {:course_id => c.id, :question_id => q.id, :id => p.id}
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(course_question_polls_path(c, q))
      expect { Poll.find(p.id) }.to raise_error { ActiveRecord::RecordNotFound }
    end
  end

  describe "GET #notify" do
    it "should send a notification email for poll responses" do
      sign_in FactoryBot.create(:admin)
      c = FactoryBot.create(:course) 
      q = c.questions.create(:qname => "question", :type => "NumericQuestion")
      p = q.new_poll(:isopen => false, :round => 1)
      p.save
      expect(response).to be_ok
    end
  end
end
