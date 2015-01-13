Empath::Application.routes.draw do

  get 'internal/server_status', to: "internal#server_status"

  get 'concierges/:experiment_id', to: 'subjects#new', defaults: { desktop: '1' }, as: :concierge_subject_signup

  # Dashboard Routes

  get 'experiments/:experiment_id/dashboard', to: 'dashboard#show', as: :dashboard
  get 'experiments/:experiment_id/dashboard/:subject_id/phonecall', to: 'dashboard#init_phone_call', as: :dashboard_phone_call
  
  # Messages routes

  post 'messages/:id/deactivate', to: "messages#deactivate", as: :deactivate_message
  #     Messages routes (for Twilio's use)
  post 'twilio/incoming', to: 'messages#incoming_message'
  post 'twilio/messages', to: 'messages#update_status', as: :update_twilio_message
  post 'twilio/voice_call', to: 'voice#connect_call'

  resources :operationtypes

  concern :userable do 
    resources :users
  end

  concern :experimentsable do
    resources :experiments, only: [:index]
  end

  root :to => 'users#index'

  resources :experiments, shallow: true do 
    resources :subjects
    resources :triggers, shallow:true do
      resources :operations  
    end
  end

  resources :users, concerns: :experimentsable

  resources :password_resets

  controller :user_sessions do
    get 'login' => :new
    post 'login' => :create
    delete 'login' => :destroy
  end

  resources :organizations, concerns: :experimentsable, shallow: true do 
    resources :users
  end

  mount Resque::Server.new, :at => '/resque'


  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end
  
  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
