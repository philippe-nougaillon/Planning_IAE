require "test_helper"

class DocumentTest < ActiveSupport::TestCase

  test "un document a quelques champs obligatoires" do
    document = Document.new
    assert document.invalid?
    assert document.errors[:dossier].any?
  end

  test "le document doit être créé s'il a des attributs valides" do
    document1 = documents(:document1)
    assert document1.valid?
  end
end
