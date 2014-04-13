Faalis::Engine.routes.draw do
  get 'templates/*path' => 'dashboard#jstemplate'

  # Authentications
  devise_config = {
    :class_name => 'Faalis::User',
    :module => :devise
  }

  # Add omniauth callback if there was any provider
  unless Devise.omniauth_providers.empty?
    devise_config[:controllers] = {
      :omniauth_callbacks => 'faalis/omniauth/callbacks',
    }
  end

  devise_for :users, devise_config


  scope '(:locale)', :locale => Regexp.new(::I18n.available_locales.join('|')) do
    scope Faalis::Engine.dashboard_namespace.to_sym do
      get '' => 'dashboard#index', :as => 'dashboard'
      get 'modules' => 'dashboard#modules'
    end


    # Root URL
    root :to => 'home#index'
  end


  namespace :api, :defaults => {:format => :json} do
    namespace :v1 do
      get 'permissions', :to => 'permissions#index'
      get 'permissions/user', :to => 'permissions#user_permissions'
      resources :groups, :except => [:new]
      resources :users, :except => [:new]
      resource :profile, :except => [:new, :destroy]

      get 'logs' => 'logs#index'
      get 'workflows' => 'workflows#index'

      resources :conversations, only: [:index, :show, :create, :destroy] do
        collection do
          get ':box/box' => 'conversations#index'
          post 'trash' => 'conversations#trash'
          post 'untrash' => 'conversations#untrash'
        end
        member do
          post :reply
        end

      end
    end
  end
end
