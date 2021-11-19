class VideoCard
  attr_accessor :title, :memory_capacity, :memory_frequency, :memory_type, :manufacturer, :gpu_name, :gpu_frequency, :min_price, :max_price, :img_url, :reference_url

    def initialize(title, memory_capacity, memory_frequency, memory_type, manufacturer, gpu_name, gpu_frequency, min_price, max_price, img_url, reference_url)
      @title = title
      @memory_capacity = memory_capacity
      @memory_frequency = memory_frequency
      @memory_type = memory_type
      @manufacturer = manufacturer
      @gpu_name = gpu_name
      @gpu_frequency = gpu_frequency
      @min_price = min_price
      @max_price = max_price
      @img_url = img_url
      @reference_url = reference_url
    end
  
  def values
    [@title, @memory_capacity, @memory_frequency, @memory_type, @manufacturer, @gpu_name, @gpu_frequency, @min_price, @max_price, @img_url, @reference_url]
  end
end