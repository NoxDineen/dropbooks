Dropbooks::Application.routes.draw do
  post "freshbooks/authorize", to: "users#freshbooks_authorize"
  get "freshbooks/authorize_callback", to: "users#freshbooks_authorize_callback", as: :freshbooks_authorize_callback
  get "authorize", to: "users#new"
  root to: 'users#new'
end
