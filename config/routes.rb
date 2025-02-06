Rails.application.routes.draw do
  resources :users do
    member do
      patch "preferences", to: "users#update_preferences"
      get "itineraries", to: "users#itineraries"
      post "itineraries", to: "users#save_itinerary"
      delete "itineraries/:itinerary_id", to: "users#remove_itinerary", as: "remove_itinerary"  # ✅ Correct placement
    end
  end

  resources :trips do
    resources :places do
      member do
        patch "update_cost"
      end
    end

    member do
      patch "update_costs"
    end
  end
end
