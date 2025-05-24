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
        extensions: [extension],
        link: link,
        image: image,
      }
    end
    puts JSON.pretty_generate({"artworks": artworks_array})
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
      
      # Look through each section for one that contains our ID
      sections[1..-1].each do |section|
        if section.include?(id)
          # Grab everything up to the first "';
          end_pos = section.index("';")
          if end_pos
            base64_part = section[0...end_pos]
            return "data:image/jpeg;base64,#{base64_part}"
          end
        end
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
    item.css("div.cxzHyb").first.text.strip
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
# parser.extract_images
# parser.get_gallery_items
parser.parse