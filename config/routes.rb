Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token
  get "invitations/:token", to: "invitation_acceptances#new", as: :new_invitation_acceptance
  post "invitations/:token", to: "invitation_acceptances#create", as: :invitation_acceptance
  root "home#show"
  get "forms/:organization_slug", to: "public_forms#show", as: :public_form
  post "forms/:organization_slug", to: "public_forms#create"
  get "forms/:organization_slug/confirmation/:reference_number",
    to: "public_forms#confirmation", as: :public_form_confirmation

  namespace :admin do
    root "organizations#index"
    resources :organizations, only: %i[index show], param: :slug do
      resources :invitations, only: :create
      resources :memberships, only: :destroy
      resource :form, only: %i[edit update] do
        get :preview
        patch :publish
      end
      resources :submissions, only: %i[index show update destroy] do
        get :export, on: :collection
      end
    end
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  get "ready" => "readiness#show", as: :readiness_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end
