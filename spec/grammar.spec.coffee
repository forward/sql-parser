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
    
    it "parses LIMIT clauses", ->
      expect(parse("SELECT * FROM my_table LIMIT 10").toString()).toEqual """
      SELECT *
        FROM `my_table`
        LIMIT 10
      """
    
    it "parses WHERE clauses", ->
      expect(parse("SELECT * FROM my_table WHERE x > 1 AND y = 'foo'").toString()).toEqual """
      SELECT *
        FROM `my_table`
        WHERE `x` > 1 AND `y` = 'foo'
      """

    it "parses WHERE with ORDER BY clauses", ->
      expect(parse("SELECT * FROM my_table WHERE x > 1 ORDER BY y ASC").toString()).toEqual """
      SELECT *
        FROM `my_table`
        WHERE `x` > 1
        ORDER BY `y` ASC
      """

    it "parses WHERE with GROUP BY clauses", ->
      expect(parse("SELECT * FROM my_table WHERE x > 1 GROUP BY x, y").toString()).toEqual """
      SELECT *
        FROM `my_table`
        WHERE `x` > 1
        GROUP BY `x`, `y`
      """

    it "parses WHERE with GROUP BY and ORDER BY clauses", ->
      expect(parse("SELECT * FROM my_table WHERE x > 1 GROUP BY x, y ORDER BY COUNT(y) ASC").toString()).toEqual """
      SELECT *
        FROM `my_table`
        WHERE `x` > 1
        GROUP BY `x`, `y`
        ORDER BY COUNT(`y`) ASC
      """

    it "parses GROUP BY and HAVING clauses", ->
      expect(parse("SELECT * FROM my_table GROUP BY x, y HAVING COUNT(`y`) > 1").toString()).toEqual """
      SELECT *
        FROM `my_table`
        GROUP BY `x`, `y`
        HAVING COUNT(`y`) > 1
      """
