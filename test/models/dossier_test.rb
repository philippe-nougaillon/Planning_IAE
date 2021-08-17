require "test_helper"

class DossierTest < ActiveSupport::TestCase
  
  test "un dossier a quelques champs obligatoires" do
    dossier = Dossier.new
    assert dossier.invalid?
    assert dossier.errors[:intervenant].any?
  end

  test "le dossier doit être créé s'il a des attributs valides" do
    dossier1 = dossiers(:dossier1)
    assert dossier1.valid?
  end

end
