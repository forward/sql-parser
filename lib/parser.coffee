grammar = require('./grammar')

{Parser} = require 'jison'

buildParser = ->

  parser = new Parser
    tokens      : grammar.tokens.join ' '
    bnf         : grammar.grammar
    operators   : grammar.operators
    startSymbol : 'Root'

  parser.lexer =
    lex: ->
      [tag, @yytext, @yylineno] = @tokens[@pos++] or ['']
      tag
    setInput: (@tokens) -> @pos = 0
    upcomingInput: -> ""
    
  parser.yy = require('./nodes')
  
  return parser
  
exports.parser = buildParser()

exports.parse = (str) -> buildParser().parse(str)