# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = "https://business-school-planning-demo-248ac1f2d92e.herokuapp.com/"

# Ne pas indéxer la liste des cours
# SitemapGenerator::Sitemap.include_root = false

SitemapGenerator::Sitemap.compress = false

SitemapGenerator::Sitemap.create do
  # Put links creation logic here.
  #
  # The root path '/' and sitemap index file are added automatically for you.
  # Links are added to the Sitemap in the order they are specified.
  #
  # Usage: add(path, options={})
  #        (default options are used if you don't specify)
  #
  # Defaults: :priority => 0.5, :changefreq => 'weekly',
  #           :lastmod => Time.now, :host => default_host
  #
  # Examples:
  #
  # Add '/articles'
  #
  #   add articles_path, :priority => 0.7, :changefreq => 'daily'
  #
  # Add all articles:
  #
  #   Article.find_each do |article|
  #     add article_path(article), :lastmod => article.updated_at
  #   end

  # add guide_index_path, :priority => 0.9,  :changefreq => 'monthly'
  add mentions_legales_path, :priority => 0.5,  :changefreq => 'monthly'

end
