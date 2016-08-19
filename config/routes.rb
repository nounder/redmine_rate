RedmineApp::Application.routes.draw do
  resources :rates, except: [:index]

  resources :users do
    resources :rates, only: [:index]
  end
end
