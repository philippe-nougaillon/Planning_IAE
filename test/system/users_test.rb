require "application_system_test_case"

class UsersTest < ApplicationSystemTestCase

  setup do
    login_user
  end
  
  test "visiter l'index" do
    visit users_url
  
    assert_selector "h3", text: "Liste des utilisateurs"
  end

  test "ajouter un utilisateur" do
    visit users_url

    click_on "Utilisateur"

    fill_in 'user_nom', with: 'Petit'
    fill_in 'user_prénom', with: 'Manon'
    fill_in 'user_email', with: 'manon.petit@gmail.com'
    fill_in 'user_password', with: '12345678'
    fill_in 'user_password_confirmation', with: '12345678'
    
    click_on "Créer un(e) Utilisateur"
    
    assert_text "Utilisateur créé avec succès."
  end

  test "Rechercher un utilisateur par son prénom" do
    visit users_url

    fill_in "search", with: 'Thomas'
    find('#search').native.send_keys(:return)

    assert_text "Affichage de Utilisateur 1 - 1 sur 1 au total"
  end

  test "Rechercher un utilisateur par son email" do
    visit users_url

    fill_in "search", with: 'thomas.robert@gmail.com'
    find('#search').native.send_keys(:return)

    assert_text "Affichage de Utilisateur 1 - 1 sur 1 au total"
  end

  test "Rechercher un utilisateur par son nom" do
    visit users_url

    fill_in "search", with: 'robert'
    find('#search').native.send_keys(:return)
    
    assert_text "Affichage de Utilisateur 1 - 1 sur 1 au total"
  end

end
