Dropbooks::Application.routes.draw do
  post "freshbooks/authorize", to: "users#freshbooks_authorize"
  get "freshbooks/authorize_callback", to: "users#freshbooks_authorize_callback", as: :freshbooks_authorize_callback
  root to: "users#new"
end
