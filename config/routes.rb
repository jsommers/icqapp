Rails.application.routes.draw do
  root to: "courses#index"
  resources :courses, :only => [:index, :show] do
#    resources :coldcalls, :only => [:edit, :update]
    resources :questions, :only => [:index, :show, :new, :create, :destroy] do
      resources :polls, :only => [:index, :show, :create, :update, :destroy] do
        resources :poll_responses, :only => [:create]
      end
    end
  end

  post '/courses/:course_id/attendance', :to => 'attendance#create', :as => :attendance_check_in, :controller => 'attendance', :action => 'create'
  post '/courses/:course_id/open_attendance', :to => 'courses#open_attendance', :as => :open_attendance, :action => 'open_attendance', :controller => 'courses'
  post '/courses/:course_id/close_attendance', :to => 'courses#close_attendance', :as => :close_attendance, :action => 'close_attendance', :controller => 'courses'

#  get '/courses/:course_id/questions/:question_id/polls/:id/status', :to => 'polls#status', :as => :poll_status, :action => 'status', :controller => 'polls'
#  get '/courses/:id/attendance_report', :to => 'courses#attendance_report', :as => :attendance_report, :action => "attendance_report", :controller => 'courses'
#  get '/courses/:id/question_report', :to => 'courses#question_report', :as => :question_report, :action => "question_report", :controller => 'courses'
#  get '/courses/:id/status', :to => 'courses#status', :as => :course_status, :action => 'status', :controller => 'courses'
#  get '/polls/:id/notify', :to => 'polls#notify', :as => :poll_notify, :action => 'notify', :controller => 'polls'


#  get '/x', :to => 'courses#create_and_activate'

  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
end
