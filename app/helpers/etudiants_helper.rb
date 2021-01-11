module EtudiantsHelper
    def sort_link(column, title = nil)
        title ||= (@model_class ? @model_class.human_attribute_name(column) : column.titleize)
        direction = column == sort_column && sort_direction == "asc" ? "desc" : "asc"
        icon = sort_direction == "asc" ? "sort-down" : "sort-up"
        icon = column == sort_column ? icon : nil
        link_title = sort_direction == "asc" ? "Tri croissant" : "Tri décroissant"

        link_to "<span title=\"#{h link_title}\">#{h title} <span>#{ fa_icon(icon) if icon }</span></span>".html_safe, 
                url_for(request.parameters.merge(column: column, direction_etudiants: direction))
    end

end
