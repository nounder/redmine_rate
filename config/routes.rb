RedmineApp::Application.routes.draw do
  resources :rates

  post 'rates/update_form', to: 'rates#update_form', as: 'rate_update_form'

  resources :users do
    resources :rates, only: [:index, :new]
  end
end
