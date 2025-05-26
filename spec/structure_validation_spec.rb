require_relative '../src/google_parser'
require 'json'

RSpec.describe "Structure validation for all HTML files" do
  HTML_FILES = ['van-gogh-paintings.html', 'goya-paintings.html', 'courbet-paintings.html', 'gauguin-paintings.html']
  
  HTML_FILES.each do |html_file|
    describe "#{html_file}" do
      let(:base_name) { File.basename(html_file, File.extname(html_file)) }
      let(:output_file) { "files/#{base_name}-array.json" }
      
      before(:all) do
        # Parse the HTML file to generate the output
        parser = GoogleParser.new("files/#{html_file}")
        parser.parse
      end
      
      let(:parsed_data) { JSON.parse(File.read(output_file)) }
      let(:artworks) { parsed_data["artworks"] }
      
      it "generates a valid JSON output file" do
        expect(File.exist?(output_file)).to be true
        expect { JSON.parse(File.read(output_file)) }.not_to raise_error
      end
      
      it "has the correct top-level structure" do
        expect(parsed_data).to be_a(Hash)
        expect(parsed_data).to have_key("artworks")
        expect(parsed_data["artworks"]).to be_an(Array)
      end
      
      it "contains at least one artwork" do
        expect(artworks.length).to be > 0
      end
      
      it "has valid artwork hash" do
        artworks.each_with_index do |artwork, index|
          expect(artwork).to be_a(Hash), "Artwork #{index + 1} should be a hash"
          
          # Required fields
          expect(artwork).to have_key("name"), "Artwork #{index + 1} missing name"
          expect(artwork).to have_key("link"), "Artwork #{index + 1} missing link"
          expect(artwork).to have_key("image"), "Artwork #{index + 1} missing image"
          
          # Name should be a non-empty string
          expect(artwork["name"]).to be_a(String), "Artwork #{index + 1} name should be string"
          expect(artwork["name"].strip).not_to be_empty, "Artwork #{index + 1} name should not be empty"
          
          # Link should be a valid Google URL
          expect(artwork["link"]).to be_a(String), "Artwork #{index + 1} link should be string"
          expect(artwork["link"]).to start_with("https://www.google.com"), "Artwork #{index + 1} link should be Google URL"
          
          # Image should be present
          expect(artwork["image"]).to be_a(String), "Artwork #{index + 1} image should be string"
          expect(artwork["image"]).not_to be_empty, "Artwork #{index + 1} image should not be empty"
          
          # Extensions should be an array if present
          if artwork.has_key?("extensions") && artwork["extensions"]
            expect(artwork["extensions"]).to be_an(Array), "Artwork #{index + 1} extensions should be array if present"
            expect(artwork["extensions"]).not_to be_empty, "Artwork #{index + 1} extensions should not be empty array if present"
          end
        end
      end
      
      it "has reasonable number of artworks" do
        expect(artworks.length).to be_between(10, 100)
      end
      
      it "has unique artwork names" do
        names = artworks.map { |artwork| artwork["name"] }
        expect(names.uniq.length).to eq(names.length), "All artwork names should be unique"
      end
    end
  end
end 