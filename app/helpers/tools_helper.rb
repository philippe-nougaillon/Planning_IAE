module ToolsHelper

    # Rendre l'audit lisible 

    def prettify(audit)    

        pretty_changes = []
        
        audit.audited_changes.each do |c|
            key = c.first.humanize
            case key
            when 'Salle'
                if salle = convertir_id_salles(audit)
                    pretty_changes << salle
                end
            when 'Formation'
                ids = audit.audited_changes['formation_id']
                case ids.class.name
                when 'Integer'
                    pretty_changes << "#{key} initialisée à '#{Formation.unscoped.find(ids).nom}'"
                when 'Array'
                    if ids.first && ids.last 
                        pretty_changes << "#{key} changée de '#{Formation.unscoped.find(ids.first).nom}' à '#{Formation.unscoped.find(ids.last).nom}'"
                    elsif ids.first 
                        pretty_changes << "#{key} changée de '#{Formation.unscoped.find(ids.first).nom}' à 'nil'"
                    else
                        pretty_changes << "#{key} changée de 'nil' à '#{Formation.unscoped.find(ids.last).nom}'"
                    end
                end 
            when 'Intervenant'
                ids = audit.audited_changes['intervenant_id']
                case ids.class.name
                when 'Integer'
                    pretty_changes << "#{key} initialisé à '#{Intervenant.find(ids).nom_prenom}'"
                when 'Array'
                    pretty_changes << "#{key} changé de '#{Intervenant.find(ids.first).nom_prenom}' à '#{Intervenant.find(ids.last).nom_prenom}'"
                end 
            when 'User'
                ids = audit.audited_changes['user_id']
                case ids.class.name
                when 'Integer'
                    pretty_changes << "#{key} initialisé à '#{User.find(ids).nom_et_prénom}'"
                when 'Array'
                    pretty_changes << "#{key} changé de '#{User.find(ids.first).nom_et_prénom if ids.first}' à '#{User.find(ids.last).nom_et_prénom if ids.last}'"
                end 
            when 'Debut' 
                if audit.audited_changes['debut'].class.name == 'Array'
                    pretty_changes << "Horaire de début modifié de '#{I18n.l(c.last.first, format: :long)}' à '#{I18n.l(c.last.last, format: :long)}'"
                else
                    pretty_changes << "Début initialisé à '#{I18n.l(c.last, format: :long)}'"
                end
            when 'Fin' 
                if audit.audited_changes['fin'].class.name == 'Array'
                    pretty_changes << "Horaire de fin modifié de '#{I18n.l(c.last.first, format: :long)}' à '#{I18n.l(c.last.last, format: :long)}'"
                else
                    pretty_changes << "Fin initialisée à '#{I18n.l(c.last, format: :long)}'"
                end
            when 'Etat'
                if audit.audited_changes['etat'].class.name == 'Array'
                    begin
                        pretty_changes << "État modifié de '#{ Cour.etats.keys[c.last.first].humanize if c.last.first }' à '#{ Cour.etats.keys[c.last.last].humanize if c.last.last }'"
                    rescue => e
                        pretty_changes << "/!\\ PB avec les données à convertir !"
                    end
                elsif audit.audited_changes['etat'].class.name == 'Integer'
                    pretty_changes << "État initialisé à '#{ Cour.etats.keys[c.last].humanize }'"
                else
                    pretty_changes << "État initialisé à '#{ c.last.humanize }'"
                end
            else
                if audit.action == 'update'
                    unless c.last.first.blank? && c.last.last.blank?    
                        pretty_changes << "#{key} modifié de '#{c.last.first}' à '#{c.last.last}'"
                    end
                else 
                    unless c.last.blank?
                        pretty_changes << "#{key} #{audit.action == 'create' ? 'initialisé à' : 'était'} '#{c.last}'"
                    end
                end
            end
        end
        pretty_changes
    end

    def audited_view_path(audit)
        case audit.auditable_type
        when "Cour"
            if Cour.exists?(audit.auditable_id)
                cour_path(audit.auditable_id)
            end
        when "User"
            if User.exists?(audit.auditable_id)
                user_path(audit.auditable_id)
            end
        when "Formation"
            if Formation.exists?(audit.auditable_id)
                formation_path(audit.auditable_id)
            end
        when "Intervenant"
            if Intervenant.exists?(audit.auditable_id)
                intervenant_path(audit.auditable_id)
            end
        when "Etudiant"
            if Etudiant.exists?(audit.auditable_id)
                etudiant_path(audit.auditable_id)
            end
        when "Salle"
            if Salle.exists?(audit.auditable_id)
                salle_path(audit.auditable_id)
            end
        when "Fermeture"
            if Fermeture.exists?(audit.auditable_id)
                fermeture_path(audit.auditable_id)
            end
        end
    end

    def convertir_id_salles(audit)
        # Rendre l'audit lisible quand changement de salle (nom des salles au lieu des id) 

        if audit.audited_changes.include?('salle_id') && audit.action != 'destroy'
            salle_id = audit.audited_changes['salle_id'] 
            if salle_id.class.name == 'Array' 
                if salle_id_was = salle_id.first 
                    salle_before = Salle.find(salle_id_was).nom 
                end 
                if salle_id = salle_id.last 
                    salle_after = Salle.find(salle_id).nom 
                end 
                if salle_before
                    return "Salle changée de '#{salle_before}' à '#{salle_after}'"
                else
                    return "Cours mis en salle '#{salle_after}"
                end
            else 
                if salle_id.class.name == 'Integer' 
                    salle_after = Salle.with_discarded.find(salle_id).nom 
                else 
                    salle_after = salle_id 
                end
                return "Salle initialisée à '#{salle_after}'"
            end  
        end 
    end

    def extract_salle_id(audit)
        # extraire l'id de la salle dans une ligne d'audit
        k = audit.audited_changes['salle_id']
        case k.class.name
        when 'Array'
            return k.last 
        when 'Integer'
            return k 
        else
            return nil
        end    
    end

end
