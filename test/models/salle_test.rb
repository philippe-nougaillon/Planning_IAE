require "test_helper"

class SalleTest < ActiveSupport::TestCase

  test "une salle a quelques champs obligatoires" do
    salle = Salle.new
    assert salle.invalid?
    assert salle.errors[:nom].any?
    assert salle.errors[:places].any?
  end

  test "la salle doit être créée si elle a des attributs valides" do
    salle_A1 = salles(:A1)
    assert salle_A1.valid?
  end

  test "le nom d'une salle doit être unique" do
    salle_nom_deja_pris = Salle.create(nom: 'A1', places: 23)
    assert salle_nom_deja_pris.invalid?
    assert_equal ["n'est pas disponible"], salle_nom_deja_pris.errors[:nom]
    salle_nom_deja_pris.nom = 'NomDeSalleDisponible'
    assert salle_nom_deja_pris.valid?
  end


end
