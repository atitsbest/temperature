Temperature::Application.routes.draw do
  namespace :api do
    resources :measurements, only: [:index, :create], :default => { format: 'json' }
  end
end
