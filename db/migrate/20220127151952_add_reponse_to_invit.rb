class AddReponseToInvit < ActiveRecord::Migration[6.1]
  def change
    add_column :invits, :reponse, :string
  end
end
