class ExportPdf
    include Prawn::View
    include ActionView::Helpers::NumberHelper
  
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

        data = [ ['Code','Dest. fi.','Date','Heure','Formation','Intitulé','Durée','CM/TD','Taux','HETD','Montant'] ]

        # Cours 
        cours_ids.flatten.each do |id|
            c = Cour.find(id)
            cumul_duree += c.duree 
    
            if c.imputable?
                cumul_hetd += c.duree.to_f * c.HETD
                montant_service = c.montant_service.round(2)
                cumul_tarif += montant_service
                formation = Formation.unscoped.find(c.formation_id)
                eotp = formation.code_analytique_avec_indice(c.debut)
                cumul_eotp.keys.include?(eotp) ? cumul_eotp[eotp] += montant_service : cumul_eotp[eotp] = montant_service
                cumul_eotp_durée.keys.include?(eotp) ? cumul_eotp_durée[eotp] += c.duree : cumul_eotp_durée[eotp] = c.duree
            end
    
            formation = Formation.unscoped.find(c.formation_id)

            data += [ [
                formation.code_analytique_avec_indice(c.debut),
                formation.code_analytique.include?('DISTR') ? "101PAIE" : "102PAIE",
                I18n.l(c.debut.to_date),
                c.debut.strftime("%k:%M"),
                formation.abrg,
                "#{c.ue} #{c.nom_ou_ue}",
                c.duree.to_f,
                formation.nomtauxtd,
                c.taux_td,
                c.HETD,
                number_to_currency(montant_service)
            ] ]
        end    

        # Sous-total des Cours
        data += [ [   
            "<i><b>#{ cours_ids.flatten.count } cours au total</i></b>",
            nil, nil, nil, nil, nil,
            cumul_duree,
            nil, nil,
            cumul_hetd,
            "<b>#{number_to_currency(cumul_tarif)}</b>"
        ] ]


        # Vacations
        vacations.each_with_index do | vacation, index |
            if vacation.forfaithtd > 0
                montant_vacation = ((Cour.Tarif * vacation.forfaithtd) * vacation.qte).round(2)
                cumul_hetd += (vacation.qte * vacation.forfaithtd)
            else
                montant_vacation = vacation.tarif * vacation.qte
            end
            cumul_vacations += montant_vacation
            formation = Formation.unscoped.find(vacation.formation_id) 
            
            data += [ [
                formation.code_analytique_avec_indice(vacation.date),
                formation.code_analytique.include?('DISTR') ? "101PAIE" : "102PAIE",
                I18n.l(vacation.date),
                nil,
                formation.nom,
                vacation.titre,
                vacation.qte,
                nil, nil,
                vacation.forfaithtd,
                number_to_currency(montant_vacation)
            ] ] 
    
            if index == vacations.size - 1
                data += [ [
                    "<b><i>#{vacations.size} vacation.s au total</i></b>",
                    nil, nil, nil, nil, nil, nil, nil, nil, nil,  
                    "<b>#{number_to_currency(cumul_vacations)}</b>"
                ] ]
            end
        end

        # Responsabilités
        responsabilites.each_with_index do |resp, index|
            montant_responsabilite = (resp.heures * Cour.Tarif).round(2)
            cumul_resps += montant_responsabilite
            cumul_hetd += resp.heures

            data += [ [
                resp.formation.code_analytique_avec_indice(resp.debut),
                resp.formation.code_analytique.include?('DISTR') ? "101PAIE" : "102PAIE",
                I18n.l(resp.debut),
                nil,
                resp.formation.nom,
                resp.titre,
                resp.heures,
                'TD', 
                Cour.Tarif,
                nil,
                number_to_currency(montant_responsabilite)
                ] ]

            if index == responsabilites.size - 1
                data += [ [
                    "<i><b>#{ responsabilites.count } #{ responsabilites.count > 1 ? 'responsabilités' : 'responsabilité' } au total</i></b>",
                    nil, nil, nil, nil, nil,
                    nil,
                    nil, nil, nil,
                    "<b>#{ number_to_currency(cumul_resps) }</b>"
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

        data += [ ["<b><i>TOTAL </i></b>", nil, nil, nil, nil, s, nil, nil, nil, nil, "<b>#{number_to_currency(cumul_resps + cumul_vacations + cumul_tarif)}</b>"] ]

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
        taux_horaire = 11.52
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
            text "Arrêté du 26 avril 2023 relatif au relèvement du salaire minimum de croissance"
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
                        durée = exam.duree + (is_vacataire ? 0 : 1)
                        cumul_durée += durée
                        data += [[ index,
                                    I18n.l(exam.debut.to_date, format: :long) + ' ' + I18n.l(exam.debut, format: :heures_min) + '-' + I18n.l(exam.fin, format: :heures_min),
                                    is_vacataire ? "Vacataire" : "Surveillance Examen",
                                    exam.formation.nom_promo,
                                    '7322GRH',
                                    (exam.formation.diplome.upcase == 'LICENCE' ? '101PAIE' : exam.intervenant.id == 1314 ? '115PAIE' : '102PAIE'),
                                    exam.formation.code_analytique_avec_indice(exam.debut).gsub('HCO','VAC'),
                                    durée 
                                ]]
                        end
                end
            end
        end

        data += [[nil, nil, nil, nil, nil, nil, "Total heures :", "<b>#{ cumul_durée }</b>" ]]

        data += [[nil, nil, nil,
                    "Taux horaire en vigueur au 01/05/2023 :", 
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

    def pochette_examen(cours, papier, calculatrice, outils)
        font "OpenSans"
        
        cours.each_with_index do |cour, index|
            surveillants = cour.commentaires.tr('[]', '').gsub(/[\r\n]/, ' ').split(' ').to_s.tr('\"[]', '').gsub(/[-]/, ' ')
            image "#{@image_path}/logo_iae_2.png", :height => 60

            move_down @margin_down * 2

            infos = [ ["<b><color rgb='E68824'>EMARGEMENT POUR SURVEILLANCE D’EXAMEN</color></b> \n <color rgb='032E4D'>(Exemplaire à conserver par le surveillant)</color>"] ]
            table(infos, cell_style: {inline_format: true, border_color: "E68824", align: :center})

            move_down @margin_down * 2
            text "<color rgb='032E4D'>NOM – Prénom du surveillant : <b>#{surveillants}</b></color>", inline_format: true


            move_down @margin_down * 2

            data = [ ["<color rgb='032E4D'>Date</color>", "<color rgb='032E4D'><b>#{I18n.l(cour.debut.to_date)}</b></color>"],
                    ["<color rgb='032E4D'>Formation(s)</color>","<color rgb='032E4D'><b>#{cour.formation.nom}</b></color>"],
                    ["<color rgb='032E4D'>Examen(s)</color>","<color rgb='032E4D'><b>UE#{cour.code_ue || '?'}</b></color>"],
                    ["<color rgb='032E4D'>Horaires de surveillance   (nbre d’heures rémunérées)</color>",
                    "<color rgb='032E4D'><b>#{cour.debut.strftime('%Hh%M')}-#{cour.fin.strftime('%Hh%M')} (#{((cour.fin - cour.debut) / 1.hour).truncate} heure.s)????</b></color>"],
                    ["<color rgb='032E4D'>Taux horaire de vacation en vigueur au 01/05/2023</color>","<color rgb='032E4D'><b>11,52 €</b></color>"] ]

            table(data, 
                header: true, 
                column_widths: [150, 350], 
                row_colors: ["FFEAD5", "FFFFFF"],
                cell_style: { inline_format: true},
                position: :center)

            move_down @margin_down * 3
            data2 = [ ["<color rgb='032E4D'>Cadre réservé au \n<b>Surveillant</b></color>"], ["<color rgb='032E4D'>Date :  ……./………/2023 \n\n Signature : \n\n\n\n\n\n\n\n\n\n</color>"]]
                table(data2, 
                    header: true, 
                    column_widths: [300],
                    cell_style: { inline_format: true, width: 300, align: :center, color: "032E4D"},
                    position: :center)

            start_new_page

            image "#{@image_path}/logo_iae_2.png", :height => 60

            move_down @margin_down * 4

            infos = [ ["<color rgb='E68824'><b>EMARGEMENT POUR SURVEILLANCE D’EXAMEN</b></color> \n<color rgb='032E4D'> (Exemplaire à remettre à l’Administration)</color>"] ]
            table(infos, cell_style: {inline_format: true, border_color: "E68824", align: :center})

            move_down @margin_down

            text "<color rgb='032E4D'>NOM – Prénom du surveillant : <b>#{surveillants}</b></color>", inline_format: true

            move_down @margin_down

            table(data, 
                header: true, 
                column_widths: [150, 350], 
                row_colors: ["FFEAD5", "FFFFFF"],
                cell_style: { inline_format: true},
                position: :center)

            move_down @margin_down * 3

            data3 = [ ["<color rgb='032E4D'>Cadre réservé au \n<b>Surveillant</b></color>", "<color rgb='032E4D'>Cadre réservé à \n<b>l’Administration</b></color>"]]
            data3 += [ ["<color rgb='032E4D'>\n\nDate :  ……./………/2023 \n\n Signature : \n\n\n\n\n\n\n</color>", "<color rgb='032E4D'>\n\nSaisie dans l’Outil Planning le \n\n\n ……./………/2023 \n\n\n\n\n\n</color>"] ]

            move_down @margin_down
            table(data3, 
                header: true, 
                column_widths: [250, 250],
                cell_style: { inline_format: true, align: :center},
                position: :center)

            start_new_page

            image "#{@image_path}/logo@100.png", :height => 60, position: :center

            move_down @margin_down * 2
            

            infos = [ ["<color rgb='E68824'><b>PROCÈS-VERBAL DE DÉROULEMENT D’EXAMEN</b></color>"] ]
            table(infos, cell_style: {inline_format: true, width: 540, border_color: "E68824", align: :center})

            move_down @margin_down *2

            text "<color rgb='032E4D'><b>UE#{cour.code_ue || "?"} #{cour.nom_ou_ue || "?????"}</b></color>",inline_format: true, size: 16

            move_down @margin_down 

            text "<color rgb='032E4D'><u>Pour tous problèmes importants durant l’examen, contacter le responsable(s) de l’UE</u> :</color>", inline_format: true
            text "<color rgb='032E4D'><b>#{Intervenant.find_by(id: cour.intervenant_binome_id).prenom_nom} (tel: #{Intervenant.find_by(id: cour.intervenant_binome_id).téléphone_mobile})</b></color>", inline_format: true

            move_down @margin_down

            table([ ["<color rgb='032E4D'>•</color>", "<color rgb='032E4D'><b>Formation : #{cour.formation.nom}</b></color>"],
                ["<color rgb='032E4D'>•</color>", "<color rgb='032E4D'><b>Date : #{I18n.l(cour.debut.to_date)}</b></color>"],
                ["<color rgb='032E4D'>•</color>", "<color rgb='032E4D'><b>Horaires : #{cour.debut.strftime('%Hh%M')}-#{cour.fin.strftime('%Hh%M')}</b></color>"],
                ["<color rgb='032E4D'>•</color>", "<color rgb='032E4D'><b>Salle : #{cour.salle.nom}</b></color>"] ],
                cell_style: { borders: [], inline_format: true })
            move_down @margin_down / 2
            table([ ["<color rgb='032E4D'>•</color>", "<color rgb='032E4D'><b>Nombre d’étudiants inscrits : #{cour.formation.nbr_etudiants} à vérifer !!!</b></color>"],
                    ["<color rgb='032E4D'>•</color>", "<color rgb='032E4D'>Nombre de copies rendues : ....................................</color>"] ],
                    cell_style: { borders: [], inline_format: true })
            move_down @margin_down / 2
            table([ ["<color rgb='032E4D'>•</color>", "<color rgb='032E4D'><b>Nom(s) du/des surveillant(s) : #{surveillants}</b></color>"] ],
            cell_style: { borders: [], inline_format: true })

            move_down @margin_down * 2

            text "<color rgb='032E4D'><b><u>COMPTE-RENDU DU DÉROULEMENT DE L’EXAMEN</u></b></color>", inline_format: true, align: :center

            text "[_]  <color rgb='032E4D'><b>R. A. S.</b></color>", inline_format: true
            text "[_]  <color rgb='032E4D'><b>INCIDENT</b></color>", inline_format: true

            move_down @margin_down

            text "<color rgb='032E4D'><b>Dans ce dernier cas,</b> indiquez ci-après les observations ou incidents constatés pendant l’examen :</color>", inline_format: true

            move_down @margin_down * 6

            y_position = cursor
            bounding_box([20, y_position], :width => 150) do
                text "<color rgb='032E4D'>Signature(s) surveillant(es)</color>", inline_format: true
            end
            bounding_box([350, y_position], :width => 190) do
                text "<color rgb='032E4D'>Signature de l’étudiant impliqué \ndans l’incident, le cas échéant</color>", inline_format: true
            end    

            start_new_page(layout: :landscape)

            text "<color rgb='032E4D'><b>#{cour.formation.nom}</b></color>", inline_format: true, align: :center, size: 32

            move_down @margin_down * 2

            text "<color rgb='032E4D'><u>Surveillant.e.s :</u></color>", inline_format: true, size: 24
            text "<color rgb='032E4D'><b>#{surveillants}</b></color>", inline_format: true, size: 24
            move_down @margin_down
            text "<color rgb='032E4D'>Examen <b>UE#{cour.code_ue || '?'} #{cour.nom_ou_ue}</b></color>", inline_format: true, size: 24
            text "<color rgb='032E4D'>Le <b>#{I18n.l(cour.debut.to_date)}</b></color>", inline_format: true, size: 24
            text "<color rgb='032E4D'>De <b>#{cour.debut.strftime('%Hh%M')} à #{cour.fin.strftime('%Hh%M')}</b></color>", inline_format: true, size: 24
            text "<color rgb='032E4D'>Salle <b>#{cour.salle.nom}</b></color>", inline_format: true, size: 24

            move_down @margin_down * 2
            text "<color rgb='FF0000'>=>   <b><u>En fin d’épreuve</u>, merci de remettre l’enveloppe contenant les copies à l’accueil.</b></color>", inline_format: true, size: 24

            start_new_page(layout: :portrait)

            image "#{@image_path}/logo_iae_2.png", :height => 60

            move_down @margin_down * 4

            text "<color rgb='032E4D'><b>UE#{cour.code_ue || "?"} #{cour.nom_ou_ue}</b></color>", inline_format: true, size: 16
            text "<color rgb='032E4D'><b>Examen du #{I18n.l(cour.debut.to_date)}</b></color>", inline_format: true, size: 16

            move_down @margin_down * 3

            text "<color rgb='E68824'><b>#{cour.formation.nom}</b></color>", inline_format: true, size: 16
            text "<color rgb='E68824'>#{'Formation en apprentissage' if cour.formation.apprentissage}</b></color>", inline_format: true, size: 16
            move_down @margin_down * 2
            text "<color rgb='032E4D'>Enseignant : #{Intervenant.find_by(id: cour.intervenant_binome_id).nom}</color>", inline_format: true
            move_down @margin_down
            text "<color rgb='032E4D'>Durée : #{((cour.fin - cour.debut) / 1.hour).truncate}h (#{(((cour.fin - cour.debut) / 1.hour).truncate) + 1}h pour le tiers temps)</color>", inline_format: true
            move_down @margin_down
            text "<color rgb='032E4D'>> Documents papier #{papier ? "autorisés" : "interdits"}</color>", inline_format: true
            text "<color rgb='032E4D'>> Calculatrice de poche à fonctionnement autonome, sans imprimante et sans aucun moyen de transmission #{calculatrice ? "autorisée" : "interdite"}</color>", inline_format: true
            text "<color rgb='032E4D'>> Les ordinateurs, tablettes et téléphones portables sont #{outils ? "autorisés" : "interdits"}</color>", inline_format: true

            move_down @margin_down * 3

            text "<color rgb='032E4D'>Promotion ???</color>", inline_format: true, align: :right

            start_new_page

            image "#{@image_path}/logo_iae_2.png", :height => 60

            move_down @margin_down * 4

            text "<color rgb='032E4D'><b>UE#{cour.code_ue || "?"} #{cour.nom_ou_ue}</b></color>", inline_format: true, size: 16
            text "<color rgb='032E4D'><b>Examen du #{I18n.l(cour.debut.to_date)}</b></color>", inline_format: true, size: 16

            move_down @margin_down * 2
            text "<color rgb='032E4D'><i>Merci d’indiquer votre numéro étudiant : .......................</i></color>", inline_format: true, size: 16

            move_down @margin_down * 2

            text "<color rgb='E68824'><b>#{cour.formation.nom}</b></color>", inline_format: true, size: 16
            text "<color rgb='E68824'>#{'Formation en apprentissage' if cour.formation.apprentissage}</b></color>", inline_format: true, size: 16
            move_down @margin_down * 2
            text "<color rgb='032E4D'>Enseignant : #{Intervenant.find_by(id: cour.intervenant_binome_id).nom}</color>", inline_format: true, size: 16
            move_down @margin_down
            text "<color rgb='032E4D'>Durée : #{((cour.fin - cour.debut) / 1.hour).truncate}h</color>", inline_format: true
            move_down @margin_down
            text "<color rgb='032E4D'>> Documents papier #{papier ? "autorisés" : "interdits"}</color>", inline_format: true
            text "<color rgb='032E4D'>> Calculatrice de poche à fonctionnement autonome, sans imprimante et sans aucun moyen de transmission #{calculatrice ? "autorisée" : "interdite"}</color>", inline_format: true
            text "<color rgb='032E4D'>> Les ordinateurs, tablettes et téléphones portables sont #{outils ? "autorisés" : "interdits"}</color>", inline_format: true

            move_down @margin_down * 3

            text "<color rgb='032E4D'>Promotion ???</color>", inline_format: true, align: :right
        end
    end

    def convocation(cour, étudiant, papier, calculatrice, outils)
        font "OpenSans"

        image "#{@image_path}/logo_iae_2.png", :height => 100, :position => :center
        move_down @margin_down
        text "<color rgb='032E4D'><b>#{cour.formation.nom.upcase}</b></color>", inline_format: true, size: 16, style: :bold, align: :center
        move_down @margin_down
        text "<color rgb='032E4D'><b>Promotion #{cour.formation.promo}</b></color>", inline_format: true, size: 16, align: :center
        move_down @margin_down
        text "<color rgb='E68824'><b>Convocation aux Examens</b></color>", inline_format: true, size: 24, align: :center

        move_down @margin_down * 2
        y_position = cursor
        bounding_box([100, y_position], :width => 190, :height => 100) do
            text "<color rgb='032E4D'><b>Nom : #{étudiant.nom}</b></color>", inline_format: true, size: 16
        end
        bounding_box([350, y_position], :width => 190) do
            text "<color rgb='032E4D'><b>Prénom : #{étudiant.prénom}</b></color>", inline_format: true, size: 16
        end

        move_down @margin_down * 2
        text "<color rgb='E68824'><b>Examen de l’UE #{cour.code_ue} - #{cour.ue}</b></color>", inline_format: true, size: 16, align: :center
        move_down @margin_down
        text "<color rgb='E68824'><b>Le #{cour.debut.to_date} de #{cour.debut.strftime('%Hh%M')} à #{cour.fin.strftime('%Hh%M')} en salle #{cour.salle.nom}</b></color>", inline_format: true, size: 16, align: :center

        move_down @margin_down
        text "<color rgb='032E4D'><b>Vous devez :
            -    vous munir de votre carte d'étudiant
            -    vous présenter dans la salle d'examen 15 minutes avant le début de l'épreuve</b></color>", inline_format: true

        move_down @margin_down
        text "<color rgb='032E4D'><b>> Documents papier #{papier ? "autorisés" : "interdits"}</b></color>", inline_format: true
        text "<color rgb='032E4D'><b>> Calculatrice de poche à fonctionnement autonome, sans imprimante et sans aucun moyen de transmission #{calculatrice ? "autorisée" : "interdite"}</b></color>", inline_format: true
        text "<color rgb='032E4D'><b>> Les ordinateurs, tablettes et téléphones portables sont #{outils ? "autorisés" : "interdits"}</b></color>", inline_format: true
    end

end