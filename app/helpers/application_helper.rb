module ApplicationHelper
    
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
