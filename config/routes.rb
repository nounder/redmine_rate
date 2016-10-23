RedmineApp::Application.routes.draw do
  resources :rates

  resources :users do
    resources :rates, only: [:index, :new]
  end
end
