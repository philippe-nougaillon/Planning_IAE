class ImportLogPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  def index?
    user.role_number >= 4
  end

  def show?
    index?
  end

  def download_imported_file?
    index?
  end

end