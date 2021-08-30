require "application_system_test_case"

class FormationsTest < ApplicationSystemTestCase

  setup do
    login_user
  end

  test "visiter l'index" do
    visit formations_url
  
    assert_selector "h3", text: "Liste des formations"
  end

  test "ajouter une formation" do
    visit formations_url

    click_on "Formation"

    fill_in 'formation_nom', with: formations(:MGEN_2021).nom
    fill_in 'formation_abrg', with: formations(:MGEN_2021).abrg
    fill_in 'formation_nbr_heures', with: formations(:MGEN_2021).nbr_heures
    select User.find(formations(:MGEN_2021).user_id).nom_et_prénom, from: 'formation_user_id'

    click_on "Créer un(e) Formation"

    sleep(10)
    
  end
end
