class ExportPdf
    include Prawn::View
  
    # Taille et orientation du document par défaut
    # def document
    #     @document ||= Prawn::Document.new(page_size: 'A4', page_layout: :landscape)
    # end

    def initialize
        super()
        self.font_families.update("OpenSans" => {
            :normal => Rails.root.join("vendor/assets/fonts/Open_Sans/static/OpenSans/OpenSans-Regular.ttf"),
            :italic => Rails.root.join("vendor/assets/fonts/Open_Sans/static/OpenSans/OpenSans-Italic.ttf"),
            :bold => Rails.root.join("vendor/assets/fonts/Open_Sans/static/OpenSans/OpenSans-Bold.ttf"),
            :bold_italic => Rails.root.join("vendor/assets/fonts/Open_Sans/static/OpenSans/OpenSans-BoldItalic.ttf")
        })

        @margin_down = 15
        @image_path =  "#{Rails.root}/app/assets/images/"
    end

    def export_liste_des_cours(cours, show_comments = false)
        data = [ ['Formation/Date', 'Heure', 'Durée', 'Intervenant', 'Binôme', 'UE', 'Intitulé', 'Obs'] ]
  
        formation = nil
        cours.includes(:intervenant, :formation).each do | c |
          if c.formation != formation
            data += [ ["<b><i><color rgb='6495ED'><font size='9'>#{c.formation.nom}</font></color></i></b>"] ]
            formation = c.formation
          end
          data += [ generate_liste_des_cours_cell(c, show_comments) ]
        end
  
        font "Courier"
        font_size 8
        table(data, 
                  header: true, 
                  column_widths: [130, 40, 40, 100, 90, 25, 90, 25], 
                  cell_style: { :inline_format => true })
  
  
        move_down 30
        font_size 6
        text "Liste au #{I18n.l(Date.today, format: :long)}"
    end
  
    def generate_liste_des_cours_cell(c, show_comments)
        [
          I18n.l(c.debut.to_date, format: :long),
          "#{I18n.l(c.debut, format: :heures_min)} #{I18n.l(c.fin, format: :heures_min)}",
          "#{"%1.2f" % c.duree} h", 
          c.intervenant.nom_prenom,
          c.intervenant_binome.try(:nom_prenom),
          c.try(:ue),
          "<font size='7'>#{c.nom_ou_ue}</font>",
          show_comments ? "<font size='6'>#{c.commentaires}</font>" : ''
        ] 
    end
  
    def export_etats_de_services(cours, intervenants, start_date, end_date)
        intervenant = intervenants.first

        cours_ids = cours.where(intervenant: intervenant)
                         .where("hors_service_statutaire IS NOT TRUE")
                         .joins(:formation)
                         .pluck(:id)
                         .flatten

        cours_ids << cours
                        .where(intervenant_binome: intervenant)
                        .where("hors_service_statutaire IS NOT TRUE")
                        .joins(:formation)
                        .pluck(:id)
                        .flatten
        
        vacations = intervenant.vacations.where("date BETWEEN ? AND ?", start_date, end_date)
        responsabilites = intervenant.responsabilites.where("debut BETWEEN ? AND ?", start_date, end_date)
        
        cumul_hetd = cumul_vacations = cumul_resps = cumul_tarif = cumul_duree = 0 
        nbr_heures_statutaire = intervenant.nbr_heures_statutaire || 0
        cumul_eotp, cumul_eotp_durée = {}, {}

        image "#{@image_path}/logo@100.png", :height => 40, :position => :center
        move_down @margin_down

        font "Helvetica"
        text "Etat liquidatif des vacations d'enseignements", size: 18
        font_size 10
        text "Décrets 87-889 du 29/10/1987 et 88-994 du 18/10/88 - CAR du 07/12/2022"
        text "Centre de coût 7322GRH"
        move_down @margin_down

        text intervenant.nom_prenom
        text "Du #{I18n.l(start_date.to_date)} au #{I18n.l(end_date.to_date)}"
        move_down @margin_down

        data = [ ['Code','Dest. fi.','Date','Heure','Formation','Intitulé','Durée','CM/TD','Taux','HETD','Montant €'] ]

        # Cours 
        cours_ids.flatten.each do |id|
            c = Cour.find(id)
            cumul_duree += c.duree 
    
            if c.imputable?
                cumul_hetd += c.duree.to_f * c.HETD
                montant_service = c.montant_service.round(2)
                cumul_tarif += montant_service
                formation = Formation.unscoped.find(c.formation_id)
                eotp = formation.code_analytique_avec_indice(c)
                cumul_eotp.keys.include?(eotp) ? cumul_eotp[eotp] += montant_service : cumul_eotp[eotp] = montant_service
                cumul_eotp_durée.keys.include?(eotp) ? cumul_eotp_durée[eotp] += c.duree : cumul_eotp_durée[eotp] = c.duree
            end
    
            formation = Formation.unscoped.find(c.formation_id)

            data += [ [
                formation.code_analytique_avec_indice(c),
                formation.code_analytique_avec_indice(c).include?('DISTR') ? "101PAIE" : "102PAIE",
                I18n.l(c.debut.to_date),
                c.debut.strftime("%k:%M"),
                formation.abrg,
                "#{c.ue} #{c.nom_ou_ue}",
                c.duree.to_f,
                formation.nomtauxtd,
                c.taux_td,
                c.HETD,
                montant_service
            ] ]
        end    

        # Sous-total des Cours
        data += [ [   
            "<i><b>#{ cours_ids.flatten.count } cours au total</i></b>",
            nil, nil, nil, nil, nil,
            cumul_duree,
            nil, nil,
            cumul_hetd,
            "<b>#{cumul_tarif}</b>"
        ] ]


        # Vacations
        vacations.each_with_index do | vacation, index |
            montant_vacation = ((Cour.Tarif * vacation.forfaithtd) * vacation.qte).round(2)
            cumul_vacations += montant_vacation
            cumul_hetd += (vacation.qte * vacation.forfaithtd)
            formation = Formation.unscoped.find(vacation.formation_id) 
            
            data += [ [
                formation.code_analytique,
                formation.code_analytique.include?('DISTR') ? "101PAIE" : "102PAIE",
                I18n.l(vacation.date),
                nil,
                formation.nom,
                vacation.titre,
                vacation.qte,
                nil, nil,
                vacation.forfaithtd,
                montant_vacation
            ] ] 
    
            if index == vacations.size - 1
                data += [ [
                    "<b><i>#{vacations.size} vacation.s au total</i></b>",
                    nil, nil, nil, nil, nil, nil, nil, nil, nil,  
                    "<b>#{cumul_vacations}</b>"
                ] ]
            end
        end

        # Responsabilités
        responsabilites.each_with_index do |resp, index|
            montant_responsabilite = (resp.heures * Cour.Tarif).round(2)
            cumul_resps += montant_responsabilite
            cumul_hetd += resp.heures

            data += [ [
                resp.formation.code_analytique,
                resp.formation.code_analytique_avec_indice(resp).include?('DISTR') ? "101PAIE" : "102PAIE",
                I18n.l(resp.debut),
                nil,
                resp.formation.nom,
                resp.titre,
                resp.heures,
                'TD', 
                Cour.Tarif,
                nil,
                montant_responsabilite
                ] ]

            if index == responsabilites.size - 1
                data += [ [
                    "<i><b>#{ responsabilites.count } #{ responsabilites.count > 1 ? 'responsabilités' : 'responsabilité' } au total</i></b>",
                    nil, nil, nil, nil, nil,
                    nil,
                    nil, nil, nil,
                    "<b>#{ cumul_resps }</b>"
                    ] ]
            end
        end

        # Grand TOTAL
        s = nil
        if nbr_heures_statutaire > 0
            s = "#{nbr_heures_statutaire} h statutaire.s"
            if (nbr_heures_statutaire > 0) && (cumul_hetd >= nbr_heures_statutaire)
                s += "Dépassement: #{cumul_hetd - nbr_heures_statutaire} h"
            end
        end

        data += [ ["<b><i>TOTAL </i></b>", nil, nil, nil, nil, s, nil, nil, nil, nil, "<b>#{cumul_resps + cumul_vacations + cumul_tarif}</b>"] ]

        # Générer la Table
        font_size 7
        table(data, header: true, 
                column_widths: {0 => 105, 1 => 40, 2 => 50, 3 => 30, 4=> 70, 6 => 30, 7 => 35, 8 => 35, 9 => 30, 10 => 50},
                row_colors: ["F0F0F0", "FFFFFF"]) do | table | 
                    table.cells.style(inline_format: true, border_width: 1, border_color: 'C0C0C0')
                    table.column(6..10).style(:align => :right)
                end

        move_down @margin_down

        # Tableau récap par code OTP
        data = [ ['Code EOTP', 'Total services', 'Nbr heures de cours' ]]    

        cumul_eotp.each do |eotp|
            data += [ [
                eotp.first,
                eotp.last,
                cumul_eotp_durée[eotp.first].to_f,
            ] ]
        end

        table data, header: true, row_colors: ["F0F0F0", "FFFFFF"] do 
            column(1..2).style(:align => :right)
            cells.style(inline_format: true, border_width: 1, border_color: 'C0C0C0')
        end

        move_down @margin_down

        font "Helvetica"
        font_size 10

        text "Fait à Paris le #{I18n.l(Date.today)}", style: :italic
        move_down @margin_down

        y_position = cursor
        bounding_box([0, y_position], :width => 250, :height => 100) do
            text "Eric LAMARQUE"
            text "Directeur de l'IAE de Paris", size: 8
        end
        bounding_box([250, y_position], :width => 250) do
            text "Barbara FITSCH-MOURAS"
            text "Responsable du service Formation et développement", size: 8 
        end    
        
    end

    def export_vacations_administratives(examens, start_date, end_date, surveillant)
        taux_horaire = 11.27
        is_vacataire = false

        if agent = Agent.find_by(nom: surveillant.split('-').first, prénom: surveillant.split('-').last)
            taux_horaire = case agent.catégorie
                            when "A"
                                22.17
                            when "B"
                                14.41
                            when "C"
                                11.07
                            end
        end

        image "#{@image_path}/logo@100.png", :height => 40, :position => :center
        move_down @margin_down

        font "Helvetica"
        if agent
            text "Demande de paiement de vacations accessoires", size: 18
        else
            text "Vacations administratives", size: 18
        end

        font_size 10

        if agent
            text "Décret n°2003-1009 du 16/10/2003 relatif aux vacations susceptibles d’être allouées aux personnels"
            text "accomplissant des activités accessoires dans certains établissements d’enseignement supérieur"
        else
            text "Décret n° 2022-1608 du 22 décembre 2022 portant relèvement du salaire minimum de croissance"
        end
        move_down @margin_down

        text surveillant
        move_down @margin_down
        text "Du #{I18n.l(start_date.to_date)} au #{I18n.l(end_date.to_date)}"

        move_down @margin_down
        #text "Affaire suivie par : Thémoline"

        # Tableau récap par code OTP
        data = [ ['N°', 'Date', 'Type', 'Formation', 'Centre de coût', 'Destination financière', 'EOTP', 'Total heures' ]]    

        font_size 7
 
        cumul_durée = 0
        index = 0
 
        examens.each do | exam |
            exam.commentaires.split('[').each do |item|
                unless item.blank? 
                    surveillant_item = item.gsub(']', '').delete("\r\n\\")
                    if surveillant_item == surveillant
                        is_vacataire = (exam.intervenant_id == 1314)
                        index += 1
                        durée = exam.duree + 1 
                        cumul_durée += durée
                        data += [[ index,
                                    I18n.l(exam.debut.to_date, format: :long) + ' ' + I18n.l(exam.debut, format: :heures_min) + '-' + I18n.l(exam.fin, format: :heures_min),
                                    is_vacataire ? "Vacataire" : "Surveillance Examen",
                                    exam.formation.nom_promo,
                                    '7322GRH',
                                    (exam.formation.diplome.upcase == 'LICENCE' ? '101PAIE' : exam.intervenant.id == 1314 ? '115PAIE' : '102PAIE'),
                                    exam.formation.code_analytique_avec_indice(exam).gsub('HCO','VAC'),
                                    durée 
                                ]]
                        end
                end
            end
        end

        data += [[nil, nil, nil, nil, nil, nil, "Total heures :", "<b>#{ cumul_durée }</b>" ]]

        data += [[nil, nil, nil,
                    "Taux horaire en vigueur au 01/01/2023 :", 
                    "#{ taux_horaire } €",
                    nil,
                    "<b>Total brut :</b>",
                    "<b>#{ cumul_durée * taux_horaire } €</b>"]]

        # Corps de table
        table data, 
            header: true, 
            column_widths: {0 => 20, 1 => 110, 2 => 50, 3 => 135, 4 => 50, 5 => 50, 6 => 85, 7 => 40},
            row_colors: ["F0F0F0", "FFFFFF"] do 
                column(6).style(:align => :right)
                cells.style(inline_format: true, border_width: 1, border_color: 'C0C0C0')
            end
    
        move_down @margin_down

        # FOOTER
        font "Helvetica"
        font_size 10

        text "Fait à Paris le #{I18n.l(Date.today)}", style: :italic
        move_down @margin_down

        y_position = cursor
        if agent
            bounding_box([0, y_position], :width => 166, :height => 100) do
                text "L'agent"
            end
            bounding_box([166, y_position], :width => 166) do
                text "Le supérieur hiérarchique,"
                text "pour accord"
            end
            bounding_box([333, y_position], :width => 166) do
                text "Le responsable du service concerné"
                text "par la vacation, pour accord"
            end
        else
            bounding_box([0, y_position], :width => 250, :height => 100) do
                text "Eric LAMARQUE"
                text "Directeur de l'IAE Paris", size: 8
            end
            bounding_box([250, y_position], :width => 250) do
                text is_vacataire ? "" : "Barbara FITSCH-MOURAS"
                text "Responsable de service", size: 8 
            end
        end

    end

    def generate_feuille_emargement(cours, étudiants_id, table)
        font "OpenSans"

        cours.each_with_index do |cour, index|
            font_size 14

            y_position = cursor
            bounding_box([0, y_position], :width => 270) do
                image "#{@image_path}/logo@100.png", :width => 200
            end
            bounding_box([270, y_position], :width => 270) do
                move_down @margin_down
                text cour.formation.nom, style: :bold, align: :right
            end

            move_down @margin_down * 2
            text "ÉMARGEMENT", size: 16, style: :bold, align: :center

            font_size 12

            move_down @margin_down
            y_position = cursor
            bounding_box([0, y_position], :width => 250, :height => 100) do
                text "Date : #{I18n.l(cour.debut.to_date)}", style: :bold
            end
            bounding_box([250, y_position], :width => 250) do
                
                text "Horaire : #{I18n.l(cour.debut, format: :heures_min)} - #{I18n.l(cour.fin, format: :heures_min)}", style: :bold

            end
            move_down @margin_down
            text "Enseignant : #{cour.intervenant.nom_prenom}", style: :bold
            move_down @margin_down
            text "UE : #{cour.code_ue} - #{cour.nom_ou_ue}", style: :bold
            move_down @margin_down
            text "Signature :", style: :bold
            move_down @margin_down
            text "IMPORTANT : les données collectées par cette feuille d’émargement sont de nature à permettre la justification des heures effectuées dans le cadre de la formation.", size: 10, align: :center

            array = étudiants_id || cour.formation.etudiants.order(:nom, :prénom).pluck(:id)

            if examen = cour.examen?
                if table
                    data = [ ['<i>NOM PRÉNOM</i>', 'N° Table', '<i>SIGNATURE DÉBUT ÉPREUVE</i>', '<i>SIGNATURE REMISE COPIE</i>'] ]
                else
                    data = [ ['<i>NOM PRÉNOM</i>', '<i>SIGNATURE DÉBUT ÉPREUVE</i>', '<i>SIGNATURE REMISE COPIE</i>'] ]
                end
                (0..array.length - 1).each do |index|
                    etudiant = Etudiant.find(array[index])
                    data += [ [
                        "<b>#{etudiant.nom.upcase}</b> #{etudiant.prénom.humanize}",
                        Array.new(table ? 3 : 2)
                    ].flatten
                    ]
                end
            else
                data = [ ['<i>NOM PRÉNOM</i>', '<i>SIGNATURE</i>', '<i>NOM PRÉNOM</i>', '<i>SIGNATURE</i>'] ]
                (0..array.length - 1).step(2).each do |index|
                    etudiant = Etudiant.find(array[index])
                    if index < array.length - 1
                        next_etudiant = Etudiant.find(array[index + 1])
                    end
                    data += [ [
                        "<b>#{etudiant.nom.upcase}</b> #{etudiant.prénom.humanize}",
                        nil,
                        next_etudiant ? "<b>#{next_etudiant.nom.upcase}</b> #{next_etudiant.prénom.humanize}" : nil,
                        nil
                    ]
                    ]
                end
            end

            move_down @margin_down

            font_size 10
            table(data, 
                header: true,
                column_widths: examen ? (table ? [160, 60, 160, 160] : [180,180,180]) : [150, 120, 150, 120] ,
                cell_style: { :inline_format => true, height: 35 })

            start_new_page unless index == cours.size - 1
        end
    end


end