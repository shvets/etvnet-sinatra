require 'etvnet_seek/core/items_page'
require 'etvnet_seek/core/media_item'

class HomePage < ItemsPage

  def items
    navigation_menu
  end

  def ignored_links
    /(person|help|register|press|\/)/
  end
end
