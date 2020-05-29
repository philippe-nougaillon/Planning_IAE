Rails.application.routes.draw do
  
  devise_for :users
  
  resources :cours do
    collection do
      get :planning, to: 'cours#index_slide'

      post :action
      post :action_do
    end
  end
    
  resources :salles do
    collection do
      get :occupation
    end
  end

  resources :formations
  resources :intervenants
  resources :users
  resources :fermetures
  resources :documents
  resources :etudiants
 
  resources :import_logs do
    member do
      get :download_imported_file
    end
  end
  
  namespace :tools do
    get :index

    get :import
    get :import_intervenants
    get :import_utilisateurs
    get :import_etudiants
    get :export
    get :export_intervenants
    get :export_etudiants

    get :swap_intervenant
    get :etats_services
    get :audits
    get :taux_occupation_jours
    get :taux_occupation_salles
    get :nouvelle_saison
    get :notifier_intervenants
    get :creation_cours

    post :import_do
    post :creation_cours_do
    post :import_intervenants_do
    post :import_utilisateurs_do
    post :import_etudiants_do
    post :export_do
    post :export_intervenants_do
    post :export_etudiants_do
    post :swap_intervenant_do
    post :taux_occupation_jours_do
    post :taux_occupation_salles_do
    post :nouvelle_saison_create
    post :notifier_intervenants_do
  end

  get 'guide/index'
  
  namespace :api, defaults: {format: 'json'} do 
    namespace :v1 do 
        resources :cours
    end 

    namespace :v2 do 
        resources :cours do
          collection do
            get :in_progress
          end
        end
        resources :etudiants
    end 
  end 

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"

  root 'cours#index'

end
