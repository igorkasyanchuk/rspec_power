Rails.application.routes.draw do
  root "home#index"
  post "/set_state", to: "home#set_state"
end
