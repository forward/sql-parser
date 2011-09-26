lexer = require('../lib/lexer')

# tokens = lexer.tokenize("SELECT * FROM my_stream WHERE name = 'andy' AND age = 28")
# 
# console.log(tokens)
# 
# tokens = lexer.tokenize("SELECT name, age FROM my_stream WHERE name = 'andy' AND age = 28")
# 
# console.log(tokens)
# 
# tokens = lexer.tokenize("SELECT name, age FROM my_stream WHERE")
# 
# console.log(tokens)

tokens = lexer.tokenize """
  SELECT x AS `first_name`, min(age) 
  FROM my_stream 
  GROUP BY age, name 
  ORDER BY age DESC 
  HAVING COUNT(*) > 5"""

console.log(tokens)
