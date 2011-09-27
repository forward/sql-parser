lexer = require('../lib/lexer')
parser = require("../lib/parser")

parse = (query) -> parser.parse(lexer.tokenize(query))

describe "SQL Grammer", ->
  describe "SELECT Queries", ->
    
    it "parses ORDER BY clauses", ->
      expect(parse("SELECT * FROM my_table ORDER BY x DESC").toString()).toEqual """
      SELECT *
        FROM `my_table`
        ORDER BY `x` DESC
      """
    
    it "parses GROUP BY clauses", ->
      expect(parse("SELECT * FROM my_table GROUP BY x, y").toString()).toEqual """
      SELECT *
        FROM `my_table`
        GROUP BY `x`, `y`
      """
    
    it "parses WHERE clauses", ->
      expect(parse("SELECT * FROM my_table WHERE x > 1 AND y = 'foo'").toString()).toEqual """
      SELECT *
        FROM `my_table`
        WHERE `x` > 1 AND `y` = 'foo'
      """
