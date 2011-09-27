
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
    o "SelectQuery"
  ]
  
  SelectQuery: [
    o 'Select'
    o 'Select OrderClause',                           -> $1.order = $2; $1
    o 'Select GroupClause',                           -> $1.group = $2; $1
    o 'Select GroupClause OrderClause',               -> $1.group = $2; $1.order = $3; $1
  ]
  
  Select: [
    o 'SelectClause'
    o 'SelectClause WhereClause',                     -> $1.where = $2; $1
  ]
  
  SelectClause: [
    o 'SELECT Fields FROM Literal',                       -> new Select($2, $4)
  ]
  
  WhereClause: [
    o 'WHERE Conditions',                                 -> new Where($2)
  ]
  
  # TODO: order by can take mulitple sorts and also the direction is optional
  OrderClause: [
    o 'ORDER BY Value DIRECTION',                         -> new Order($3, $4)
  ]
  
  GroupClause: [
    o 'GroupBasicClause'
    o 'GroupBasicClause HavingClause',                    -> $1.having = $2; $1
  ]
  
  GroupBasicClause: [
    o 'GROUP BY ArgumentList',                            -> new Group($3)
  ]
  
  HavingClause: [
    o 'HAVING Conditions',                                -> new Having($2)
  ]
  
  # TODO: Support nested conditionals, eg: a and (b or c)
  Conditions: [
    o 'Condition',                                        -> [$1]
    o 'Conditions CONDITIONAL Condition',                 -> [$1, $2, $3]
  ]
  
  Condition: [
    o 'Value OPERATOR Value',                             -> new Condition($2, $1, $3)
  ]
  
  Value: [
    o 'Literal'
    o 'NUMBER',                                           -> new NumberValue($1)
    o 'STRING',                                           -> new StringValue($1)
    o 'Function'
  ]
  
  Literal: [
    o 'LITERAL',                                          -> new LiteralValue($1)
  ]
  
  Function: [
    o "FUNCTION LEFT_PAREN ArgumentList RIGHT_PAREN",     -> "#{$1}(#{$3})"
  ]
  
  ArgumentList: [
    o 'Value',                                            -> [$1]
    o 'ArgumentList SEPARATOR Value',                     -> $1.concat($3)
  ]
  
  Fields: [
    o 'Field',                                            -> [$1]
    o 'Fields SEPARATOR Field',                           -> $1.concat($3)
  ]
  
  Field: [
    o 'STAR'
    o 'Value',                                            -> new Field($1)
    o 'Value AS LITERAL',                                 -> new Field($1, $3)
  ]

tokens = []
operators = []

for name, alternatives of grammar
  grammar[name] = for alt in alternatives
    for token in alt[0].split ' '
      tokens.push token unless grammar[token]
    alt[1] = "return #{alt[1]}" if name is 'Root'
    alt

exports.grammar = grammar
exports.tokens = tokens
exports.operators = operators.reverse()