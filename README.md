# JP's Google Parser

## Usage

### Running the Parser

To parse HTML files and extract artwork data from the command line:

```bash
# Parse van-gogh-paintings.html (default)
ruby src/run_parser.rb

# Parse a specific HTML file (optional argument)
ruby src/run_parser.rb goya-paintings.html
```

This will generate JSON output files in the `files/` directory:
- `files/van-gogh-paintings-array.json` (when run with no arguments)
- `files/goya-paintings-array.json` (when run with `goya-paintings.html`)


### Running Tests

```bash
# Run all tests with detailed output
rspec --format documentation

# Run specific test file
rspec spec/structure_validation_spec.rb

# Run tests for a specific HTML file
rspec spec/structure_validation_spec.rb -e "goya-paintings.html"

# Run output matches expected test
rspec spec/output_matches_expected_spec.rb
```

The tests validate:
- JSON output structure and validity
- Required fields (name, link, image)
- Data quality (non-empty values, valid URLs)
- Reasonable artwork counts (10-100 items)
- Unique artwork names
- Exact match against expected output (**van Gogh only**)

---
# Extract Van Gogh Paintings Code Challenge

Goal is to extract a list of Van Gogh paintings from the attached Google search results page.

![Van Gogh paintings](https://github.com/serpapi/code-challenge/blob/master/files/van-gogh-paintings.png?raw=true "Van Gogh paintings")

## Instructions

This is already fully supported on SerpApi. ([relevant test], [html file], [sample json], and [expected array].)
Try to come up with your own solution and your own test.
Extract the painting `name`, `extensions` array (date), and Google `link` in an array.

Fork this repository and make a PR when ready.

Programming language wise, Ruby (with RSpec tests) is strongly suggested but feel free to use whatever you feel like.

Parse directly the HTML result page ([html file]) in this repository. No extra HTTP requests should be needed for anything.

[relevant test]: https://github.com/serpapi/test-knowledge-graph-desktop/blob/master/spec/knowledge_graph_claude_monet_paintings_spec.rb
[sample json]: https://raw.githubusercontent.com/serpapi/code-challenge/master/files/van-gogh-paintings.json
[html file]: https://raw.githubusercontent.com/serpapi/code-challenge/master/files/van-gogh-paintings.html
[expected array]: https://raw.githubusercontent.com/serpapi/code-challenge/master/files/expected-array.json

Add also to your array the painting thumbnails present in the result page file (not the ones where extra requests are needed). 

Test against 2 other similar result pages to make sure it works against different layouts. (Pages that contain the same kind of carrousel. Don't necessarily have to be paintings.)

The suggested time for this challenge is 4 hours. But, you can take your time and work more on it if you want.
