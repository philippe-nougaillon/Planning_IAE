class AddCommentairesToVacation < ActiveRecord::Migration
  def change
    add_column :vacations, :commentaires, :string
  end
end
