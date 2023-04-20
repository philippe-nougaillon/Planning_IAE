# ENCODING: UTF-8

class CustomAudit < Audited::Audit
    def pretty_changes
        pretty_changes = []

        self.audited_changes.each do |c| 
            if self.action == 'create'
                unless c.last.blank?
                    pretty_changes << "'#{c.first}' a été initialisé à '#{c.last}'"
                end
            elsif self.action == 'update'
                if c.last.first && c.last.last
                    pretty_changes << "'#{c.first}' modifié de '#{c.last.first}' à '#{c.last.last}'"
                end
            else
                pretty_changes << "'#{c.first}' était '#{c.last}'"
            end
        end
        pretty_changes.join('<br>')
    end

    def self.generate_xls(audits)
        require 'spreadsheet'    
        
        Spreadsheet.client_encoding = 'UTF-8'
    
        book = Spreadsheet::Workbook.new
        sheet = book.create_worksheet name: 'Audit des modifications'
        bold = Spreadsheet::Format.new :weight => :bold, :size => 10
        
        sheet.row(0).concat ['id', 'auditable_id','auditable_type', 'associated_id', 'associated_type', 'user_id', 'user_type', 'username', 'action', 'audited_changes','version','remote_adress','created_at']
        sheet.row(0).default_format = bold
        
        index = 1
        audits.each do |audit|
            fields_to_export = [
                audit.id,
                audit.auditable_id,
                audit.auditable_type,
                audit.associated_id,
                audit.associated_type,
                audit.user_id,
                audit.user_type,
                audit.user.try(:email),
                audit.action,
                audit.audited_changes.to_s,
                audit.version,
                audit.remote_address,
                audit.created_at 
            ]
            sheet.row(index).replace fields_to_export
            index += 1
        end
    
        return book
      end
    
end