require "test_helper"

class EnvoiLogTest < ActiveSupport::TestCase
  
  test "un envoi_log a quelques champs obligatoires" do
    envoi_log = EnvoiLog.new
    assert envoi_log.invalid?
    assert envoi_log.errors[:date_prochain].any?
  end

  test "l'envoi_log doit être créé s'il a des attributs valides" do
    envoi_log1 = envoi_logs(:one)
    assert envoi_log1.valid?
  end
  
end
