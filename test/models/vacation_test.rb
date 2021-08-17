require "test_helper"

class VacationTest < ActiveSupport::TestCase
  
  test "une vacation a quelques champs obligatoires" do
    vacance = Vacation.new
    assert vacance.invalid?
    assert vacance.errors[:formation].any?
    assert vacance.errors[:intervenant].any?
  end

  test "la vacation doit être créée si elle a des attributs valides" do
    vacance_MGEN_2021 = vacations(:vacance_MGEN_2021)
    assert vacance_MGEN_2021.valid?
  end

end
