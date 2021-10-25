require_relative 'VideoCard'

class VideoCardParser
  def self.parse_all(items)
    items.map { |item| self.parse(item) }.compact
  end

  def self.parse(item)
    title         = item['title'].gsub('Відеокарта ', '')
    img_url       = item['image']
    reference_url = item['link']

    prices = item['price'].split('до') # 62 397 до 74 843 грн.
    if prices.length == 2
      min_price = prices[0].gsub(' ', '').strip
      max_price = prices[1].gsub(' ', '').gsub('грн.', '').strip
    else
      min_price = prices[0].gsub(' ', '').gsub('грн.', '').strip
      max_price = min_price
    end

    memory_data = item['specs']["Пам'ять"].split(',') # 12ГБ, GDDR6, 15000МГц
    memory_capacity  = memory_data[0].gsub(' ', '').strip
    memory_type      = memory_data[1].gsub(' ', '').strip
    memory_frequency = memory_data[2].gsub(' ', '').strip

    gpu_data = item['specs']['GPU'].split(',') # NVIDIA GeForce RTX 3060, 1777МГц
    gpu_name      = gpu_data[0].gsub(' ', '').strip
    gpu_frequency = gpu_data[1].gsub(' ', '').strip

    VideoCard.new(title, memory_capacity, memory_frequency, memory_type, gpu_name, gpu_frequency, min_price, max_price, img_url, reference_url)
  rescue
    nil
  end
end