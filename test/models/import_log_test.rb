require "test_helper"

class ImportLogTest < ActiveSupport::TestCase
  
  test "un import_log a quelques champs obligatoires" do
    import_log = ImportLog.new
    assert import_log.invalid?
    assert import_log.errors[:user].any?
    assert import_log.errors[:model_type].any?
    assert import_log.errors[:etat].any?
  end

  test "l'import_log doit être créé s'il a des attributs valides" do
    import_log1 = import_logs(:import_log1)
    assert import_log1.valid?
  end

end
