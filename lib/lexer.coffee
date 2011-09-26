class Lexer
  constructor: (sql, opts={}) ->
    @sql = sql
    @preserveWhitespace = opts.preserveWhitespace || false
    @tokens = []
    @currentLine = 1
    i = 0
    while @chunk = sql.slice(i)
      bytesConsumed =  @keywordToken() or
                       @starToken() or
                       @functionToken() or
                       @sortOrderToken() or
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
    @token('EOF', '')
  
  token: (name, value) ->
    @tokens.push([name, value, @currentLine])
  
  tokenizeFromRegex: (name, regex, part=0, lengthPart=part, output=true) ->
    return 0 unless match = regex.exec(@chunk)
    partMatch = match[part]
    @token(name, partMatch) if output
    return match[lengthPart].length
    
  tokenizeFromWord: (name, word=name) ->
    matcher = if (/^\w+$/).test(word)
      new RegExp("^(#{word})\\b",'ig')
    else
      new RegExp("^(#{word}) ",'ig')
    match = matcher.exec(@chunk)
    return 0 unless match
    @token(name, match[1])
    return match[1].length
  
  tokenizeFromList: (name, list) ->
    ret = 0
    for entry in list
      ret = @tokenizeFromWord(name, entry)
      break if ret > 0
    ret
  
  keywordToken: ->
    @tokenizeFromWord('SELECT') or
    @tokenizeFromWord('FROM') or
    @tokenizeFromWord('WHERE') or
    @tokenizeFromWord('GROUP') or
    @tokenizeFromWord('ORDER') or
    @tokenizeFromWord('BY') or
    @tokenizeFromWord('HAVING') or
    @tokenizeFromWord('AS')
  operatorToken:    -> @tokenizeFromList('OPERATOR', SQL_OPERATORS)  
  conditionalToken: -> @tokenizeFromList('CONDITIONAL', SQL_CONDITIONALS)
  functionToken:    -> @tokenizeFromList('FUNCTION', SQL_FUNCTIONS)
  sortOrderToken:   -> @tokenizeFromList('DIRECTION', SQL_SORT_ORDERS)
  
  starToken:        -> @tokenizeFromRegex('STAR', STAR)
  seperatorToken:   -> @tokenizeFromRegex('SEPARATOR', SEPARATOR)
  # whitespaceToken:  -> @tokenizeFromRegex('WHITESPACE', WHITESPACE, 0, 0, @preserveWhitespace)
  literalToken:     -> @tokenizeFromRegex('LITERAL', LITERAL, 1, 0)
  numberToken:      -> @tokenizeFromRegex('NUMBER', NUMBER)
  stringToken:      -> @tokenizeFromRegex('STRING', STRING, 1, 0)
  parensToken:      -> 
    @tokenizeFromRegex('LEFT_PAREN', /^\(/,) or 
    @tokenizeFromRegex('RIGHT_PAREN', /^\)/,)
  
  whitespaceToken: ->
    return 0 unless match = WHITESPACE.exec(@chunk)
    partMatch = match[0]
    newlines = partMatch.replace(/[^\n]/, '').length
    @currentLine += newlines
    @token(name, partMatch) if @preserveWhitespace
    return partMatch.length
  
  
  SQL_KEYWORDS        = ['SELECT', 'FROM', 'WHERE', 'GROUP BY', 'ORDER BY', 'HAVING', 'AS']
  SQL_FUNCTIONS       = ['COUNT', 'MIN', 'MAX']
  SQL_SORT_ORDERS     = ['ASC', 'DESC']
  SQL_OPERATORS       = ['=', '>', '<']
  SQL_CONDITIONALS    = ['AND']
  STAR                = /^\*/
  SEPARATOR           = /^,/
  WHITESPACE          = /^[ \n\r]+/
  LITERAL             = /^`?([a-z_][a-z0-9_]{0,})`?/i
  NUMBER              = /^[0-9]+/
  STRING              = /^'(.*?)'/
  
  
  
exports.tokenize = (sql, opts) -> (new Lexer(sql, opts)).tokens

