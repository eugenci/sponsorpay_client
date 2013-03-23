Rchallenge::Application.routes.draw do
  root :to => 'offers#new'
  match '/get' => 'offers#get'
  match '*default' => 'offers#new'
end
