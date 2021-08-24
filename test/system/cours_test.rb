require "application_system_test_case"

class CoursTest < ApplicationSystemTestCase

  setup do
    login_user
    @cour_cloture_module =  Cour.create(
      debut: "2021-11-24 10:00:00",
      duree: 6,
      formation_id: 2, 
      intervenant_id: 3,
      intervenant_binome_id: 1
    )
    
    visit cours_url
  end

  test "visiter l'index" do
    assert_selector "h3", text: "Planning des cours"
  end

  test "ajouter un cours" do
    click_on "Cours"

    fill_in 'cour_debut', with: "16-11-2021 12:00:00"
    select cours(:cours_management_commercial).duree, from: 'cour_duree'
    select Formation.find(cours(:cours_management_commercial).formation_id).nom, from: 'cour_formation_id'
    select Intervenant.find(cours(:cours_management_commercial).intervenant_id).nom, from: 'intervenant_id'

    click_on "Enregistrer"

    assert_text ' ajouté avec succès.'
  end

  test "Action: changer de salle" do
    check "_cours_id_#{@cour_cloture_module.id}"
    select 'Changer de salle', from: 'action_name'

    click_on "A2"

    assert_text "Action 'Changer de salle' appliquée à 1 cours."
  end

  test "Action: changer d'état" do
    check "_cours_id_#{@cour_cloture_module.id}"
    select "Changer d'état", from: 'action_name'

    select 'annulé', from: 'etat'
    click_on "Appliquer"

    assert_text "Action 'Changer d'état' appliquée à 1 cours."
  end

  test "Action: changer de date avec une nouvelle date" do
    check "_cours_id_#{@cour_cloture_module.id}"
    select "Changer de date", from: 'action_name'

    fill_in 'new_date', with: "29-09-2021"
    click_on "Appliquer"

    assert_text "Action 'Changer de date' appliquée à 1 cours."
  end

  test "Action: changer de date en décalant d'un nombre de jours" do
    check "_cours_id_#{@cour_cloture_module.id}"
    select "Changer de date", from: 'action_name'

    fill_in 'add_n_days', with: 2
    click_on "Appliquer"

    assert_text "Action 'Changer de date' appliquée à 1 cours."
  end

  test "Action: intervertir deux cours (intervenants)" do
    @cour_marketing = Cour.create(
      debut: "2021-11-24 14:00:00",
      duree: 2,
      formation_id: 1, 
      intervenant_id: 2
    )

    visit cours_url

    check "_cours_id_#{@cour_cloture_module.id}"
    check "_cours_id_#{@cour_marketing.id}"
    select "Intervertir", from: 'action_name'

    check "intervertir_intervenants"
    click_on "Appliquer"

    assert_text "Action 'Intervertir' appliquée à 2 cours."
  end

  test "Action: export Excel" do
    File.delete( File.expand_path "~/Downloads/Export_Cours.xls" )

    check "_cours_id_#{@cour_cloture_module.id}"
    select "Exporter vers Excel", from: 'action_name'
    
    click_on "Appliquer"
    
    #This sleep to ensure that the download of the file will be completed before the assertion.
    sleep(4)
    assert File.exists?( File.expand_path "~/Downloads/Export_Cours.xls" )
  end

  test "Action: export iCalendar" do
    File.delete( File.expand_path "~/Downloads/Export_Planning_2021-08-24.ics" )

    check "_cours_id_#{@cour_cloture_module.id}"
    select "Exporter vers iCalendar", from: 'action_name'

    click_on "Appliquer"

    #This sleep makes it possible to be (almost) sure that the download of the file will be completed before the assertion.
    sleep(4)
    assert File.exists?( File.expand_path "~/Downloads/Export_Planning_2021-08-24.ics" )
  end

  test "Action: export PDF" do
    check "_cours_id_#{@cour_cloture_module.id}"
    select "Exporter en PDF", from: 'action_name'

    click_on "Appliquer"

    assert_text @cour_cloture_module.nom
  end

  test "Action: supprimer" do
    check "_cours_id_#{@cour_cloture_module.id}"
    select "Supprimer", from: 'action_name'

    check "delete"
    click_on "Appliquer"

    assert_text "Action 'Supprimer' appliquée à 1 cours."
  end
end
