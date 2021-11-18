require_relative 'VideoCard'

class VideoCardParser
  def self.parse_all(items)
    items.map { |item| self.parse(item) }.compact
  end

  def self.parse(item)
    title         = item['title'].gsub('Відеокарта ', '')
    img_url       = item['image']
    reference_url = item['link']

    min_price = item['min_price'].gsub(' ', '').strip
    max_price = item['max_price'].gsub(' ', '').strip

    memory_data = item['specs']["Пам'ять"].split(',') # 12ГБ, GDDR6, 15000МГц
    memory_capacity  = memory_data[0].gsub(' ', ' ').strip
    memory_type      = memory_data[1].gsub(' ', '').strip
    memory_frequency = memory_data[2].gsub(' ', ' ').strip

    gpu_data = item['specs']['GPU'].split(',') # NVIDIA GeForce RTX 3060, 1777МГц
    gpu_name      = gpu_data[0].gsub(' ', '').strip
    gpu_frequency = gpu_data[1].gsub(' ', ' ').strip

    VideoCard.new(title, memory_capacity, memory_frequency, memory_type, gpu_name, gpu_frequency, min_price, max_price, img_url, reference_url)
  rescue
    nil
  end
end