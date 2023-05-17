require 'rails_helper'

RSpec.describe CoursesController, type: :controller do
  include Devise::Test::ControllerHelpers

  describe "GET #index" do
    it "redirects to login page for unauthenticated users" do
      get :index
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to("/users/sign_in")
    end
    
    it "doesn't redirect for signed in users" do
      admin = FactoryBot.create(:admin)
      sign_in admin 
      c = FactoryBot.create(:course)
      c.instructors << admin
      get :index
      expect(response).to have_http_status(:success)
      expect(assigns(:courses)).to eq([c])
    end
  end

  describe "GET #show" do
    it "redirects to login page for unauthenticated users" do
      get :show, :params => {:id => 1}
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to("/users/sign_in")
    end
    
    it "doesn't redirect for signed in users" do
      s = FactoryBot.create(:student)
      c = FactoryBot.create(:course)
      c.students << s
      sign_in s
      get :show, :params => {:id => c.id}
      expect(response).to have_http_status(:success)
      expect(assigns(:course)).to eq(c)
    end 

    it "should redirect to the course index for an invalid course id" do
      sign_in FactoryBot.create(:user)
      get :show, :params => {:id => 100}
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(courses_path)
    end
  end

  describe "correct redirect on auth" do
    it "should redirect to course going on now if available for std (1)" do
      s = FactoryBot.create(:student)
      c1 = FactoryBot.create(:course, :daytime => "MWF 09:20-10:10")
      c2 = FactoryBot.create(:course, :daytime => "TR 08:30-9:45")
      c1.students << s
      c2.students << s
      # a tuesday
      allow(Time).to receive(:now) { Time.new(2019, 5, 14, 9, 30, 0, "-05:00") }
      sign_in s
      get :index
      expect(response).to redirect_to(course_path(c2))
    end

    it "should redirect to course going on now if available for std (2)" do
      s = FactoryBot.create(:student)
      c1 = FactoryBot.create(:course, :daytime => "MWF 09:20-10:10")
      c2 = FactoryBot.create(:course, :daytime => "TR 08:30-9:45")
      c1.students << s
      c2.students << s
      # a monday
      allow(Time).to receive(:now) { Time.new(2019, 5, 13, 9, 30, 0, "-05:00") }
      sign_in s
      get :index
      expect(response).to redirect_to(course_path(c1))
    end

    it "should redirect to course going on now if available for admin (1)" do
      a = FactoryBot.create(:admin)
      c1 = FactoryBot.create(:course, :daytime => "MWF 09:20-10:10")
      c2 = FactoryBot.create(:course, :daytime => "TR 08:30-9:45")
      # a monday
      allow(Time).to receive(:now) { Time.new(2019, 5, 13, 9, 30, 0, "-05:00") }
      sign_in a
      get :index
      expect(response).to redirect_to(course_path(c1))
    end

    it "should redirect to course going on now if available for admin (2)" do
      a = FactoryBot.create(:admin)
      c1 = FactoryBot.create(:course, :daytime => "MWF 09:20-10:10")
      c2 = FactoryBot.create(:course, :daytime => "TR 08:30-9:45")
      # a tuesday
      allow(Time).to receive(:now) { Time.new(2019, 5, 14, 9, 30, 0, "-05:00") }
      sign_in a
      get :index
      expect(response).to redirect_to(course_path(c2))
    end

    it "should redirect to course index if no course is on now for std" do
      s = FactoryBot.create(:student)
      c1 = FactoryBot.create(:course, :daytime => "MWF 09:20-10:10")
      c2 = FactoryBot.create(:course, :daytime => "TR 08:30-9:45")
      s.courses << c1
      s.courses << c2
      # a monday
      allow(Time).to receive(:now) { Time.new(2019, 5, 13, 9, 0, 0, "-05:00") }
      sign_in s
      get :index
      expect(response).to have_http_status(:success)
    end

    it "should redirect to course index if no course is on now for admin" do
      a = FactoryBot.create(:admin)
      c1 = FactoryBot.create(:course, :daytime => "MWF 09:20-10:10")
      c2 = FactoryBot.create(:course, :daytime => "TR 08:30-9:45")
      # a monday
      allow(Time).to receive(:now) { Time.new(2019, 5, 13, 9, 0, 0, "-05:00") }
      sign_in a
      get :index
      expect(response).to have_http_status(:success)
    end
  end
end
