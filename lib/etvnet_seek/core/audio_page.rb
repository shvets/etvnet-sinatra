require 'etvnet_seek/core/items_page'
require 'etvnet_seek/core/media_item'

class AudioPage < ItemsPage
  AUDIO_URL = BASE_URL + "/audio/"

  def initialize url = AUDIO_URL
    super(url)
  end

  def ignored_links
    /(help|register|press)/
  end
end
