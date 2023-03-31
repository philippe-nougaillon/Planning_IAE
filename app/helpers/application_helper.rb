module ApplicationHelper
    
    def navbar_nav_item(name, icon, path, label = nil)
        render(inline: %{
            <li class="nav-item">
                <%= link_to '#{ url_for(path) }', 
                            class: 'nav-link text-#{ (@ctrl == name) ? 'primary' : 'dark' }' do %>
                    <%= fa_icon '#{ icon }' %>
                    #{ label ? label : name.humanize }
                <% end %>
            </li>
        })
    end

    def page_entries_info(collection)
        model_name = collection.respond_to?(:human_name) ? collection.model_name.human : (collection.first&.model_name&.human || '')
    
        sanitize "Affichage de  #{model_name} " +
          tag.b("#{collection.offset + 1} - #{[collection.per_page * collection.current_page, collection.total_entries].min}") +
          ' sur ' + tag.b(collection.total_entries) +
          ' au total'
    end

    def time_in_paris

        DateTime.now.in_time_zone('Europe/Paris')

    end

    def time_in_paris_selon_la_saison
        # Heure d'hiver
        #DateTime.now.in_time_zone('Europe/Paris') + 1.hours

        # Heure d'été
        DateTime.now.in_time_zone('Europe/Paris') + 2.hours
    end

    def clean_page(page)
        begin
            WillPaginate::PageNumber(page)
        rescue WillPaginate::InvalidPage
            1
        end
    end

end
