module ApplicationHelper
    
    def sort_link(column, title = nil)
        title ||= (@model_class ? @model_class.human_attribute_name(column) : column.titleize)
        direction = column == sort_column && sort_direction == "asc" ? "desc" : "asc"
        icon = sort_direction == "asc" ? "glyphicon glyphicon-sort-by-attributes" : "glyphicon glyphicon-sort-by-attributes-alt"
        icon = column == sort_column ? icon : ""
        
        link_title = sort_direction == "asc" ? "Sort table in ascending order" : "Sort table in descending order"
        link_to "<span title=\"#{h link_title}\">#{h title} <span class=\"#{icon}\"></span></span>".html_safe, 
                url_for(request.parameters.merge(column: column, direction: direction))
    end

    def navbar_nav_item(name, icon, path)
        render(inline: %{
            <li class="nav-item">
                <%= link_to '#{ url_for(path) }', 
                            class: 'nav-link text-#{ (@ctrl == name) ? 'primary' : 'dark' }' do %>
                    <%= fa_icon '#{ icon }' %>
                    #{ name.humanize } 
                <% end %>
            </li>
        })
    end

end
