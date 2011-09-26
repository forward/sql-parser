lexer = require('../lib/lexer')
parser = require("../lib/grammer").parser

parser.lexer =
  lex: ->
    [tag, @yytext, @yylineno] = @tokens[@pos++] or ['']
    tag
  setInput: (@tokens) ->
    @pos = 0
  upcomingInput: ->
    ""
    
console.log parser.parse(lexer.tokenize("SELECT * FROM my_table"))
console.log parser.parse(lexer.tokenize("SELECT COUNT(foo), bar AS x, y FROM my_table WHERE a = 5 and b > a"))
