Rails.application.routes.draw do
<<<<<<< HEAD

  resources :viajes

  devise_for :users, :controllers => { registrations: 'registrations' }

  resources :users

=======
>>>>>>> 9e55228f2ab404fffd2800e9bb09f41c8540bb0a
  root "application#index"

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
