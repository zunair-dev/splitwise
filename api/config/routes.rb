Rails.application.routes.draw do
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  devise_for :users,
    path: "api/v1/auth",
    path_names: {
      sign_in: "sign_in",
      sign_out: "sign_out",
      registration: "sign_up"
    },
    controllers: {
      registrations: "api/v1/auth/registrations",
      sessions: "api/v1/auth/sessions"
    },
    defaults: { format: :json },
    skip: [ :passwords ]

  namespace :api do
    namespace :v1 do
      resource :profile, only: [ :show, :update ], controller: :users

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
