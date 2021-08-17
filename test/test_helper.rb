ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  setup do
    user_thomas = users(:thomas)
    formation_MGEN_2021 = formations(:MGEN_2021)
    formation_Master_CGAO = formations(:Master_CGAO)
    intervenant_florent = intervenants(:florent)
    intervenant_christophe = intervenants(:christophe)
    cour_management_commercial = cours(:cours_management_commercial)
    salle_A1 = salles(:A1)
    

  end

  # Add more helper methods to be used by all tests here...
end
