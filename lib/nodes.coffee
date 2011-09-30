indent = (str) ->
  ("  #{line}" for line in str.split("\n")).join("\n")

exports.Select = class Select
    constructor: (@fields, @source) -> 
      @order = null
      @group = null
      @where = null
      @limit = null
    toString: ->
      ret = ["SELECT #{@fields.join(', ')}"] 
      ret.push indent("FROM #{@source}")
      ret.push indent(@where.toString()) if @where
      ret.push indent(@group.toString()) if @group
      ret.push indent(@order.toString()) if @order
      ret.push indent(@limit.toString()) if @limit
      ret.join("\n")

exports.LiteralValue = class LiteralValue
  constructor: (@value) -> null
  toString: -> "`#{@value}`"

exports.StringValue = class StringValue
  constructor: (@value) -> null
  toString: -> "'#{@value}'"

exports.NumberValue = class LiteralValue
  constructor: (value) -> @value = Number(value)
  toString: -> @value.toString()

exports.FunctionValue = class FunctionValue
  constructor: (@name, @arguments=[]) -> null
  toString: -> "#{@name}(#{@arguments.join(', ')})"

exports.Order = class Order
  constructor: (@orderings) ->
  toString: -> "ORDER BY #{@orderings.join(', ')}"

exports.OrderArgument = class OrderArgument
  constructor: (@value, @direction='ASC') -> null
  toString: -> "#{@value} #{@direction}"

exports.Limit = class Limit
  constructor: (@value) -> null
  toString: -> "LIMIT #{@value}"

exports.Group = class Group
  constructor: (@fields) ->
    @having = null
  toString: -> 
    ret = ["GROUP BY #{@fields.join(', ')}"]
    ret.push @having.toString() if @having
    ret.join("\n")

exports.Where = class Where
  constructor: (@conditions) -> null
  toString: -> "WHERE #{@conditions}"

exports.Having = class Having
  constructor: (@conditions) -> null
  toString: -> "HAVING #{@conditions}"

exports.Op = class Op
  constructor: (@operation, @left, @right) -> null
  toString: -> "(#{@left} #{@operation} #{@right})"

exports.Field = class Field
  constructor: (@field, @name=null) -> null
  toString: -> if @name then "#{@field} AS #{@name}" else @field.toString()

exports.Star = class Star
  constructor: () -> null
  toString: -> '*'
  star: true
      