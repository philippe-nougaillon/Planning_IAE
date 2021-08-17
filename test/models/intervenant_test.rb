require "test_helper"

class IntervenantTest < ActiveSupport::TestCase

  test "un intervenant a quelques champs obligatoires" do
    intervenant = Intervenant.new
    assert intervenant.invalid?
    assert intervenant.errors[:nom].any?
    assert intervenant.errors[:email].any?
    assert intervenant.errors[:prenom].any?
    assert intervenant.errors[:status].any?
  end

  test "l'intervenant doit être créé s'il a des attributs valides" do
    intervenant_florent = intervenants(:florent)
    assert intervenant_florent.valid?
  end

end
