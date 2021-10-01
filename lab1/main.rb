require 'open-uri'
require 'nokogiri'
require 'csv'

BASE_URL = 'https://ek.ua/ua'
CATALOG_ID=189
SEARCH_KEYWORD = URI.encode_www_form_component('Відеокарта')
CATALOG_URL = "#{BASE_URL}/ek-list.php?katalog_=#{CATALOG_ID}&sb_=#{SEARCH_KEYWORD}&page_="
MAX_PAGES = 5
OUTPUT_FILENAME = 'data.csv'
CSV_HEADER = %w[Title Specs Price Image Link]


def fetch_items(page)
  page_index = page - 1
  url = CATALOG_URL + page_index.to_s

  html = URI.open(url)
  doc = Nokogiri::HTML(html)

  parse_items(doc)
end

def parse_items(doc)
  items = Array.new

  doc.css('.model-short-block').each do |item_el| 
    item = parse_item(item_el)
    items.push(item)
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
  item['specs'] = item_el.css('.m-s-f2').children.map { |item_spec| item_spec.attr('title') }
  item['price'] = price_el.text
  item['image'] = item_el.css('.model-short-photo img').attr('src')
  item['link']  = BASE_URL + item_link_el.attr('href')

  item
end

def export_to_csv(filename, header, items)
  CSV.open(filename, "wb") do |csv|
    csv << header
    items.each do |hash|
      csv << hash.values
    end
  end
end


all_items = Array.new

(1..MAX_PAGES).each do |page|
  page_items = fetch_items(page)
  if page_items.length == 0
    break
  end

  all_items += page_items
end

export_to_csv(OUTPUT_FILENAME, CSV_HEADER, all_items)