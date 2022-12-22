class MailLog < ApplicationRecord
  include Sortable::Model

  audited
end
