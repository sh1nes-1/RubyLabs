require 'open-uri'
require 'nokogiri'
require 'csv'
require_relative 'parser'

CATALOG_ID = 189
SEARCH_KEYWORD = 'Відеокарта'
MAX_PAGES = 5
OUTPUT_FILENAME = 'data.csv'
CSV_HEADER = %w[Title Specs Price Image Link]

def export_to_csv(filename, header, items)
  CSV.open(filename, "wb") do |csv|
    csv << header
    items.each do |hash|
      csv << hash.values
    end
  end
  self
end

parser = Parser.new
items = parser.parse(CATALOG_ID, SEARCH_KEYWORD, 1, MAX_PAGES)

export_to_csv(OUTPUT_FILENAME, CSV_HEADER, items)