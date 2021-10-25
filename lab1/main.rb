require 'open-uri'
require 'nokogiri'
require 'csv'
require_relative 'Scrapper'
require_relative 'VideoCardParser'

def export_to_csv(filename, items)
  CSV.open(filename, "wb") do |csv|
    csv << items.first.instance_variables.map {|var_name| var_name[1..-1]}
    items.each do |item|
      csv << item.values
    end
  end
end

scrapper = Scrapper.new
items = scrapper.fetch(189, 'Відеокарта', 1, 1)
video_cards = VideoCardParser.parse_all(items)
export_to_csv('data.csv', video_cards)