Testapp::Application.routes.draw do
  resources :users
  root :to => "users#index"
  match "jasmine" => "application#jasmine"
end
