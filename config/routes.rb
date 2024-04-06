Rails.application.routes.draw do
  scope '/api' do
    if Rails.env.development?
      mount LetterOpenerWeb::Engine, at: "/letter_opener"
    end

    devise_for :users, path: '', path_names: {
      sign_in: 'login',
      sign_out: 'logout',
      registration: 'signup'
    }, controllers: {
      sessions: 'users/sessions',
      registrations: 'users/registrations'
    }

    devise_scope :user do
      get '/reset-password', to: 'api/v1/users/passwords#reset', as: :reset_user_password
      get '/me', to: 'users/sessions#me', as: :me
    end

    get "up" => "rails/health#show", as: :rails_health_check

    ## User-level API routes:
    resources :wallets, only: [] do
      get :show, on: :collection
    end

  end
end
