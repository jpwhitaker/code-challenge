require 'nokogiri'
require 'json'
require 'debug'


class GoogleParser
  def initialize(url = "files/van-gogh-paintings.html")
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
      # debugger
      {
        name: name,
        extensions: extension,
        link: link,
        image: image,
      }
    end
    
    output = {"artworks": artworks_array}
    File.write("my-array.json", JSON.pretty_generate(output))
    puts "Output written to my-array.json"
  end

  def get_gallery_items
    galleryItems = @doc.css('div.iELo6')
    galleryItems.first.css('img.taFZJe').first
    return galleryItems
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
            # debugger
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
      link = anchor.attribute_nodes.first.value
      return "https://www.google.com#{link}"
    end
  end

end


parser = GoogleParser.new
parser.parse