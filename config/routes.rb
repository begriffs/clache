Clache::Application.routes.draw do
  resources :terms, only: [:index, :show, :new, :create]
end
