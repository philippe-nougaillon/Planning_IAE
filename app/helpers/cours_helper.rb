module CoursHelper
  def disabled_paginate?(params)
    params[:formation].blank? && params[:intervenant].blank?
  end

  # Choix de catégories proposés dans le select, filtrés selon le rôle :
  # "Suivi des copies" n'est proposé qu'à l'Accueil, aux Gestionnaires et aux Administrateurs.
  def option_category_choices(user)
    categories = Option.catégories.keys
    categories -= ["suivi_copies"] unless user.peut_gerer_suivi_copies?
    categories
  end

  # Options affichables dans le formulaire d'un cours selon le rôle :
  # les options "Suivi des copies" sont masquées aux rôles non autorisés.
  def options_visibles(cour, user)
    return cour.options.to_a if user.peut_gerer_suivi_copies?
    cour.options.reject(&:suivi_copies?)
  end
end
