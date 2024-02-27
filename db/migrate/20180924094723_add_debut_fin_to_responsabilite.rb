class AddDebutFinToResponsabilite < ActiveRecord::Migration[7.1]
  def change
    add_column :responsabilites, :debut, :date
    add_column :responsabilites, :fin, :date
  end
end
