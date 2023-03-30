# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2023_03_30_113820) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_stat_statements"
  enable_extension "plpgsql"

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "agents", force: :cascade do |t|
    t.string "nom"
    t.string "prénom"
    t.string "catégorie"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "alerts", force: :cascade do |t|
    t.datetime "debut"
    t.datetime "fin"
    t.string "message"
    t.integer "etat"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "audits", id: :serial, force: :cascade do |t|
    t.integer "auditable_id"
    t.string "auditable_type"
    t.integer "associated_id"
    t.string "associated_type"
    t.integer "user_id"
    t.string "user_type"
    t.string "username"
    t.string "action"
    t.text "audited_changes"
    t.integer "version", default: 0
    t.string "comment"
    t.string "remote_address"
    t.string "request_uuid"
    t.datetime "created_at"
    t.index ["associated_id", "associated_type"], name: "associated_index"
    t.index ["auditable_id", "auditable_type"], name: "auditable_index"
    t.index ["created_at"], name: "index_audits_on_created_at"
    t.index ["request_uuid"], name: "index_audits_on_request_uuid"
    t.index ["user_id", "user_type"], name: "user_index"
  end

  create_table "cours", id: :serial, force: :cascade do |t|
    t.datetime "debut"
    t.datetime "fin"
    t.integer "formation_id"
    t.integer "intervenant_id"
    t.integer "salle_id"
    t.string "ue"
    t.string "nom"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "etat", default: 0
    t.decimal "duree", precision: 4, scale: 2, default: "0.0"
    t.integer "intervenant_binome_id"
    t.boolean "hors_service_statutaire"
    t.string "commentaires"
    t.boolean "elearning"
    t.integer "code_ue"
    t.index ["debut"], name: "index_cours_on_debut"
    t.index ["etat"], name: "index_cours_on_etat"
    t.index ["formation_id"], name: "index_cours_on_formation_id"
    t.index ["intervenant_id"], name: "index_cours_on_intervenant_id"
    t.index ["salle_id"], name: "index_cours_on_salle_id"
  end

  create_table "documents", force: :cascade do |t|
    t.bigint "dossier_id", null: false
    t.string "nom"
    t.string "workflow_state"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "commentaire"
    t.index ["dossier_id"], name: "index_documents_on_dossier_id"
  end

  create_table "dossiers", force: :cascade do |t|
    t.bigint "intervenant_id", null: false
    t.string "période"
    t.string "workflow_state"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "slug"
    t.string "mémo"
    t.index ["intervenant_id"], name: "index_dossiers_on_intervenant_id"
    t.index ["slug"], name: "index_dossiers_on_slug"
  end

  create_table "envoi_logs", force: :cascade do |t|
    t.datetime "date_prochain"
    t.string "workflow_state"
    t.string "cible", default: "Testeurs"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "date_exécution"
    t.integer "cible_id"
  end

  create_table "etudiants", id: :serial, force: :cascade do |t|
    t.integer "formation_id"
    t.string "nom"
    t.string "prénom"
    t.string "email"
    t.string "mobile"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "civilité"
    t.string "lieu_naissance"
    t.string "pays_naissance"
    t.string "nationalité"
    t.string "adresse"
    t.string "cp"
    t.string "ville"
    t.string "dernier_ets"
    t.string "dernier_diplôme"
    t.string "cat_diplôme"
    t.string "num_sécu"
    t.string "nom_marital"
    t.date "date_de_naissance"
    t.string "num_apogée"
    t.string "poste_occupé"
    t.string "nom_entreprise"
    t.string "adresse_entreprise"
    t.string "cp_entreprise"
    t.string "ville_entreprise"
    t.string "workflow_state"
    t.index ["formation_id"], name: "index_etudiants_on_formation_id"
    t.index ["workflow_state"], name: "index_etudiants_on_workflow_state"
  end

  create_table "fermetures", id: :serial, force: :cascade do |t|
    t.date "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "nom"
    t.index ["date"], name: "index_fermetures_on_date"
  end

  create_table "formations", id: :serial, force: :cascade do |t|
    t.string "nom"
    t.string "promo"
    t.string "diplome"
    t.string "domaine"
    t.boolean "apprentissage"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "memo"
    t.integer "nbr_etudiants", default: 0
    t.integer "nbr_heures"
    t.string "abrg"
    t.integer "user_id"
    t.string "color"
    t.string "forfait_hetd"
    t.decimal "taux_td", precision: 10, scale: 2, default: "0.0"
    t.string "code_analytique"
    t.boolean "hors_catalogue", default: false
    t.boolean "archive"
    t.boolean "hss"
    t.string "courriel"
    t.string "nomtauxtd"
    t.index ["archive"], name: "index_formations_on_archive"
    t.index ["user_id"], name: "index_formations_on_user_id"
  end

  create_table "import_log_lines", id: :serial, force: :cascade do |t|
    t.integer "import_log_id"
    t.integer "num_ligne"
    t.integer "etat"
    t.text "message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["import_log_id"], name: "index_import_log_lines_on_import_log_id"
  end

  create_table "import_logs", id: :serial, force: :cascade do |t|
    t.string "model_type"
    t.integer "etat"
    t.integer "nbr_lignes"
    t.integer "lignes_importees"
    t.string "fichier"
    t.string "message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["user_id"], name: "index_import_logs_on_user_id"
  end

  create_table "intervenants", id: :serial, force: :cascade do |t|
    t.string "nom"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "prenom"
    t.string "email"
    t.string "linkedin_url"
    t.string "titre1"
    t.string "titre2"
    t.string "spécialité"
    t.string "téléphone_fixe"
    t.string "téléphone_mobile"
    t.string "bureau"
    t.string "photo"
    t.integer "status"
    t.datetime "remise_dossier_srh"
    t.string "adresse"
    t.string "cp"
    t.string "ville"
    t.boolean "doublon"
    t.integer "nbr_heures_statutaire"
    t.date "date_naissance"
    t.string "memo"
    t.boolean "notifier"
    t.string "slug"
    t.integer "année_entrée"
    t.index ["slug"], name: "index_intervenants_on_slug", unique: true
  end

  create_table "invits", force: :cascade do |t|
    t.bigint "cour_id", null: false
    t.bigint "intervenant_id", null: false
    t.string "msg"
    t.string "workflow_state"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "reponse"
    t.string "slug"
    t.string "nom"
    t.integer "ue"
    t.bigint "user_id", null: false
    t.index ["cour_id"], name: "index_invits_on_cour_id"
    t.index ["intervenant_id"], name: "index_invits_on_intervenant_id"
    t.index ["slug"], name: "index_invits_on_slug", unique: true
    t.index ["user_id"], name: "index_invits_on_user_id"
  end

  create_table "mail_logs", force: :cascade do |t|
    t.string "to"
    t.string "subject"
    t.string "message_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "user_id"
  end

  create_table "ouvertures", force: :cascade do |t|
    t.string "bloc", null: false
    t.integer "jour", null: false
    t.time "début", null: false
    t.time "fin", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "pg_search_documents", force: :cascade do |t|
    t.text "content"
    t.string "searchable_type"
    t.bigint "searchable_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["searchable_type", "searchable_id"], name: "index_pg_search_documents_on_searchable"
  end

  create_table "responsabilites", id: :serial, force: :cascade do |t|
    t.integer "intervenant_id"
    t.string "titre"
    t.decimal "heures", precision: 5, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "debut"
    t.date "fin"
    t.integer "formation_id"
    t.string "commentaires"
    t.index ["formation_id"], name: "index_responsabilites_on_formation_id"
    t.index ["intervenant_id"], name: "index_responsabilites_on_intervenant_id"
  end

  create_table "salles", id: :serial, force: :cascade do |t|
    t.string "nom"
    t.integer "places"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "bloc"
    t.datetime "discarded_at"
    t.index ["discarded_at"], name: "index_salles_on_discarded_at"
  end

  create_table "unites", id: :serial, force: :cascade do |t|
    t.integer "formation_id"
    t.string "nom"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "num"
    t.integer "code"
    t.integer "séances", default: 0
    t.integer "heures", default: 0
    t.index ["formation_id"], name: "index_unites_on_formation_id"
    t.index ["num"], name: "index_unites_on_num"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "admin", default: false
    t.integer "formation_id"
    t.string "nom"
    t.string "prénom"
    t.string "mobile"
    t.boolean "reserver"
    t.datetime "discarded_at"
    t.integer "role", default: 0
    t.index ["discarded_at"], name: "index_users_on_discarded_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["formation_id"], name: "index_users_on_formation_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "vacations", id: :serial, force: :cascade do |t|
    t.integer "formation_id"
    t.integer "intervenant_id"
    t.string "titre"
    t.decimal "forfaithtd", precision: 5, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "date"
    t.integer "qte"
    t.string "commentaires"
    t.index ["formation_id"], name: "index_vacations_on_formation_id"
    t.index ["intervenant_id"], name: "index_vacations_on_intervenant_id"
  end

  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "documents", "dossiers"
  add_foreign_key "invits", "cours"
  add_foreign_key "invits", "intervenants"
  add_foreign_key "invits", "users"

  create_view "cours_non_planifies", materialized: true, sql_definition: <<-SQL
      SELECT cours.id
     FROM cours
    WHERE ((cours.id IN ( SELECT audits.auditable_id
             FROM audits
            WHERE (((audits.auditable_type)::text = 'Cour'::text) AND (audits.user_id <> 41)))) AND (cours.etat = 0) AND ((cours.debut >= now()) AND (cours.debut <= (now() + 'P30D'::interval))));
  SQL
end
