Temperature::Application.routes.draw do
  namespace :api do
    resources :measurements, only: [:index], :default => { format: 'json' }
  end
end
