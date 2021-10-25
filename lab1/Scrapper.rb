require 'mechanize'

class Scrapper
  BASE_URL = 'https://ek.ua/ua'
  CATALOG_URL = "#{BASE_URL}/ek-list.php?katalog_=%d&sb_=%s&page_=%d"

  def fetch(catalog_id, search_keyword, start_page, max_pages)
    all_items = Array.new

    search_keyword = URI.encode_www_form_component(search_keyword)
    url = CATALOG_URL % [catalog_id, search_keyword, start_page - 1]

    agent = Mechanize.new
    doc = agent.get(url)

    (start_page..max_pages).each do |page_number|
      puts('Parsing items of page %d' % [page_number])

      page_items = parse_items(doc)
      if page_items.length == 0
        break
      end

      all_items += page_items
      doc = agent.click(doc.at('#pager_next'))
    end

    all_items
  end

  private

  def parse_items(doc)
    items = Array.new

    doc.css('.model-short-block').each do |item_el|
      item = parse_item(item_el)
      items.push(item)
    rescue Exception => error
      puts('Exception: %s' % [error.to_s])
    end

    items
  end

  def parse_item(item_el)
    item_link_el = item_el.at('.model-short-title')

    # there are 3 types of price
    price_elements = item_el.css('.model-hot-prices-td .model-price-range a span') # price range (63 012 до 76 848 грн.)
    if price_elements.length > 1
      min_price_el = price_elements[0]
      if price_elements[1].text != ''
        max_price_el = price_elements[1]
      else
        max_price_el = min_price_el
      end
    else
      min_price_el = item_el.at('.model-hot-prices-td .pr31 span') # price (26 999 грн.)
      max_price_el = min_price_el
    end

    item          = Hash.new
    item['title'] = item_link_el['title'].strip

    specs_list = item_el.css('.m-s-f2').children.map { |item_spec| item_spec.attr('title') }
    specs_dict = specs_list.group_by { |specs| specs.split(':', 2)[0] } # { 'Key' => ['Key: Value'] }
    item['specs'] = specs_dict.transform_values { |values| values[0].split(':', 2)[1].strip } # { 'Key' => 'Value' }

    item['min_price'] = min_price_el.text
    item['max_price'] = max_price_el.text
    item['image'] = item_el.at('.model-short-photo img').attr('src')
    item['link']  = BASE_URL + item_link_el.attr('href')

    item
  end
end