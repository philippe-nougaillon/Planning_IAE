class UsersToXls < ApplicationService
  require 'spreadsheet'
  attr_reader :users

  def initialize(users)
    @users = users
  end

  def call
    Spreadsheet.client_encoding = 'UTF-8'
  
    book = Spreadsheet::Workbook.new
    sheet = book.create_worksheet name: 'Users'
    bold = Spreadsheet::Format.new :weight => :bold, :size => 11

    headers = ["id", "nom", "prénom", "email", 
                "role",
                "mobile",
                "formation_id",
                "désactivé?",
                "created_at", "updated_at"]

    sheet.row(0).concat headers
    sheet.row(0).default_format = bold

    index = 1
    @users.each do | user |
        fields_to_export = [
          user.id,
          user.nom,
          user.prénom,
          user.email,
          user.role,
          user.mobile,
          user.formation_id,
          user.discarded?,
          user.created_at, 
          user.updated_at
        ]
        sheet.row(index).replace fields_to_export
        index += 1
    end

    return book

  end

end