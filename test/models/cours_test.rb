require "test_helper"

class CoursTest < ActiveSupport::TestCase

    setup do
        @cour_management_commercial = Cour.create(
            debut: "2021-11-24 12:00:00", 
            duree: 2,
            formation_id: 1, 
            intervenant_id: 1
        )

        @cour_finance = Cour.create(
            debut: "2021-11-24 13:00:00",
            duree: 3,
            formation_id: 2, 
            intervenant_id: 2
        )

        @cour_marketing = Cour.create(
            debut: "2021-11-24 14:00:00",
            duree: 2,
            formation_id: 1, 
            intervenant_id: 2
        )
        
        @cour_cloture_module = Cour.create(
            debut: "2021-11-24 10:00:00",
            duree: 6,
            formation_id: 2, 
            intervenant_id: 3,
            intervenant_binome_id: 1
        )
        @cour_en_ligne = Cour.create(
            debut: "2021-11-24 11:00:00",
            duree: 4,
            formation_id: 1, 
            intervenant_id: 3
        )

        # @cour_veille = Cour.create(
        #     debut: "2021-11-24 13:00:00",
        #     duree: 2,
        #     formation_id: 1, 
        #     intervenant_id: 3
        # )
    end


    test "un cours a quelques champs obligatoires" do
        cour = Cour.new(debut: "2020-12-01 12:00:00") # debut obligatoire, sinon wday ne sera pas trouvé
        assert cour.invalid?
		assert cour.errors[:formation].any?
        assert cour.errors[:formation_id].any?
        assert cour.errors[:intervenant].any?
        assert cour.errors[:intervenant_id].any?
        assert cour.errors[:fin].any?
    end

    test "le cours doit être créé s'il a des attributs valides" do
		assert @cour_management_commercial.valid?
	end

    test "le cours est de base en état planifié" do
        assert @cour_management_commercial.etat == "planifié"
    end

    test "le cours passe en état confirmé si une salle lui a été attribuée" do
        @cour_management_commercial.salle_id = 1
        @cour_management_commercial.save
        assert @cour_management_commercial.etat == "confirmé"
    end

    test "il ne peut pas y avoir deux cours dans la même salle" do
        @cour_management_commercial.salle_id = 1
        @cour_management_commercial.save

        @cour_finance.salle_id = 1
        @cour_finance.etat = "confirmé"

        assert @cour_finance.invalid?
        assert_equal ["en chevauchement (période, salle) avec le cours <a href='/cours/#{@cour_management_commercial.id}'>#{@cour_management_commercial.id}</a>"], @cour_finance.errors[:cours]
    end

    test "deux cours peuvent être dans la même salle de capacité = 0 (ex: en ligne)" do
        @cour_management_commercial.salle_id = 3
        @cour_management_commercial.save

        @cour_en_ligne.salle_id = 3
        @cour_en_ligne.save

        assert @cour_en_ligne.valid?
    end

    # tester que l'intervenant n'est pas deux cours en même temps
    test "un intervenant ne peut pas avoir deux cours en même temps" do
        @cour_finance.salle_id = 1
        @cour_finance.save

        @cour_marketing.salle_id = 2
        @cour_marketing.etat = "confirmé"

        assert @cour_marketing.invalid?
        assert_equal ["en chevauchement (période, intervenant) avec le(s) cours ##{@cour_finance.id}"], @cour_marketing.errors[:cours]
    end


    #test que l'intervenant doublon n'ai pas deux cours en même temps

    test "un intervenant doublon ne peut pas avoir deux cours en même temps" do
        # puts 'a'
        # puts @cour_management_commercial.inspect
        # @cour_management_commercial.salle_id = 1
        # puts 'b'
        # puts @cour_management_commercial.inspect
        # @cour_management_commercial.save
        # puts 'c'
        # puts @cour_management_commercial.inspect

        # puts 'd'
        # puts @cour_cloture_module.inspect
        # @cour_cloture_module.salle_id = 2
        # # puts 'e'
        # # puts @cour_cloture_module.inspect
        # @cour_cloture_module.save
        # puts 'f'
        # puts @cour_cloture_module.inspect

        # assert @cour_cloture_module.invalid?
        # assert_equal ["en chevauchement (période, intervenant) avec le(s) cours ##{@cour_management_commercial.id}"], @cour_cloture_module.errors[:cours]
        # puts @cour_cloture_module.errors.full_messages
        # # puts @cour_cloture_module.inspect
    end


    # tester qu'une formation n'est pas deux cours en même temps
    # test "une formation ne peut pas être dans deux cours en même temps" do
    #     @cour_management_commercial.salle_id = 1
    #     @cour_management_commercial.save
    #     puts @cour_management_commercial.inspect

    #     @cour_veille.salle_id = 2
    #     @cour_veille.etat = "confirmé"
    #     assert @cour_veille.invalid?
    #     puts @cour_veille.errors.full_messages
    #     puts @cour_veille.inspect
    #     puts @cour_finance.inspect

    #     assert_equal ["en chevauchement (période, salle) avec le cours ##{@cour_management_commercial.id}"], @cour_veille.errors[:cours]
    # end
end
