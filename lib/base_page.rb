class BasePage

  def navigation_menu
    list = []

    document.css("table tr td .navigation").first.parent.parent.parent.css("tr td a").each do |item|
      text = item.children.at(0).content
      href = item['href']

      list <<  MediaItem.new(text, href) unless href =~ /(login|signup|thematic|action=browse_persons)/
    end

    list
  end

  def category_breadcrumbs
    list = []

    document.css("table tr td table tr td table tr td strong").each_with_index do |item, index|
      if index == 0
        item.children.each do |child|
          text = child.text
          link = child.attributes['href']
          href = link.nil? ? nil : link.value

          list << MediaItem.new(text, href)
        end
      end
    end

    list
  end

  def categories
    list = []

    unless url =~ /(action=browse_container|action=search|action=channels|media)/
      document.css("table").each_with_index do |table1, index1|
        if index1 == 5
          table1.css("tr/td/table/tr/td/table").each_with_index do |table2, index2|
            if index2 == 2
              table2.css("tr td a").each_with_index do |item3, index3|
                link = item3.attributes['href'].value

                if index3 > 0
                  text = item3.text
                  href = link

                  additional_info = additional_info(item3, 2)

                  list << MediaItem.new(text, href, additional_info) unless additional_info.nil?
                end
              end
            end
          end
        end
      end
    end

    list = [] if list.size == 1
    
    list
  end

  def title_items
    list = []

    root = nil
    document.css("a").each do |item|
      link = item.attributes['href']

      unless link.value =~ /login.fcgi/
        if link.value =~ /order_by/
          root = link.parent.parent.parent.parent.parent.parent
          break
        end
      end
    end

    if root
      root.css("td").each do |item|
        node1 = item.search("table/tr/td")
        node2 = item.search("table/tr/td[2]")
        if node1.search("a").size > 0
          link = node1.css("a").first

          text = link.text
          href = link.attributes['href'].value

          if node2.search("#SPAN_all_letters").size > 0
            additional_info = node2.search("#SPAN_all_letters").at(0).inner_html
            index = additional_info.index('<a href="#"')
            additional_info = additional_info[0..index-2].strip + "]"
          else
            additional_info = nil
          end

          list << MediaItem.new(text, href, additional_info)
        end
      end
    end

    list
  end

end
