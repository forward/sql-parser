exports.Select = class Select
    constructor: (@fields, @source) -> 
      @order = null
      @group = null
    toString: ->
      ret = ["SELECT #{@fields.join(', ')}"] 
      ret.push "FROM #{@source}"
      ret.push @where.toString() if @where
      ret.push @group.toString() if @group
      ret.push @order.toString() if @order
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
  constructor: (@value, @direction='ASC') -> null
  toString: -> "ORDER BY #{@value} #{@direction}"

exports.Group = class Group
  constructor: (@values) -> null
  toString: -> "GROUP BY #{@values.join(', ')}"

exports.Where = class Where
  constructor: (@conditions) -> null
  toString: -> "WHERE #{@conditions.join(' ')}"

exports.Condition = class Condition
  constructor: (@comparitor, @left, @right) -> null
  toString: -> "#{@left} #{@comparitor} #{@right}"

exports.Field = class Field
  constructor: (@field, @name=null) -> null
  toString: -> if @name then "#{@field} AS #{@name}" else @field
      