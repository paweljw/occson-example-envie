Rails.application.routes.draw do
  root to: 'home#index'

  post :webhook, to: 'webhooks#create'
end
