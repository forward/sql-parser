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
    
    it "parses SELECTs with FUNCTIONs", ->
      expect(parse("SELECT a, COUNT(1, b) FROM my_table LIMIT 10").toString()).toEqual """
      SELECT `a`, COUNT(1, `b`)
        FROM `my_table`
        LIMIT 10
      """
    
    it "parses WHERE clauses", ->
      expect(parse("SELECT * FROM my_table WHERE x > 1 AND y = 'foo'").toString()).toEqual """
      SELECT *
        FROM `my_table`
        WHERE ((`x` > 1) AND (`y` = 'foo'))
      """
    
    it "parses complex WHERE clauses", ->
      expect(parse("SELECT * FROM my_table WHERE a > 10 AND (a < 30 OR b = 'c')").toString()).toEqual """
      SELECT *
        FROM `my_table`
        WHERE ((`a` > 10) AND ((`a` < 30) OR (`b` = 'c')))
      """

    it "parses WHERE with ORDER BY clauses", ->
      expect(parse("SELECT * FROM my_table WHERE x > 1 ORDER BY y").toString()).toEqual """
      SELECT *
        FROM `my_table`
        WHERE (`x` > 1)
        ORDER BY `y` ASC
      """

    it "parses WHERE with multiple ORDER BY clauses", ->
      expect(parse("SELECT * FROM my_table WHERE x > 1 ORDER BY x, y DESC").toString()).toEqual """
      SELECT *
        FROM `my_table`
        WHERE (`x` > 1)
        ORDER BY `x` ASC, `y` DESC
      """

    it "parses WHERE with ORDER BY clauses with direction", ->
      expect(parse("SELECT * FROM my_table WHERE x > 1 ORDER BY y ASC").toString()).toEqual """
      SELECT *
        FROM `my_table`
        WHERE (`x` > 1)
        ORDER BY `y` ASC
      """

    it "parses WHERE with GROUP BY clauses", ->
      expect(parse("SELECT * FROM my_table WHERE x > 1 GROUP BY x, y").toString()).toEqual """
      SELECT *
        FROM `my_table`
        WHERE (`x` > 1)
        GROUP BY `x`, `y`
      """

    it "parses WHERE with GROUP BY and ORDER BY clauses", ->
      expect(parse("SELECT * FROM my_table WHERE x > 1 GROUP BY x, y ORDER BY COUNT(y) ASC").toString()).toEqual """
      SELECT *
        FROM `my_table`
        WHERE (`x` > 1)
        GROUP BY `x`, `y`
        ORDER BY COUNT(`y`) ASC
      """

    it "parses GROUP BY and HAVING clauses", ->
      expect(parse("SELECT * FROM my_table GROUP BY x, y HAVING COUNT(`y`) > 1").toString()).toEqual """
      SELECT *
        FROM `my_table`
        GROUP BY `x`, `y`
        HAVING (COUNT(`y`) > 1)
      """

    it "parses UDFs", ->
      expect(parse("SELECT LENGTH(a) FROM my_table").toString()).toEqual """
      SELECT LENGTH(`a`)
        FROM `my_table`
      """

    it "parses expressions in place of fields", ->
      expect(parse("SELECT f+LENGTH(f)/3 AS f1 FROM my_table").toString()).toEqual """
      SELECT (`f` + (LENGTH(`f`) / 3)) AS `f1`
        FROM `my_table`
      """

    it "supports booleans", ->
      expect(parse("SELECT null FROM my_table WHERE a = true").toString()).toEqual """
      SELECT NULL
        FROM `my_table`
        WHERE (`a` = TRUE)
      """

    it "supports IS and IS NOT", ->
      expect(parse("SELECT * FROM my_table WHERE a IS NULL AND b IS NOT NULL").toString()).toEqual """
      SELECT *
        FROM `my_table`
        WHERE ((`a` IS NULL) AND (`b` IS NOT NULL))
      """

    it "supports nested expressions", ->
      expect(parse("SELECT * FROM my_table WHERE MOD(LENGTH(a) + LENGTH(b), c)").toString()).toEqual """
      SELECT *
        FROM `my_table`
        WHERE MOD((LENGTH(`a`) + LENGTH(`b`)), `c`)
      """

    it "supports nested fields using dot syntax", ->
      expect(parse("SELECT a.b.c FROM my_table WHERE a.b > 2").toString()).toEqual """
      SELECT `a.b.c`
        FROM `my_table`
        WHERE (`a.b` > 2)
      """

    it "supports time window extensions", ->
      expect(parse("SELECT * FROM my_table.win:length(123)").toString()).toEqual """
      SELECT *
        FROM `my_table`.win:length(123)
      """
