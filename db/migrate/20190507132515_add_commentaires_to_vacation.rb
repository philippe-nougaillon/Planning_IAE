class AddCommentairesToVacation < ActiveRecord::Migration[7.1]
  def change
    add_column :vacations, :commentaires, :string
  end
end
