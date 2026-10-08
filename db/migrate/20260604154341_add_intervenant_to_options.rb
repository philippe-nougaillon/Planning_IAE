class AddIntervenantToOptions < ActiveRecord::Migration[7.2]
  def change
    add_reference :options, :intervenant, null: true, foreign_key: true
  end
end
