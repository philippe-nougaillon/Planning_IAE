require "test_helper"

class FermetureTest < ActiveSupport::TestCase
  
  test "une fermeture a quelques champs obligatoires" do
    fermeture = Fermeture.new
    assert fermeture.invalid?
    assert fermeture.errors[:date].any?
    assert fermeture.errors[:nom].any?
  end

  test "la fermeture doit être créée si elle a des attributs valides" do
    fermeture_fete_nationale_2021 = fermetures(:fete_nationale_2021)
    assert fermeture_fete_nationale_2021.valid?
  end

end
