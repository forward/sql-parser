lexer = require('../lib/lexer')
parser = require("../lib/grammer").parser

parse = (query) -> parser.parse(lexer.tokenize(query))

describe "SQL Grammer", ->
  describe "SELECT Queries", ->
    it "parses: SELECT * FROM my_table", ->
      expect(parse("SELECT * FROM my_table")).toEqual("SELECT * FROM my_table")


# console.log parser.parse(lexer.tokenize("SELECT COUNT(foo), bar AS x, y FROM my_table WHERE a = 5 and b > a"))
# console.log parser.parse(lexer.tokenize("SELECT * FROM my_table ORDER BY age DESC"))
# console.log parser.parse(lexer.tokenize("SELECT * FROM my_table GROUP BY first, last"))