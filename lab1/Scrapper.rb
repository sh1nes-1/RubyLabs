class Scrapper
  BASE_URL = 'https://ek.ua/ua'
  CATALOG_URL = "#{BASE_URL}/ek-list.php?katalog_=%d&sb_=%s&page_=%d"

  def fetch(catalog_id, search_keyword, start_page, max_pages)
    all_items = Array.new

    (start_page..max_pages).each do |page|
      page_items = fetch_items(catalog_id, search_keyword, page)
      if page_items.length == 0
        break
      end

      all_items += page_items
    end

    all_items
  end

  private

  def fetch_items(catalog_id, search_keyword, page)
    search_keyword = URI.encode_www_form_component(search_keyword)
    url = CATALOG_URL % [catalog_id, search_keyword, page - 1]

    html = URI.open(url)
    doc = Nokogiri::HTML(html)

    parse_items(doc)
  end

  def parse_items(doc)
    items = Array.new

    doc.css('.model-short-block').each do |item_el|
      item = parse_item(item_el)
      items.push(item)
    rescue error
      # Ignored
    end

    items
  end

  def parse_item(item_el)
    item_link_el = item_el.at('.model-short-title')

    price_el = item_el.at_css('.model-hot-prices-td .model-price-range a') # price range (63 012 до 76 848 грн.)
    unless price_el
      price_el = item_el.at_css('.model-hot-prices-td .pr31') # price (26 999 грн.)
    end

    item          = Hash.new
    item['title'] = item_link_el['title'].strip

    specs_list = item_el.css('.m-s-f2').children.map { |item_spec| item_spec.attr('title') }
    specs_dict = specs_list.group_by { |specs| specs.split(':', 2)[0] } # { 'Key' => ['Key: Value'] }
    item['specs'] = specs_dict.transform_values { |values| values[0].split(':', 2)[1].strip } # { 'Key' => 'Value' }

    item['price'] = price_el.text
    item['image'] = item_el.css('.model-short-photo img').attr('src')
    item['link']  = BASE_URL + item_link_el.attr('href')

    item
  end
end