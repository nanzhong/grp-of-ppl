GrpOfPpl::Application.routes.draw do
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'

  root :to => "home#index", :as => :root

  resources :users , :except => [:index, :new] do
    get 'sign_in(/:token)' => 'users#sign_in', :as => :sign_in
    delete 'sign_out' => 'users#sign_out', :as => :sign_out
    match 'accept_invite/:token' => 'users#accept_invite'
    match 'ignore_invite/:token' => 'users#ignore_invite'
    get 'show_invite/:invite_id' => 'users#show_invite'
  end

  resources :groups do
    resources :posts, :only => [ :create ]
  end

  match '/groups/:id/join/:token' => 'groups#join', :as => :join
  match '/groups/:id/show_reply/:post_id' => 'groups#show_reply'
  match '/groups/:id/hide_reply/:post_id' => 'groups#hide_reply'
  match '/groups/:id/show_share' => 'groups#show_share'
  match '/groups/:id/hide_share' => 'groups#hide_share'
  match '/home' => 'home#index'
  match '/home/new' => 'home#new'
  match '/home/create' => 'home#create'

end
