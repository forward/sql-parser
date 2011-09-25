class Lexer
  constructor: (sql, opts={}) ->
    @sql = sql
    @preserveWhitespace = opts.preserveWhitespace || false
    @tokens = []
    i = 0
    while @chunk = sql.slice(i)
      i += @keywordToken() or
           @starToken() or
           @operatorToken() or
           @conditionalToken() or
           @numberToken() or
           @stringToken() or
           @whitespaceToken() or
           @literalToken()
  
  token: (name, value) ->
    console.log(name, value)
    @tokens.push([name, value])
  
  tokenizeFromRegex: (name, regex, part=0, lengthPart=part, output=true) ->
    return 0 unless match = regex.exec(@chunk)
    partMatch = match[part]
    @token(name, partMatch) if output
    return match[lengthPart].length
    
  
  tokenizeFromList: (name, list) ->
    ret = 0
    for entry in list
      matcher = new RegExp("^(#{entry})\\W",'i')
      match = matcher.exec(@chunk)
      if match
        @token(name, entry)
        ret = entry.length
        break
    ret
  
  keywordToken:     -> @tokenizeFromList('KEYWORD', SQL_KEYWORDS)
  operatorToken:    -> @tokenizeFromList('OPERATOR', SQL_OPERATORS)  
  conditionalToken: -> @tokenizeFromList('CONDITIONAL', SQL_CONDITIONALS)
  
  starToken:        -> @tokenizeFromRegex('STAR', STAR)
  whitespaceToken:  -> @tokenizeFromRegex('WHITESPACE', WHITESPACE, 0, 0, @preserveWhitespace)
  literalToken:     -> @tokenizeFromRegex('LITERAL', LITERAL)
  numberToken:      -> @tokenizeFromRegex('NUMBER', NUMBER)
  stringToken:      -> @tokenizeFromRegex('STRING', STRING, 1, 0)
  
  
  
  SQL_KEYWORDS        = ['SELECT', 'FROM', 'WHERE']
  SQL_OPERATORS       = ['=']
  SQL_CONDITIONALS    = ['AND']
  STAR                = /^\*/
  WHITESPACE          = /^ +/
  LITERAL             = /^[a-z_][a-z0-9_]+/i
  NUMBER              = /^[0-9]+/
  STRING              = /^'(.*?)'/
  
  
  
exports.tokenize = (sql) -> (new Lexer(sql)).tokens

