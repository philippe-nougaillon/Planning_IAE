Rails.application.routes.draw do

  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  resources :ouvertures
  devise_for :users

  resources :invits, only: [:index, :show] do
    member do
      get :envoyer 
      get :relancer 
      get :valider 
      get :rejeter 
      get :confirmer 
      get :archiver
      post :validation
    end
    collection do
      post :action
    end
  end

  resources :formations
  resources :intervenants do
    member do
      get :invitations
    end
  end
  resources :users
  resources :fermetures
  resources :etudiants
  resources :documents
  resources :unites

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
      get :libres
    end
  end

  resources :dossiers do
    member do
      get :deposer
      get :envoyer
      get :valider
      get :rejeter
      get :relancer
      get :archiver
    end
  end
 
  resources :import_logs do
    member do
      get :download_imported_file
    end
  end

  resources :envoi_logs do
    member do
      get :activer
      get :tester
      get :suspendre
    end
  end

  resources :mail_logs, only: %i[ index show destroy ]

  namespace :tools do
    get :index

    get :import
    get :import_intervenants
    get :import_utilisateurs
    get :import_etudiants
    get :export
    get :export_intervenants
    get :export_utilisateurs
    get :export_etudiants
    get :export_formations
    get :export_vacations

    get :swap_intervenant
    get :etats_services
    get :audits
    get :taux_occupation_jours
    get :taux_occupation_salles
    get :nouvelle_saison
    get :notifier_intervenants
    get :creation_cours
    get :audit_cours
    get :liste_surveillants_examens
    get :rechercher
    get :rappel_des_cours

    post :import_do
    post :creation_cours_do
    post :import_intervenants_do
    post :import_utilisateurs_do
    post :import_etudiants_do
    post :export_do
    post :export_intervenants_do
    post :export_utilisateurs_do
    post :export_etudiants_do
    post :export_formations_do
    post :export_vacations_do
    post :swap_intervenant_do
    post :taux_occupation_jours_do
    post :taux_occupation_salles_do
    post :nouvelle_saison_create
    post :notifier_intervenants_do
    post :rappel_des_cours_do

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
  
    namespace :v3 do 
      resources :cours do
        collection do
          get :in_progress
        end
      end
    end 

    namespace :v4 do 
      resources :cours
    end 

  end 

  root 'cours#index'

end
