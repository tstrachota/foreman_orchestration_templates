Rails.application.routes.draw do
  scope :module => :foreman_orchestration_templates do
    resources :orchestration_templates, :except => [:show] do
      member do
        get 'clone_template'
        get 'lock'
        get 'export'
        get 'unlock'
        post 'preview'
      end
      collection do
        post 'preview'
        post 'import'
        get 'revision'
        get 'auto_complete_search'
        get 'auto_complete_job_category'
      end
    end

    resources :orchestration_jobs, :only => [:new, :create, :show, :index, :destroy] do
      get :auto_complete_search, :on => :collection
    end

    namespace :api do
      scope '(:apiv)',
            :module      => :v2,
            :defaults    => { :apiv => 'v2' },
            :apiv        => /v1|v2/,
            :constraints => ApiConstraints.new(:version => 2) do

      end
    end
  end
end
