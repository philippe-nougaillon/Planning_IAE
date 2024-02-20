class MailLog < ApplicationRecord
  include Sortable::Model

  include PgSearch::Model
	multisearchable against: [:to, :subject]

  audited
end
