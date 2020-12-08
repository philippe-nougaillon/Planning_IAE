# require 'test_helper'

class CoursTest < ActiveSupport::TestCase

    test "the truth" do
        assert true
    end

    test "Ajouter un cours en ligne" do
        # USER
        user = User.create(email: "philippe.nougaillon@gmail.com", 
                            nom: "philnoug", 
                            prénom: "philippe",
                            password: "12345678!", 
                            password_confirmation: "12345678!")

        assert user.valid?, "User valide ?"

        # FORMATIONS
        formation = Formation.create(nom: "Formation TEST1", 
                                     abrg: "FTEST1", 
                                     nbr_heures: 100, 
                                     user: user)
        
        assert formation.valid?, "Formation valide ?"

        formation2 = Formation.create(nom: "Formation TEST2", 
                                    abrg: "FTEST2", 
                                    nbr_heures: 100, 
                                    user: user)

        assert formation2.valid?, "Formation2 valide ?"

        # INTERVENANTS
        intervenant = Intervenant.create(nom: "Intervenant1", 
                                        prenom: "prénom intervenant1", 
                                        email: "pp@pp.com", 
                                        status: "CEV",
                                        doublon: false)

        assert intervenant.valid?, "Intervenant valide ?"

        intervenant2 = Intervenant.create(nom: "Intervenant2", 
                                        prenom: "prénom intervenant2", 
                                        email: "pop@popp.com", 
                                        status: "CEV",
                                        doublon: false)

        assert intervenant2.valid?, "Intervenant2 valide ?"

        # COURS
        cours = Cour.create(debut: "2020-12-01 12:00:00", 
                        duree: 2,
                        formation: formation, 
                        intervenant: intervenant)

        assert cours.valid?, "Cours valide ?"
        assert cours.etat == "planifié", "Cours en état 'Planifié ?"

        # SALLE
        salle = Salle.create(nom: "SALLE A1", places: 30)
        assert salle.valid?, "Salle valide?"

        # CHGT COURS => ETAT ET SALLE
        cours.salle = salle
        cours.etat  = "confirmé"
        assert cours.valid?, "on assigne une salle à un cours"
        cours.save

        #puts cours.inspect

        # COURS EN CHEVAUCHEMENT SI MEME SALLE
        cours_en_doublon = Cour.create(debut: "2020-12-01 13:00:00", 
                                        duree: 2,
                                        intervenant: intervenant2,
                                        formation: formation2, 
                                        salle: salle,
                                        etat: "confirmé")

        assert_not cours_en_doublon.valid?, "COURS EN CHEVAUCHEMENT MEME SALLE"
        #puts cours_en_doublon.errors.inspect


        # COURS EN CHEVAUCHEMENT SI MEME DATE & INTERVENANT
        cours_en_doublon2 = Cour.create(debut: "2020-12-01 13:00:00", 
                                        duree: 2,
                                        intervenant: intervenant,
                                        formation: formation2, 
                                        salle: salle,
                                        etat: "confirmé")

        assert_not cours_en_doublon2.valid?, "COURS EN CHEVAUCHEMENT MEME INTERVENANT"
        #puts cours_en_doublon2.errors.inspect

        # SALLE PLACE = 0 => DOUBLON AUTORISE
        salle_en_ligne = Salle.create(nom: "En ligne", places: 0)
        assert salle_en_ligne.valid?
        #puts salle_en_ligne.inspect

        # COURS #2 EN LIGNE
        cours2 = Cour.create(debut: "2020-12-01 14:00:00", duree: 3,
                        intervenant: intervenant,
                        formation: formation, 
                        salle: salle_en_ligne,
                        etat: "confirmé")

        assert cours2.valid?, "Cours #2 en ligne en doublon autorisé(EN LIGNE) avec cours #1"
        puts cours2.inspect

        # COURS #3 EN LIGNE
        cours3 = Cour.create(debut: "2020-12-01 14:00:00", duree: 3,
                        intervenant: intervenant,
                        formation: formation, 
                        salle: salle_en_ligne,
                        etat: "confirmé")

        assert_not cours3.valid?, "Cours #3 en ligne en doublon non autorisé avec cours #2 en ligne (même heure, même intervenant)"
        puts cours3.inspect
        # puts cours3.errors.messages

        # COURS #4 EN LIGNE BINOME
        cours4 = Cour.create(debut: "2020-12-01 14:00:00", duree: 3,
                        intervenant: intervenant2,
                        intervenant_binome: intervenant,
                        formation: formation, 
                        salle: salle_en_ligne,
                        etat: "confirmé")

        assert cours4.valid?, "Cours #4 intervenant en binome en doublon"
        puts cours4.inspect

    end

end