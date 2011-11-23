lexer = require('../lib/lexer')

describe "SQL Lexer", ->
  it "eats select queries", ->
    tokens = lexer.tokenize("select * from my_table")
    expect(tokens).toEqual [
      ["SELECT", "select", 1]
      ["STAR", "*", 1]
      ["FROM", "from", 1]
      ["LITERAL", "my_table", 1]
      ["EOF", "", 1]
    ]

  it "eats sub selects", ->
    tokens = lexer.tokenize("select * from (select * from my_table) t")
    expect(tokens).toEqual [
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

# tokens = lexer.tokenize("SELECT * FROM my_stream WHERE name = 'andy' AND age = 28")
# 
# console.log(tokens)
# 
# tokens = lexer.tokenize("SELECT name, age FROM my_stream WHERE name = 'andy' AND age = 28")
# 
# console.log(tokens)
# 
# tokens = lexer.tokenize("SELECT LENGTH(foo) FROM data")
# 
# console.log(tokens)
#
# tokens = lexer.tokenize("SELECT f+1 AS f1 FROM data")
# 
# console.log(tokens)
# 
# tokens = lexer.tokenize """
#   SELECT x AS `first_name`, min(age) 
#   FROM my_stream.win:length(123)
#   WHERE age > 10.2 AND (age < 30 OR first_name = 'andy')
#   GROUP BY age, name 
#   ORDER BY age DESC 
#   HAVING COUNT(*) > 5"""
# 
# console.log(tokens)
