
unwrap = /^function\s*\(\)\s*\{\s*return\s*([\s\S]*);\s*\}/

o = (patternString, action, options) ->
  patternString = patternString.replace /\s{2,}/g, ' '
  return [patternString, '$$ = $1;', options] unless action
  action = if match = unwrap.exec action then match[1] else "(#{action}())"
  action = action.replace /\bnew /g, '$&yy.'
  [patternString, "$$ = #{action};", options]

grammar = 

  Root: [
    o 'Query EOF'
  ]
  
  Query: [
    o "SelectWithLimitQuery"
    o "SelectQuery"
  ]
  
  SelectQuery: [
    o 'Select'
    o 'Select OrderClause',                               -> $1.order = $2; $1
    o 'Select GroupClause',                               -> $1.group = $2; $1
    o 'Select GroupClause OrderClause',                   -> $1.group = $2; $1.order = $3; $1
  ]
  
  SelectWithLimitQuery: [
    o 'SelectQuery LimitClause',                          -> $1.limit = $2; $1
  ]
  
  Select: [
    o 'SelectClause'
    o 'SelectClause WhereClause',                         -> $1.where = $2; $1
  ]
  
  SelectClause: [
    o 'SELECT Fields FROM Table',                         -> new Select($2, $4, false)
    o 'SELECT DISTINCT Fields FROM Table',                -> new Select($3, $5, true)
  ]
  
  Table: [
    o 'Literal',                                          -> new Table($1)
    o 'Literal WINDOW WINDOW_FUNCTION LEFT_PAREN Number RIGHT_PAREN',
                                                          -> new Table($1, $2, $3, $5)
  ]
  
  WhereClause: [
    o 'WHERE Expression',                                 -> new Where($2)
  ]
  
  LimitClause: [
    o 'LIMIT Number',                                     -> new Limit($2)
  ]
  
  OrderClause: [
    o 'ORDER BY OrderArgs',                               -> new Order($3)
  ]
  
  OrderArgs: [
    o 'OrderArg',                                         -> [$1]
    o 'OrderArgs SEPARATOR OrderArg',                     -> $1.concat($3)
  ]
  
  OrderArg: [
    o 'Value',                                            -> new OrderArgument($1, 'ASC')
    o 'Value DIRECTION',                                  -> new OrderArgument($1, $2)    
  ]
  
  GroupClause: [
    o 'GroupBasicClause'
    o 'GroupBasicClause HavingClause',                    -> $1.having = $2; $1
  ]
  
  GroupBasicClause: [
    o 'GROUP BY ArgumentList',                            -> new Group($3)
  ]
  
  HavingClause: [
    o 'HAVING Expression',                                -> new Having($2)
  ]
  
  
  Expression: [
    o 'LEFT_PAREN Expression RIGHT_PAREN',                -> $2
    o 'Expression MATH Expression',                       -> new Op($2, $1, $3)
    o 'Expression MATH_MULTI Expression',                 -> new Op($2, $1, $3)
    o 'Expression OPERATOR Expression',                   -> new Op($2, $1, $3)
    o 'Expression CONDITIONAL Expression',                -> new Op($2, $1, $3)
    o 'Value'
  ]
  
  Value: [
    o 'Literal'
    o 'Number'
    o 'String'
    o 'Function'
    o 'UserFunction'
    o 'Boolean'
  ]
  
  Number: [
    o 'NUMBER',                                           -> new NumberValue($1)
  ]
  
  Boolean: [
    o 'BOOLEAN',                                           -> new BooleanValue($1)
  ]
  
  String: [
    o 'STRING',                                           -> new StringValue($1)
  ]
  
  Literal: [
    o 'LITERAL',                                          -> new LiteralValue($1)
    o 'Literal DOT LITERAL',                              -> new LiteralValue($1, $3)
  ]
  
  Function: [
    o "FUNCTION LEFT_PAREN ArgumentList RIGHT_PAREN",     -> new FunctionValue($1, $3)
  ]

  UserFunction: [
    o "LITERAL LEFT_PAREN ArgumentList RIGHT_PAREN",     -> new FunctionValue($1, $3, true)
  ]
  
  ArgumentList: [
    o 'Expression',                                       -> [$1]
    o 'ArgumentList SEPARATOR Value',                     -> $1.concat($3)
  ]
  
  Fields: [
    o 'Field',                                            -> [$1]
    o 'Fields SEPARATOR Field',                           -> $1.concat($3)
  ]
  
  Field: [
    o 'STAR',                                             -> new Star()
    o 'Expression',                                       -> new Field($1)
    o 'Expression AS Literal',                            -> new Field($1, $3)
  ]

tokens = []
operators = [
  ['left', 'Op']
  ['left', 'MATH_MULTI']
  ['left', 'MATH']
  ['left', 'OPERATOR']
  ['left', 'CONDITIONAL']
]

for name, alternatives of grammar
  grammar[name] = for alt in alternatives
    for token in alt[0].split ' '
      tokens.push token unless grammar[token]
    alt[1] = "return #{alt[1]}" if name is 'Root'
    alt

exports.grammar = grammar
exports.tokens = tokens
exports.operators = operators.reverse()