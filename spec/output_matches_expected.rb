require_relative '../src/google_parser'
require 'json'

RSpec.describe "Output matches expected JSON" do
  let(:my_array) { JSON.parse(File.read("files/van-gogh-paintings-array.json")) }
  let(:expected_array) { JSON.parse(File.read("files/expected-array.json")) }

  it "matches expected output exactly" do
    expect(my_array).to eq(expected_array)
  end

  it "validates basic structure and content" do
    my_artworks = my_array["artworks"]
    expected_artworks = expected_array["artworks"]
    
    expect(my_artworks.length).to eq(expected_artworks.length), 
      "Expected #{expected_artworks.length} artworks, got #{my_artworks.length}"
    
    my_artworks.each_with_index do |artwork, index|
      expected = expected_artworks[index]
      
      expect(artwork["name"]).to eq(expected["name"]), 
        "Artwork #{index + 1} name mismatch: got '#{artwork['name']}', expected '#{expected['name']}'"
      
      expect(artwork["extensions"]).to eq(expected["extensions"]), 
        "Artwork #{index + 1} extensions mismatch: got #{artwork['extensions']}, expected #{expected['extensions']}"
      
      expect(artwork["link"]).to eq(expected["link"]), 
        "Artwork #{index + 1} link mismatch"
      
      expect(artwork["image"]).to eq(expected["image"]), 
        "Artwork #{index + 1} image mismatch"
    end
  end
end 