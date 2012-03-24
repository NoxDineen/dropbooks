Dropbooks::Application.routes.draw do
  post "freshbooks/authorize", to: "users#freshbooks_authorize"
  get "freshbooks/authorize_callback", to: "users#freshbooks_authorize_callback", as: :freshbooks_authorize_callback

  get "dropbox/authorize", to: "users#dropbox_authorize"
  get "dropbox/authorize_callback", to: "users#dropbox_authorize_callback", as: :dropbox_authorize_callback

  get "authorize", to: "users#new"
  root to: 'users#new'
end
