class EdusignJob < ApplicationJob
  queue_as :default

  def perform(type_task, current_user_id, args=nil)
    
    @current_user_id = current_user_id

    case type_task
    when "Sync log"
      synchronisation_edusign
    when "Initialisation"
      initialisation_edusign
    when "sync manuelle"
      synchronisation_manuelle_edusign(args)
    when "salle changée"
      changement_salle_edusign(args)
    end
    
  end

  def synchronisation_edusign
    etat = 0

    # capture output
    @stream = capture_stdout do
      request = Edusign.new
      puts "C'est parti !"

      request.call
      
      etat = request.get_etat
    end

    EdusignLog.create(modele_type: 1, message: @stream, user_id: @current_user_id, etat: etat)
  end

  def initialisation_edusign
    etat = 0

    # capture output
    @stream = capture_stdout do
      request = Edusign.new
      puts "Démarrage de l'initialisation de la synchronisation avec Edusign !"

      request.initialisation
      
      etat = request.get_etat
    end

    EdusignLog.create(modele_type: 0, message: @stream, user_id: @current_user_id, etat: etat)
  end
  
  def synchronisation_manuelle_edusign(args)
    record_type = args[:record_type]
    record_id = args[:record_id]

    etat = 0

    # capture output
    stream = capture_stdout do
      request = Edusign.new

      case record_type
      when "intervenant"
        request.export_intervenant(record_id)
      when "formation"
        request.export_formation(record_id)
      when "etudiant"
        request.export_etudiant(record_id)
      end

      etat = request.get_etat
    end

    EdusignLog.create(modele_type: 2, message: stream, user_id: @current_user_id, etat: etat)
  end

  def changement_salle_edusign(args)
    cour_id = args[:cour_id]
    
    etat = 0

    # capture output
    stream = capture_stdout do
      request = Edusign.new
      request.export_cours(cour_id)
      etat = request.get_etat
    end

    EdusignLog.create(modele_type: 3, message: stream, user_id: @current_user_id, etat: etat)
  end
end
