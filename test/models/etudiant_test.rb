require "test_helper"

class EtudiantTest < ActiveSupport::TestCase
  
  test "un étudiant a quelques champs obligatoires" do
    etudiant = Etudiant.new
    assert etudiant.invalid?
    assert etudiant.errors[:nom].any?
    assert etudiant.errors[:prénom].any?
    assert etudiant.errors[:civilité].any?
    assert etudiant.errors[:email].any?
    assert etudiant.errors[:formation].any?
  end

  test "l'étudiant doit être créé s'il a des attributs valides" do
    etudiant_nicolas = etudiants(:nicolas)
    assert etudiant_nicolas.valid?
  end

end
