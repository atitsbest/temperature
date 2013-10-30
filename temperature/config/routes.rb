Temperature::Application.routes.draw do
  namespace :api do
    resources :measurements, only: [:index, :create], format: :json
  end
end
