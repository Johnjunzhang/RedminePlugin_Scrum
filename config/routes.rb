# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

resources :projects do
  resources :sprints, :shallow => true do
    member do
      get :edit_effort
      put :update_effort
      get :burndown
      get :burndown_graph
    end
    collection do
      get :burndown_index
    end
  end
  post "sprints/change_task_status",
       :controller => :sprints, :action => :change_task_status,
       :as => :sprints_change_task_status

  resources :product_backlog, :shallow => true, :only => [:index] do
    collection do
      post :sort
      post :create_pbi
      get :burndown
      get :burndown_graph
    end
  end
  get "product_backlog/new_pbi/:tracker_id",
      controller: :product_backlog, action: :new_pbi,
      as: :product_backlog_new_pbi

end

post "issues/:id/story_points",
     :controller => :scrum, :action => :change_story_points,
     :as => :change_story_points
post "issues/:id/pending_effort",
     :controller => :scrum, :action => :change_pending_effort,
     :as => :change_pending_effort
post "issues/:id/assigned_to",
     :controller => :scrum, :action => :change_assigned_to,
     :as => :change_assigned_to
post "issues/:id/create_time_entry",
     :controller => :scrum, :action => :create_time_entry,
     :as => :create_time_entry
get "scrum/:sprint_id/new_pbi/:tracker_id",
     controller: :scrum, action: :new_pbi,
     as: :new_pbi
post "scrum/:sprint_id/create_pbi",
     controller: :scrum, action: :create_pbi,
     as: :create_pbi

