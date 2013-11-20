Temperature::Application.routes.draw do
  get "dashboard/index"
  root 'dashboard#index'
  namespace :api do
    resources :measurements, only: [:index, :create], format: :json
  end
  get 'realtime/measurements' => 'realtime#measurements', :as => :realtime_measurements
end
