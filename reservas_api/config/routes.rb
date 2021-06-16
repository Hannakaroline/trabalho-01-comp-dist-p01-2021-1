Rails.application.routes.draw do
  resources :booking_requests, only: [:create, :destroy] do
    get 'made', on: :collection
    get 'received', on: :collection
    post 'answer', on: :member
  end
  resources :bookings, only: [:index] do
    post 'cancel', on: :member
  end
  resources :places, only: [:create, :update, :index] do
    put 'enable', on: :member
    put 'disable', on: :member
    get 'search', on: :collection
    get 'bookings', on: :member
  end
  resources :users, only: [] do
    post 'signup', on: :collection
    get 'login', on: :collection
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
