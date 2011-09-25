lexer = require('../lib/lexer')

tokens = lexer.tokenize("SELECT * FROM my_stream WHERE name = 'andy' AND age = 28")

console.log(tokens)