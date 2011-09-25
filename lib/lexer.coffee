class Lexer
  constructor: (sql, opts={}) ->
    @sql = sql
    @preserveWhitespace = opts.preserveWhitespace || false
    @tokens = []
    i = 0
    while @chunk = sql.slice(i)
      bytesConsumed =  @keywordToken() or
                       @starToken() or
                       @functionToken() or
                       @seperatorToken() or
                       @operatorToken() or
                       @conditionalToken() or
                       @numberToken() or
                       @stringToken() or
                       @parensToken() or
                       @whitespaceToken() or
                       @literalToken()
      throw new Error("NOTHING CONSUMED: Stopped at - '#{@chunk.slice(0,30)}'") if bytesConsumed < 1
      i += bytesConsumed
  
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
  functionToken:    -> @tokenizeFromList('FUNCTION', SQL_FUNCTIONS)
  
  starToken:        -> @tokenizeFromRegex('STAR', STAR)
  seperatorToken:   -> @tokenizeFromRegex('SEPERATOR', SEPERATOR)
  whitespaceToken:  -> @tokenizeFromRegex('WHITESPACE', WHITESPACE, 0, 0, @preserveWhitespace)
  literalToken:     -> @tokenizeFromRegex('LITERAL', LITERAL, 1, 0)
  numberToken:      -> @tokenizeFromRegex('NUMBER', NUMBER)
  stringToken:      -> @tokenizeFromRegex('STRING', STRING, 1, 0)
  parensToken:      -> 
    @tokenizeFromRegex('LEFT_PAREN', /^\(/,) or @tokenizeFromRegex('RIGHT_PAREN', /^\)/,)
  
  
  
  SQL_KEYWORDS        = ['SELECT', 'FROM', 'WHERE', 'GROUP BY', 'AS']
  SQL_FUNCTIONS       = ['COUNT', 'MIN', 'MAX']
  SQL_OPERATORS       = ['=']
  SQL_CONDITIONALS    = ['AND']
  STAR                = /^\*/
  SEPERATOR           = /^,/
  WHITESPACE          = /^ +/
  LITERAL             = /^`?([a-z_][a-z0-9_]{0,})`?/i
  NUMBER              = /^[0-9]+/
  STRING              = /^'(.*?)'/
  
  
  
exports.tokenize = (sql, opts) -> (new Lexer(sql, opts)).tokens

