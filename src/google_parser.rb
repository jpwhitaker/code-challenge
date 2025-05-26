require 'nokogiri'
require 'json'

class GoogleParser
  def initialize(url = "files/van-gogh-paintings.html")
    @input_file = url
    content = File.read(url)
    @doc = Nokogiri::HTML(content)
  end

  def parse
    items = get_gallery_items
    artworks_array = items.map do |item|
      name = extract_name(item)
      image = extract_image(item)
      extension = extract_extension(item)
      link = extract_link(item)
      
      artwork = {}
      artwork[:name] = name
      artwork[:extensions] = extension if extension
      artwork[:link] = link
      artwork[:image] = image
      artwork
    end
    
    output = {"artworks": artworks_array}
    output_filename = generate_output_filename
    File.write(output_filename, JSON.pretty_generate(output))
    puts "Output written to #{output_filename}"
  end

  def get_gallery_items
    gallery_items = @doc.css('div.iELo6')
  end

  def extract_image(item)
    id = item.css('img.taFZJe').first['id']
    if id
      content = @doc.to_s
      sections = content.split("data:image/jpeg;base64,")
      matching_sections = []
      sections[1..-1].each do |section|
        if section.include?(id)
          end_pos = section.index("';")
          if end_pos
            base64_part = section[0...end_pos]
            base64_part = "\"#{base64_part}\"".undump
            matching_sections << base64_part
          end
        end
      end
      
      if matching_sections.any?
        longest_base64 = matching_sections.max_by(&:length)
        return "data:image/jpeg;base64,#{longest_base64}"
      end
  
    else
      return item.css('img.taFZJe').first['data-src']
    end
  
    nil
  end

  def extract_name(item)
    name = item.css("div.pgNMRc").first.text.strip
  end

  def extract_extension(item)
    extension = item.css("div.cxzHyb").first.text.strip
    extension.empty? ? nil : [extension]
  end

  def extract_link(item)
    begin
      anchor = item.css("a").first
      link = anchor['href']
      return "https://www.google.com#{link}"
    end
  end

  private

  def generate_output_filename
    base_name = File.basename(@input_file, File.extname(@input_file))
    "files/#{base_name}-array.json"
  end
end
