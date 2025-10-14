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

ActiveRecord::Schema[7.2].define(version: 2025_10_13_090926) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_stat_statements"
  enable_extension "plpgsql"

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", precision: nil, null: false
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
    t.datetime "created_at", precision: nil, null: false
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "alerts", force: :cascade do |t|
    t.datetime "debut", precision: nil
    t.datetime "fin", precision: nil
    t.string "message"
    t.integer "etat"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "attendances", force: :cascade do |t|
    t.boolean "état"
    t.datetime "signée_le"
    t.string "justificatif_edusign_id"
    t.integer "retard"
    t.datetime "exclu_le"
    t.bigint "etudiant_id", null: false
    t.bigint "cour_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "signature_email_id"
    t.string "signature"
    t.integer "edusign_id"
    t.index ["cour_id"], name: "index_attendances_on_cour_id"
    t.index ["etudiant_id"], name: "index_attendances_on_etudiant_id"
    t.index ["signature_email_id"], name: "index_attendances_on_signature_email_id"
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
    t.datetime "created_at", precision: nil
    t.index ["associated_id", "associated_type"], name: "associated_index"
    t.index ["auditable_id", "auditable_type"], name: "auditable_index"
    t.index ["created_at"], name: "index_audits_on_created_at"
    t.index ["request_uuid"], name: "index_audits_on_request_uuid"
    t.index ["user_id", "user_type"], name: "user_index"
  end

  create_table "cours", id: :serial, force: :cascade do |t|
    t.datetime "debut", precision: nil
    t.datetime "fin", precision: nil
    t.integer "formation_id"
    t.integer "intervenant_id"
    t.integer "salle_id"
    t.string "ue"
    t.string "nom"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "etat", default: 0
    t.decimal "duree", precision: 4, scale: 2, default: "0.0"
    t.integer "intervenant_binome_id"
    t.boolean "hors_service_statutaire"
    t.string "commentaires"
    t.boolean "elearning"
    t.integer "code_ue"
    t.string "edusign_id"
    t.boolean "no_send_to_edusign"
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "commentaire"
    t.index ["dossier_id"], name: "index_documents_on_dossier_id"
  end

  create_table "dossier_etudiants", force: :cascade do |t|
    t.bigint "etudiant_id"
    t.string "nom"
    t.string "prénom"
    t.string "mode_payement"
    t.string "workflow_state"
    t.string "slug"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "formation"
    t.string "email"
    t.string "adresse"
    t.string "téléphone_fixe"
    t.string "téléphone_mobile"
    t.string "civilité"
    t.date "date_naissance"
    t.string "nationalité"
    t.string "num_secu"
    t.string "nom_martial"
    t.string "nom_père"
    t.string "prénom_père"
    t.string "profession_père"
    t.string "nom_mère"
    t.string "prénom_mère"
    t.string "profession_mère"
    t.index ["etudiant_id"], name: "index_dossier_etudiants_on_etudiant_id"
  end

  create_table "dossiers", force: :cascade do |t|
    t.bigint "intervenant_id", null: false
    t.string "période"
    t.string "workflow_state"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug"
    t.string "mémo"
    t.bigint "mail_log_id"
    t.index ["intervenant_id"], name: "index_dossiers_on_intervenant_id"
    t.index ["mail_log_id"], name: "index_dossiers_on_mail_log_id"
    t.index ["slug"], name: "index_dossiers_on_slug"
  end

  create_table "edusign_logs", force: :cascade do |t|
    t.integer "modele_type"
    t.text "message"
    t.integer "user_id"
    t.integer "etat"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "envoi_logs", force: :cascade do |t|
    t.datetime "date_prochain", precision: nil
    t.string "workflow_state"
    t.string "cible", default: "Testeurs"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "date_exécution", precision: nil
    t.integer "cible_id"
    t.date "date_début"
    t.date "date_fin"
    t.integer "mail_count"
    t.string "message"
  end

  create_table "etudiants", id: :serial, force: :cascade do |t|
    t.integer "formation_id"
    t.string "nom"
    t.string "prénom"
    t.string "email"
    t.string "mobile"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
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
    t.integer "table", default: 0
    t.string "edusign_id"
    t.index ["formation_id"], name: "index_etudiants_on_formation_id"
    t.index ["workflow_state"], name: "index_etudiants_on_workflow_state"
  end

  create_table "evaluations", force: :cascade do |t|
    t.bigint "etudiant_id", null: false
    t.decimal "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "date"
    t.string "matière"
    t.string "examen"
    t.index ["etudiant_id"], name: "index_evaluations_on_etudiant_id"
  end

  create_table "fermetures", id: :serial, force: :cascade do |t|
    t.date "date"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "nom"
    t.index ["date"], name: "index_fermetures_on_date"
  end

  create_table "formations", id: :serial, force: :cascade do |t|
    t.string "nom"
    t.string "promo"
    t.string "diplome"
    t.string "domaine"
    t.boolean "apprentissage"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
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
    t.string "edusign_id"
    t.boolean "send_to_edusign"
    t.index ["archive"], name: "index_formations_on_archive"
    t.index ["user_id"], name: "index_formations_on_user_id"
  end

  create_table "import_log_lines", id: :serial, force: :cascade do |t|
    t.integer "import_log_id"
    t.integer "num_ligne"
    t.integer "etat"
    t.text "message"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["import_log_id"], name: "index_import_log_lines_on_import_log_id"
  end

  create_table "import_logs", id: :serial, force: :cascade do |t|
    t.string "model_type"
    t.integer "etat"
    t.integer "nbr_lignes"
    t.integer "lignes_importees"
    t.string "fichier"
    t.string "message"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "user_id"
    t.index ["user_id"], name: "index_import_logs_on_user_id"
  end

  create_table "intervenants", id: :serial, force: :cascade do |t|
    t.string "nom"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
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
    t.datetime "remise_dossier_srh", precision: nil
    t.string "adresse"
    t.string "cp"
    t.string "ville"
    t.boolean "doublon", default: false
    t.integer "nbr_heures_statutaire"
    t.date "date_naissance"
    t.string "memo"
    t.boolean "notifier"
    t.string "slug"
    t.integer "année_entrée"
    t.string "email2"
    t.string "edusign_id"
    t.index ["slug"], name: "index_intervenants_on_slug", unique: true
  end

  create_table "invits", force: :cascade do |t|
    t.bigint "cour_id", null: false
    t.bigint "intervenant_id", null: false
    t.string "msg"
    t.string "workflow_state"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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

  create_table "justificatifs", force: :cascade do |t|
    t.string "edusign_id"
    t.string "commentaires"
    t.bigint "etudiant_id", null: false
    t.datetime "edusign_created_at"
    t.datetime "accepte_le"
    t.datetime "debut"
    t.datetime "fin"
    t.string "file_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "motif_id", null: false
    t.index ["etudiant_id"], name: "index_justificatifs_on_etudiant_id"
    t.index ["motif_id"], name: "index_justificatifs_on_motif_id"
  end

  create_table "mail_logs", force: :cascade do |t|
    t.string "to"
    t.string "subject"
    t.string "message_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.boolean "statut", default: true
    t.boolean "opened", default: false
    t.json "error_message"
    t.string "title"
  end

  create_table "motifs", force: :cascade do |t|
    t.integer "edusign_id"
    t.string "nom"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "notes", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "titre"
    t.string "texte"
    t.string "couleur"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_notes_on_user_id"
  end

  create_table "options", force: :cascade do |t|
    t.bigint "cour_id", null: false
    t.bigint "user_id", null: false
    t.integer "catégorie", null: false
    t.string "description"
    t.boolean "fait"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cour_id"], name: "index_options_on_cour_id"
    t.index ["user_id"], name: "index_options_on_user_id"
  end

  create_table "ouvertures", force: :cascade do |t|
    t.string "bloc", null: false
    t.integer "jour", null: false
    t.time "début", null: false
    t.time "fin", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "pg_search_documents", force: :cascade do |t|
    t.text "content"
    t.string "searchable_type"
    t.bigint "searchable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["searchable_type", "searchable_id"], name: "index_pg_search_documents_on_searchable"
  end

  create_table "presences", force: :cascade do |t|
    t.bigint "cour_id", null: false
    t.string "signature"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "ip"
    t.integer "code_ue"
    t.string "workflow_state"
    t.bigint "etudiant_id"
    t.bigint "intervenant_id"
    t.datetime "signée_le", precision: nil
    t.string "slug"
    t.index ["cour_id"], name: "index_presences_on_cour_id"
    t.index ["etudiant_id"], name: "index_presences_on_etudiant_id"
    t.index ["intervenant_id"], name: "index_presences_on_intervenant_id"
    t.index ["slug"], name: "index_presences_on_slug", unique: true
  end

  create_table "responsabilites", id: :serial, force: :cascade do |t|
    t.integer "intervenant_id"
    t.string "titre"
    t.decimal "heures", precision: 5, scale: 2
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
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
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "bloc"
    t.datetime "discarded_at", precision: nil
    t.index ["discarded_at"], name: "index_salles_on_discarded_at"
  end

  create_table "signature_emails", force: :cascade do |t|
    t.integer "nb_envoyee"
    t.string "requete_edusign_id"
    t.datetime "limite"
    t.boolean "second_envoi"
    t.datetime "envoi_email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "attendance_id"
    t.index ["attendance_id"], name: "index_signature_emails_on_attendance_id"
  end

  create_table "solid_queue_blocked_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "queue_name", null: false
    t.integer "priority", default: 0, null: false
    t.string "concurrency_key", null: false
    t.datetime "expires_at", null: false
    t.datetime "created_at", null: false
    t.index ["concurrency_key", "priority", "job_id"], name: "index_solid_queue_blocked_executions_for_release"
    t.index ["expires_at", "concurrency_key"], name: "index_solid_queue_blocked_executions_for_maintenance"
    t.index ["job_id"], name: "index_solid_queue_blocked_executions_on_job_id", unique: true
  end

  create_table "solid_queue_claimed_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.bigint "process_id"
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_claimed_executions_on_job_id", unique: true
    t.index ["process_id", "job_id"], name: "index_solid_queue_claimed_executions_on_process_id_and_job_id"
  end

  create_table "solid_queue_failed_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.text "error"
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_failed_executions_on_job_id", unique: true
  end

  create_table "solid_queue_jobs", force: :cascade do |t|
    t.string "queue_name", null: false
    t.string "class_name", null: false
    t.text "arguments"
    t.integer "priority", default: 0, null: false
    t.string "active_job_id"
    t.datetime "scheduled_at"
    t.datetime "finished_at"
    t.string "concurrency_key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active_job_id"], name: "index_solid_queue_jobs_on_active_job_id"
    t.index ["class_name"], name: "index_solid_queue_jobs_on_class_name"
    t.index ["finished_at"], name: "index_solid_queue_jobs_on_finished_at"
    t.index ["queue_name", "finished_at"], name: "index_solid_queue_jobs_for_filtering"
    t.index ["scheduled_at", "finished_at"], name: "index_solid_queue_jobs_for_alerting"
  end

  create_table "solid_queue_pauses", force: :cascade do |t|
    t.string "queue_name", null: false
    t.datetime "created_at", null: false
    t.index ["queue_name"], name: "index_solid_queue_pauses_on_queue_name", unique: true
  end

  create_table "solid_queue_processes", force: :cascade do |t|
    t.string "kind", null: false
    t.datetime "last_heartbeat_at", null: false
    t.bigint "supervisor_id"
    t.integer "pid", null: false
    t.string "hostname"
    t.text "metadata"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.index ["last_heartbeat_at"], name: "index_solid_queue_processes_on_last_heartbeat_at"
    t.index ["name", "supervisor_id"], name: "index_solid_queue_processes_on_name_and_supervisor_id", unique: true
    t.index ["supervisor_id"], name: "index_solid_queue_processes_on_supervisor_id"
  end

  create_table "solid_queue_ready_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "queue_name", null: false
    t.integer "priority", default: 0, null: false
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_ready_executions_on_job_id", unique: true
    t.index ["priority", "job_id"], name: "index_solid_queue_poll_all"
    t.index ["queue_name", "priority", "job_id"], name: "index_solid_queue_poll_by_queue"
  end

  create_table "solid_queue_recurring_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "task_key", null: false
    t.datetime "run_at", null: false
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_recurring_executions_on_job_id", unique: true
    t.index ["task_key", "run_at"], name: "index_solid_queue_recurring_executions_on_task_key_and_run_at", unique: true
  end

  create_table "solid_queue_recurring_tasks", force: :cascade do |t|
    t.string "key", null: false
    t.string "schedule", null: false
    t.string "command", limit: 2048
    t.string "class_name"
    t.text "arguments"
    t.string "queue_name"
    t.integer "priority", default: 0
    t.boolean "static", default: true, null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_solid_queue_recurring_tasks_on_key", unique: true
    t.index ["static"], name: "index_solid_queue_recurring_tasks_on_static"
  end

  create_table "solid_queue_scheduled_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "queue_name", null: false
    t.integer "priority", default: 0, null: false
    t.datetime "scheduled_at", null: false
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_scheduled_executions_on_job_id", unique: true
    t.index ["scheduled_at", "priority", "job_id"], name: "index_solid_queue_dispatch_all"
  end

  create_table "solid_queue_semaphores", force: :cascade do |t|
    t.string "key", null: false
    t.integer "value", default: 1, null: false
    t.datetime "expires_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["expires_at"], name: "index_solid_queue_semaphores_on_expires_at"
    t.index ["key", "value"], name: "index_solid_queue_semaphores_on_key_and_value"
    t.index ["key"], name: "index_solid_queue_semaphores_on_key", unique: true
  end

  create_table "sujets", force: :cascade do |t|
    t.bigint "cour_id", null: false
    t.bigint "mail_log_id"
    t.string "workflow_state"
    t.string "slug"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cour_id"], name: "index_sujets_on_cour_id"
    t.index ["mail_log_id"], name: "index_sujets_on_mail_log_id"
  end

  create_table "unites", id: :serial, force: :cascade do |t|
    t.integer "formation_id"
    t.string "nom"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
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
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at", precision: nil
    t.datetime "last_sign_in_at", precision: nil
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.boolean "admin", default: false
    t.integer "formation_id"
    t.string "nom"
    t.string "prénom"
    t.string "mobile"
    t.boolean "reserver"
    t.datetime "discarded_at", precision: nil
    t.integer "role", default: 0
    t.index ["discarded_at"], name: "index_users_on_discarded_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["formation_id"], name: "index_users_on_formation_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "vacation_activite_tarifs", force: :cascade do |t|
    t.bigint "vacation_activite_id"
    t.integer "statut", null: false
    t.integer "prix", default: 0
    t.decimal "forfait_hetd", precision: 6, scale: 2, default: "0.0"
    t.integer "max"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["vacation_activite_id"], name: "index_vacation_activite_tarifs_on_vacation_activite_id"
  end

  create_table "vacation_activites", force: :cascade do |t|
    t.string "nature", null: false
    t.string "nom", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "vacations", id: :serial, force: :cascade do |t|
    t.integer "formation_id"
    t.integer "intervenant_id"
    t.string "titre"
    t.decimal "forfaithtd", precision: 5, scale: 2
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.date "date"
    t.integer "qte"
    t.string "commentaires"
    t.bigint "vacation_activite_id"
    t.decimal "montant", precision: 6, scale: 2
    t.index ["formation_id"], name: "index_vacations_on_formation_id"
    t.index ["intervenant_id"], name: "index_vacations_on_intervenant_id"
    t.index ["vacation_activite_id"], name: "index_vacations_on_vacation_activite_id"
  end

  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "attendances", "cours"
  add_foreign_key "attendances", "etudiants"
  add_foreign_key "attendances", "signature_emails"
  add_foreign_key "documents", "dossiers"
  add_foreign_key "dossier_etudiants", "etudiants"
  add_foreign_key "dossiers", "mail_logs"
  add_foreign_key "evaluations", "etudiants"
  add_foreign_key "invits", "cours"
  add_foreign_key "invits", "intervenants"
  add_foreign_key "invits", "users"
  add_foreign_key "justificatifs", "etudiants"
  add_foreign_key "justificatifs", "motifs"
  add_foreign_key "notes", "users"
  add_foreign_key "options", "cours"
  add_foreign_key "options", "users"
  add_foreign_key "presences", "cours"
  add_foreign_key "presences", "etudiants"
  add_foreign_key "presences", "intervenants"
  add_foreign_key "signature_emails", "attendances", on_delete: :nullify
  add_foreign_key "solid_queue_blocked_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_claimed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_failed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_ready_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_recurring_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_scheduled_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "sujets", "cours"
  add_foreign_key "sujets", "mail_logs"
  add_foreign_key "vacation_activite_tarifs", "vacation_activites"
  add_foreign_key "vacations", "vacation_activites"

  create_view "cours_non_planifies", materialized: true, sql_definition: <<-SQL
      SELECT cours.id
     FROM cours
    WHERE ((cours.id IN ( SELECT audits.auditable_id
             FROM audits
            WHERE (((audits.auditable_type)::text = 'Cour'::text) AND (audits.user_id <> 41)))) AND (cours.etat = 0) AND ((cours.debut >= now()) AND (cours.debut <= (now() + 'P30D'::interval))));
  SQL
end
