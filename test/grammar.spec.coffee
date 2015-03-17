lexer = require('../lib/lexer')
parser = require("../lib/parser")

parse = (query) ->
  parser.parse(lexer.tokenize(query))

describe "SQL Grammar", ->
  describe "SELECT Queries", ->

    it "parses ORDER BY clauses", ->
      parse("SELECT * FROM my_table ORDER BY x DESC").toString().should.eql """
      SELECT *
        FROM `my_table`
        ORDER BY `x` DESC
      """

    it "parses ORDER BY clauses with OFFSET n ROWS", ->
      parse("SELECT * FROM my_table ORDER BY x DESC OFFSET 10 ROWS").toString().should.eql """
      SELECT *
        FROM `my_table`
        ORDER BY `x` DESC
        OFFSET 10 ROWS
      """

    it "parses ORDER BY clauses with OFFSET n ROW", ->
      parse("SELECT * FROM my_table ORDER BY x DESC OFFSET 10 ROW").toString().should.eql """
      SELECT *
        FROM `my_table`
        ORDER BY `x` DESC
        OFFSET 10 ROWS
      """

    it "parses ORDER BY clauses with OFFSET n ROW FETCH FIRST n ONLY", ->
      parse("SELECT * FROM my_table ORDER BY x DESC OFFSET 10 ROW FETCH FIRST 15 ROW ONLY").toString().should.eql """
      SELECT *
        FROM `my_table`
        ORDER BY `x` DESC
        OFFSET 10 ROWS
        FETCH NEXT 15 ROWS ONLY
      """

    it "parses ORDER BY clauses with OFFSET n ROW FETCH NEXT n ONLY", ->
      parse("SELECT * FROM my_table ORDER BY x DESC OFFSET 10 ROW FETCH NEXT 15 ROWS ONLY").toString().should.eql """
      SELECT *
        FROM `my_table`
        ORDER BY `x` DESC
        OFFSET 10 ROWS
        FETCH NEXT 15 ROWS ONLY
      """

    it "parses GROUP BY clauses", ->
      parse("SELECT * FROM my_table GROUP BY x, y").toString().should.eql """
      SELECT *
        FROM `my_table`
        GROUP BY `x`, `y`
      """

    it "parses LIMIT clauses", ->
      parse("SELECT * FROM my_table LIMIT 10").toString().should.eql """
      SELECT *
        FROM `my_table`
        LIMIT 10
      """

    it "parses LIMIT clauses after ORDER BY", ->
      parse("SELECT * FROM my_table ORDER BY cat DESC LIMIT 10").toString().should.eql """
      SELECT *
        FROM `my_table`
        ORDER BY `cat` DESC
        LIMIT 10
      """

    it "parses LIMIT clauses with comma separated offset", ->
      parse("SELECT * FROM my_table LIMIT 30, 10").toString().should.eql """
      SELECT *
        FROM `my_table`
        LIMIT 10
        OFFSET 30
      """

    it "parses LIMIT clauses with OFFSET keyword", ->
      parse("SELECT * FROM my_table LIMIT 10 OFFSET 30").toString().should.eql """
      SELECT *
        FROM `my_table`
        LIMIT 10
        OFFSET 30
      """

    it "parses SELECTs with FUNCTIONs", ->
      parse("SELECT a, COUNT(1, b) FROM my_table LIMIT 10").toString().should.eql """
      SELECT `a`, COUNT(1, `b`)
        FROM `my_table`
        LIMIT 10
      """

    it "parses COUNT(DISTINCT field)", ->
      parse("select a, count(distinct b) FROM my_table limit 10").toString().should.eql """
      SELECT `a`, COUNT(DISTINCT `b`)
        FROM `my_table`
        LIMIT 10
      """

    it "parses WHERE clauses", ->
      parse("SELECT * FROM my_table WHERE x > 1 AND y = 'foo'").toString().should.eql """
      SELECT *
        FROM `my_table`
        WHERE ((`x` > 1) AND (`y` = 'foo'))
      """

    it "parses complex WHERE clauses", ->
      parse("SELECT * FROM my_table WHERE a > 10 AND (a < 30 OR b = 'c')").toString().should.eql """
      SELECT *
        FROM `my_table`
        WHERE ((`a` > 10) AND ((`a` < 30) OR (`b` = 'c')))
      """

    it "parses WHERE with ORDER BY clauses", ->
      parse("SELECT * FROM my_table WHERE x > 1 ORDER BY y").toString().should.eql """
      SELECT *
        FROM `my_table`
        WHERE (`x` > 1)
        ORDER BY `y` ASC
      """

    it "parses WHERE with multiple ORDER BY clauses", ->
      parse("SELECT * FROM my_table WHERE x > 1 ORDER BY x, y DESC").toString().should.eql """
      SELECT *
        FROM `my_table`
        WHERE (`x` > 1)
        ORDER BY `x` ASC, `y` DESC
      """

    it "parses WHERE with ORDER BY clauses with direction", ->
      parse("SELECT * FROM my_table WHERE x > 1 ORDER BY y ASC").toString().should.eql """
      SELECT *
        FROM `my_table`
        WHERE (`x` > 1)
        ORDER BY `y` ASC
      """

    it "parses WHERE with GROUP BY clauses", ->
      parse("SELECT * FROM my_table WHERE x > 1 GROUP BY x, y").toString().should.eql """
      SELECT *
        FROM `my_table`
        WHERE (`x` > 1)
        GROUP BY `x`, `y`
      """

    it "parses WHERE with GROUP BY and ORDER BY clauses", ->
      parse("SELECT * FROM my_table WHERE x > 1 GROUP BY x, y ORDER BY COUNT(y) ASC").toString().should.eql """
      SELECT *
        FROM `my_table`
        WHERE (`x` > 1)
        GROUP BY `x`, `y`
        ORDER BY COUNT(`y`) ASC
      """

    it "parses GROUP BY and HAVING clauses", ->
      parse("SELECT * FROM my_table GROUP BY x, y HAVING COUNT(`y`) > 1").toString().should.eql """
      SELECT *
        FROM `my_table`
        GROUP BY `x`, `y`
        HAVING (COUNT(`y`) > 1)
      """

    it "parses UDFs", ->
      parse("SELECT LENGTH(a) FROM my_table").toString().should.eql """
      SELECT LENGTH(`a`)
        FROM `my_table`
      """

    it "parses expressions in place of fields", ->
      parse("SELECT f+LENGTH(f)/3 AS f1 FROM my_table").toString().should.eql """
      SELECT (`f` + (LENGTH(`f`) / 3)) AS `f1`
        FROM `my_table`
      """

    it "supports booleans", ->
      parse("SELECT null FROM my_table WHERE a = true").toString().should.eql """
      SELECT NULL
        FROM `my_table`
        WHERE (`a` = TRUE)
      """

    it "supports IS and IS NOT", ->
      parse("SELECT * FROM my_table WHERE a IS NULL AND b IS NOT NULL").toString().should.eql """
      SELECT *
        FROM `my_table`
        WHERE ((`a` IS NULL) AND (`b` IS NOT NULL))
      """

    it "supports nested expressions", ->
      parse("SELECT * FROM my_table WHERE MOD(LENGTH(a) + LENGTH(b), c)").toString().should.eql """
      SELECT *
        FROM `my_table`
        WHERE MOD((LENGTH(`a`) + LENGTH(`b`)), `c`)
      """

    it "supports nested fields using dot syntax", ->
      parse("SELECT a.b.c FROM my_table WHERE a.b > 2").toString().should.eql """
      SELECT `a.b.c`
        FROM `my_table`
        WHERE (`a.b` > 2)
      """

    it "supports time window extensions", ->
      parse("SELECT * FROM my_table.win:length(123)").toString().should.eql """
      SELECT *
        FROM `my_table`.win:length(123)
      """

    it "parses sub selects", ->
      parse("select * from (select * from my_table)").toString().should.eql """
      SELECT *
        FROM (
          SELECT *
            FROM `my_table`
        )
      """

    it "parses named sub selects", ->
      parse("select * from (select * from my_table) t").toString().should.eql """
      SELECT *
        FROM (
          SELECT *
            FROM `my_table`
        ) `t`
      """

    it "parses single joins", ->
      parse("select * from a join b on a.id = b.id").toString().should.eql """
      SELECT *
        FROM `a`
        JOIN `b`
          ON (`a.id` = `b.id`)
      """

    it "parses right outer joins", ->
      parse("select * from a right outer join b on a.id = b.id").toString().should.eql """
      SELECT *
        FROM `a`
        RIGHT OUTER JOIN `b`
          ON (`a.id` = `b.id`)
      """

    it "parses multiple joins", ->
      parse("select * from a join b on a.id = b.id join c on a.id = c.id").toString().should.eql """
      SELECT *
        FROM `a`
        JOIN `b`
          ON (`a.id` = `b.id`)
        JOIN `c`
          ON (`a.id` = `c.id`)
      """

    it "parses UNIONs", ->
      parse("select * from a union select * from b").toString().should.eql """
      SELECT *
        FROM `a`
      UNION
      SELECT *
        FROM `b`
      """

    it "parses UNION ALL", ->
      parse("select * from a union all select * from b").toString().should.eql """
      SELECT *
        FROM `a`
      UNION ALL
      SELECT *
        FROM `b`
      """

  describe "string quoting", ->
    it "doesn't choke on escaped quotes", ->
      parse("select * from a where foo = 'I\\'m'").toString().should.eql """
      SELECT *
        FROM `a`
        WHERE (`foo` = 'I\\'m')
      """

    it "allows using double quotes", ->
      parse('select * from a where foo = "a"').toString().should.eql """
      SELECT *
        FROM `a`
        WHERE (`foo` = "a")
      """

    it "allows nesting different quote styles", ->
      parse("""select * from a where foo = "I'm" """).toString().should.eql """
      SELECT *
        FROM `a`
        WHERE (`foo` = "I'm")
      """

  describe "subselect clauses", ->
    it "parses an IN clause containing a list", ->
      parse("""select * from a where x in (1,2,3)""").toString().should.eql """
      SELECT *
        FROM `a`
        WHERE (`x` IN (1, 2, 3))
      """

    it "parses an IN clause containing a query", ->
      parse("""select * from a where x in (select foo from bar)""").toString().should.eql """
      SELECT *
        FROM `a`
        WHERE (`x` IN (
          SELECT `foo`
            FROM `bar`
        ))
      """

    it "parses a NOT IN clause containing a query", ->
      parse("""select * from a where x not in (select foo from bar)""").toString().should.eql """
      SELECT *
        FROM `a`
        WHERE (`x` NOT IN (
          SELECT `foo`
            FROM `bar`
        ))
      """

    it "parses an EXISTS clause containing a query", ->
      parse("""select * from a where exists (select foo from bar)""").toString().should.eql """
      SELECT *
        FROM `a`
        WHERE (EXISTS (
          SELECT `foo`
            FROM `bar`
        ))
      """

  describe "aliases", ->
    it "parses aliased table names", ->
      parse("""select * from a b""").toString().should.eql """
      SELECT *
        FROM `a` AS `b`
      """

    it "parses aliased table names with as", ->
      parse("""select * from a as b""").toString().should.eql """
      SELECT *
        FROM `a` AS `b`
      """

  describe "STARS", ->
    it "parses stars as multiplcation", ->
      parse('SELECT * FROM foo WHERE a = 1*2').toString().should.eql """
      SELECT *
        FROM `foo`
        WHERE (`a` = (1 * 2))
      """

  describe "Parameters", ->
    it "parses query parameters", ->
      parse('select * from foo where bar = $12').toString().should.eql """
      SELECT *
        FROM `foo`
        WHERE (`bar` = $12)
      """

