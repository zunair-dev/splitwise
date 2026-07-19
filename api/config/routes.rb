Rails.application.routes.draw do
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      resource :profile, only: [ :show, :update ], controller: :users
      resources :users, only: [ :create ]

      resources :friendships, only: [ :index, :create ] do
        member do
          patch :accept
        end
      end

      resources :groups, only: [ :index, :create, :show, :update ] do
        resources :memberships, only: [ :create ], controller: :group_memberships
        resources :invitations, only: [ :create ], controller: :group_invitations
      end

      resources :memberships, only: [ :destroy ], controller: :group_memberships
      resources :invitations, only: [], controller: :group_invitations do
        member do
          patch :revoke
        end
      end
    end
  end
end
