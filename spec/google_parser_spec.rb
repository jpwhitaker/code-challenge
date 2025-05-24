require_relative '../src/google_parser'
require 'json'
require 'colorize'

RSpec.describe GoogleParser do
  before(:all) do
    # Run the parser to generate output
    parser = GoogleParser.new
    parser.parse
  end

  describe "Comparing output with expected results" do
    let(:my_array) { JSON.parse(File.read("my-array.json")) }
    let(:expected_array) { JSON.parse(File.read("files/expected-array.json")) }

    it "should have the same number of artworks" do
      expect(my_array["artworks"].length).to eq(expected_array["artworks"].length)
    end

    it "should compare each artwork and show differences" do
      my_artworks = my_array["artworks"]
      expected_artworks = expected_array["artworks"]
      
      puts "\n=== DETAILED COMPARISON ===".yellow
      puts "Expected: #{expected_artworks.length} artworks".green
      puts "Actual: #{my_artworks.length} artworks".blue
      
      if my_artworks.length != expected_artworks.length
        puts "❌ COUNT MISMATCH!".red
        puts "Expected #{expected_artworks.length} but got #{my_artworks.length}".red
      else
        puts "✅ COUNT MATCHES".green
      end
      
      puts "\n--- ARTWORK BY ARTWORK COMPARISON ---".yellow
      
      max_count = [my_artworks.length, expected_artworks.length].max
      
      (0...max_count).each do |i|
        puts "\n🎨 Artwork #{i + 1}:".cyan
        
        expected_artwork = expected_artworks[i]
        my_artwork = my_artworks[i]
        
        if expected_artwork.nil?
          puts "  ❌ MISSING in expected (you have extra)".red
          puts "  Your artwork: #{my_artwork&.dig('name')}".blue
          next
        end
        
        if my_artwork.nil?
          puts "  ❌ MISSING in your output".red
          puts "  Expected artwork: #{expected_artwork['name']}".green
          next
        end
        
        # Compare each field
        compare_field("name", expected_artwork, my_artwork, i)
        compare_field("extensions", expected_artwork, my_artwork, i)
        compare_field("link", expected_artwork, my_artwork, i)
        compare_field("image", expected_artwork, my_artwork, i)
      end
      
      # Summary
      puts "\n=== SUMMARY ===".yellow
      show_summary(my_artworks, expected_artworks)
    end

    private

    def compare_field(field, expected, actual, index)
      expected_value = expected[field]
      actual_value = actual[field]
      
      if expected_value == actual_value
        puts "  ✅ #{field}: MATCH".green
      else
        puts "  ❌ #{field}: MISMATCH".red
        puts "    Expected: #{truncate_value(expected_value)}".green
        puts "    Actual:   #{truncate_value(actual_value)}".blue
        
        if field == "extensions" && expected_value.is_a?(Array) && actual_value.is_a?(Array)
          puts "    Expected extensions: #{expected_value}".green
          puts "    Actual extensions:   #{actual_value}".blue
        end
      end
    end

    def truncate_value(value)
      if value.is_a?(String) && value.length > 100
        "#{value[0..100]}... (truncated, length: #{value.length})"
      elsif value.is_a?(Array)
        value.inspect
      else
        value.inspect
      end
    end

    def show_summary(my_artworks, expected_artworks)
      total_fields = 0
      matching_fields = 0
      
      max_count = [my_artworks.length, expected_artworks.length].min
      
      (0...max_count).each do |i|
        expected = expected_artworks[i]
        actual = my_artworks[i]
        
        %w[name extensions link image].each do |field|
          total_fields += 1
          matching_fields += 1 if expected[field] == actual[field]
        end
      end
      
      accuracy = total_fields > 0 ? (matching_fields.to_f / total_fields * 100).round(2) : 0
      
      puts "📊 Overall Accuracy: #{accuracy}% (#{matching_fields}/#{total_fields} fields match)".cyan
      
      if accuracy == 100
        puts "🎉 PERFECT MATCH! Your parser is working correctly!".green
      elsif accuracy >= 80
        puts "🟡 GOOD - Most fields match, minor issues to fix".yellow
      elsif accuracy >= 50
        puts "🟠 NEEDS WORK - About half the fields match".orange
      else
        puts "🔴 MAJOR ISSUES - Most fields don't match".red
      end
      
      puts "\nKey areas to check:".cyan
      puts "- Name extraction accuracy"
      puts "- Extension/date parsing"
      puts "- Link generation"
      puts "- Image data extraction"
    end
  end
end 