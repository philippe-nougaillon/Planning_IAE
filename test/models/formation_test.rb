require "test_helper"

class FormationTest < ActiveSupport::TestCase

  test "une formation a quelques champs obligatoires" do
    formation = Formation.new
    assert formation.invalid?
    assert formation.errors[:user].any?
    assert formation.errors[:nom].any?
    assert formation.errors[:nbr_heures].any?
    assert formation.errors[:abrg].any?
  end

  test "la formation doit être créée si elle a des attributs valides" do
    formation_MGEN_2021 = formations(:MGEN_2021)
    assert formation_MGEN_2021.valid?
  end

end
