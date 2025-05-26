require_relative 'google_parser'
html_file = ARGV[0] || "van-gogh-paintings.html"

parser = GoogleParser.new("files/#{html_file}")
parser.parse