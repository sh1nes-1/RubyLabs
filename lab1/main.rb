require 'open-uri'
require 'nokogiri'
require 'csv'

SEARCH_KEYWORD = CGI.escape('Відеокарта')
BASE_URL = 'https://ek.ua/ua'
OUTPUT_FILENAME = 'lab1/data.csv'
CSV_HEADER = ['Title', 'Specs', 'Price', 'Image', 'Link']


def parse_items(doc)
  items = Array.new

  doc.css('.model-short-block').each do |item_el| 
    item = parse_item(item_el)
    items.push(item)
  end

  return items
end

def parse_item(item_el)
  item_link_el = item_el.at('.model-short-title')
  
  price_el = item_el.at_css('.model-hot-prices-td .model-price-range a') # price range (63 012 до 76 848 грн.)
  if not price_el        
    price_el = item_el.at_css('.model-hot-prices-td .pr31') # price (26 999 грн.)
  end

  item          = Hash.new
  item['title'] = item_link_el['title'].strip  
  item['specs'] = item_el.css('.m-s-f2').children.map { |item_spec| item_spec.attr('title') }
  item['price'] = price_el.text
  item['image'] = item_el.css('.model-short-photo img').attr('src')
  item['link']  = BASE_URL + item_link_el.attr('href')

  return item
end

def export_to_csv(filename, header, items)
  CSV.open(filename, "wb") do |csv|
    csv << header
    items.each do |hash|
      csv << hash.values
    end
  end
end

html = URI.open("#{BASE_URL}/ek-list.php?search_=#{SEARCH_KEYWORD}")
doc = Nokogiri::HTML(html)

items = parse_items(doc)
export_to_csv(OUTPUT_FILENAME, CSV_HEADER, items)