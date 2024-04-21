Rails.application.routes.draw do
  scope '/api' do
    mount LetterOpenerWeb::Engine, at: '/letter_opener' if Rails.env.development?

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

    get 'up' => 'rails/health#show', as: :rails_health_check

    ## User-level API routes:
    resources :wallets, only: [] do
      collection do
        get 'show', to: 'wallets#show', as: :show
        get 'total-equity', to: 'wallets#total_equity', as: :total_equity
      end
    end

    resources :transactions, only: %i[create index], defaults: { format: 'json' } do
      collection do
        get 'sent'
        get 'received'
      end
    end

    resources :assets, only: %i[index show], defaults: { format: 'json' } do
      member do
        get 'value'
      end
    end
  end
end
