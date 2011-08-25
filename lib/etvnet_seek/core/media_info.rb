class MediaInfo
  attr_reader :link

  def initialize link
    @link = link
  end

  def resolved?
    not @link.nil? and not @link.strip.size == 0
  end

  def session_expired?
    @session_expired
  end

  def session_expired= expired
    @session_expired = expired
  end
end

