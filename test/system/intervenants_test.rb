require "application_system_test_case"

class IntervenantsTest < ApplicationSystemTestCase

  setup do
    login_user
  end
  
  test "visiter l'index" do
    visit intervenants_url
  
    assert_selector "h3", text: "Liste des intervenants"
  end

  test "ajouter un intervenant" do
    visit intervenants_url

    click_on "Intervenant"

    fill_in 'intervenant_nom', with: 'Simmons'
    fill_in 'intervenant_prenom', with: 'Michael'
    fill_in 'intervenant_email', with: 'michael.simmons@gmail.com'
    select intervenants(:florent).status ,from: 'intervenant_status'
    click_on "Créer un(e) Intervenant"

    assert_text "Intervenant ajouté."
  end
end
