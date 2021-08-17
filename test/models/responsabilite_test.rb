require "test_helper"

class ResponsabiliteTest < ActiveSupport::TestCase
  
  test "une responsabilité a quelques champs obligatoires" do
    responsabilite = Responsabilite.new
    assert responsabilite.invalid?
    assert responsabilite.errors[:intervenant].any?
    assert responsabilite.errors[:formation].any?
  end

  test "la responsabilité doit être créée si elle a des attributs valides" do
    responsable_MGEN_2021 = responsabilites(:responsable_MGEN_2021)
    assert responsable_MGEN_2021.valid?
  end

end
