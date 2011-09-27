exports.Select = class Select
    constructor: (@fields, @source) -> 
      @order = null
      @group = null
      @where = null
      @limit = null
    toString: ->
      ret = ["SELECT #{@fields.join(', ')}"] 
      ret.push "FROM #{@source}"
      ret.push @where.toString() if @where
      ret.push @group.toString() if @group
      ret.push @order.toString() if @order
      ret.push @limit.toString() if @limit
      ret.join("\n  ")

exports.LiteralValue = class LiteralValue
  constructor: (@value) -> null
  toString: -> "`#{@value}`"

exports.StringValue = class StringValue
  constructor: (@value) -> null
  toString: -> "'#{@value}'"

exports.NumberValue = class LiteralValue
  constructor: (value) -> @value = Number(value)
  toString: -> @value.toString()

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
  constructor: (@values) ->
    @having = null
  toString: -> 
    ret = ["GROUP BY #{@values.join(', ')}"]
    ret.push @having.toString() if @having
    ret.join("\n  ")

exports.Where = class Where
  constructor: (@conditions) -> null
  toString: -> "WHERE #{@conditions.join(' ')}"

exports.Having = class Having
  constructor: (@conditions) -> null
  toString: -> "HAVING #{@conditions.join(' ')}"

exports.Condition = class Condition
  constructor: (@comparitor, @left, @right) -> null
  toString: -> "#{@left} #{@comparitor} #{@right}"

exports.Field = class Field
  constructor: (@field, @name=null) -> null
  toString: -> if @name then "#{@field} AS #{@name}" else @field
      