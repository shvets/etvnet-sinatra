require 'cgi'

require 'etvnet_seek/core/catalog_page'

class SearchPage < CatalogPage
  SEARCH_URL = BASE_URL + "/search/"

  def initialize(params)
   # CGI.escape(
    super("#{SEARCH_URL}?#{params}")
  end

end
