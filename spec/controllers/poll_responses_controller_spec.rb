require 'rails_helper'

RSpec.describe PollResponsesController, type: :controller do
  include Devise::Test::ControllerHelpers

  describe "POST #create" do
    it "should reject any response from a student not enrolled in the course" do
      sign_in FactoryBot.create(:student)
      c = FactoryBot.create(:course)
      q = c.questions.create(:qname => "question", :type => "NumericQuestion")
      p = q.new_poll(:round => 1, :isopen => true)
      p.save!
      post :create, :params => {:course_id => c.id, :question_id => q.id, :poll_id => p.id, :response => "1.0"}
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(courses_path)
      expect(PollResponse.count).to eq(0)
    end

    it "should reject any response if the poll isn't open" do
      s = FactoryBot.create(:student)
      sign_in s
      c = FactoryBot.create(:course)
      c.students << s
      q = c.questions.create(:qname => "question", :type => "NumericQuestion")
      p = q.new_poll(:round => 1, :isopen => false)
      p.save!
      post :create, :params => {:course_id => c.id, :question_id => q.id, :poll_id => p.id, :response => "1.0"}
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(course_path(c))
      expect(PollResponse.count).to eq(0)
    end

    it "should allow a response if student is enrolled and poll is open" do
      s = FactoryBot.create(:student)
      sign_in s
      c = FactoryBot.create(:course)
      c.students << s
      q = c.questions.create(:qname => "question", :type => "NumericQuestion")
      p = q.new_poll(:round => 1, :isopen => true)
      p.save!
      post :create, :params => {:course_id => c.id, :question_id => q.id, :poll_id => p.id, :response => "1.0"}
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(course_path(c))
      expect(PollResponse.where(:user => s, :poll => p).first.response).to eq(1.0)
    end

    it "should fail graceful if save doesn't work" do
      s = FactoryBot.create(:student)
      sign_in s
      c = FactoryBot.create(:course)
      c.students << s
      q = c.questions.create(:qname => "question", :type => "NumericQuestion")
      p = q.new_poll(:round => 1, :isopen => true)
      p.save!
      p = double("poll")
      pr = double("poll_response")
      x = double('stuff')
      expect(x).to receive(:where) { x }
      expect(x).to receive(:first) { nil }
      expect(p).to receive(:poll_responses) { x }
      expect(p).to receive(:id) { 1 }
      expect(p).to receive(:new_response) { pr }
      expect(p).to receive(:isopen) { true }
      expect(pr).to receive(:save) { nil }
      expect(pr).to receive(:response=) { nil }
      expect(Poll).to receive(:find).with("1") { p }

      post :create, :params => {:course_id => c.id, :question_id => q.id, :poll_id => p.id, :response => "1.0"}
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(course_path(c))
      expect(PollResponse.count).to eq(0)
    end
  end
end
