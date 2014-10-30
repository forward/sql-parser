lexer = require('../lib/lexer')

describe "SQL Lexer", ->
  it "eats select queries", ->
    tokens = lexer.tokenize("select * from my_table")
    tokens.should.eql [
      ["SELECT", "select", 1]
      ["STAR", "*", 1]
      ["FROM", "from", 1]
      ["LITERAL", "my_table", 1]
      ["EOF", "", 1]
    ]

  it "eats select queries with stars and multiplication", ->
    tokens = lexer.tokenize("select * from my_table where foo = 1 * 2")
    tokens.should.eql [
      ["SELECT", "select", 1]
      ["STAR", "*", 1]
      ["FROM", "from", 1]
      ["LITERAL", "my_table", 1]
      ["WHERE", "where", 1]
      ["LITERAL", "foo", 1]
      ["OPERATOR", "=", 1]
      ["NUMBER", "1", 1]
      ["MATH_MULTI", "*", 1]
      ["NUMBER", "2", 1]
      ["EOF", "", 1]
    ]


  it "eats sub selects", ->
    tokens = lexer.tokenize("select * from (select * from my_table) t")
    tokens.should.eql [
      ["SELECT", "select", 1]
      ["STAR", "*", 1]
      ["FROM", "from", 1]
      [ 'LEFT_PAREN', '(', 1 ]
      [ 'SELECT', 'select', 1 ]
      [ 'STAR', '*', 1 ]
      [ 'FROM', 'from', 1 ]
      [ 'LITERAL', 'my_table', 1 ]
      [ 'RIGHT_PAREN', ')', 1 ]
      ["LITERAL", "t", 1]
      ["EOF", "", 1]
    ]

  it "eats joins", ->
    tokens = lexer.tokenize("select * from a join b on a.id = b.id")
    tokens.should.eql [
      ["SELECT", "select", 1]
      ["STAR", "*", 1]
      ["FROM", "from", 1]
      [ 'LITERAL', 'a', 1 ]
      [ 'JOIN', 'join', 1 ]
      [ 'LITERAL', 'b', 1 ]
      [ 'ON', 'on', 1 ]
      [ 'LITERAL', 'a', 1 ]
      [ 'DOT', '.', 1 ]
      [ 'LITERAL', 'id', 1 ]
      [ 'OPERATOR', '=', 1 ]
      [ 'LITERAL', 'b', 1 ]
      [ 'DOT', '.', 1 ]
      [ 'LITERAL', 'id', 1 ]
      ["EOF", "", 1]
    ]
