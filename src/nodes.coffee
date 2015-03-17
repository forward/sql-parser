indent = (str) ->
  ("  #{line}" for line in str.split("\n")).join("\n")

exports.Select = class Select
    constructor: (@fields, @source, @distinct=false, @joins=[], @unions=[]) ->
      @order = null
      @group = null
      @where = null
      @limit = null
    toString: ->
      ret = ["SELECT #{@fields.join(', ')}"]
      ret.push indent("FROM #{@source}")
      ret.push indent(join.toString()) for join in @joins
      ret.push indent(@where.toString()) if @where
      ret.push indent(@group.toString()) if @group
      ret.push indent(@order.toString()) if @order
      ret.push indent(@limit.toString()) if @limit
      ret.push union.toString() for union in @unions
      ret.join("\n")

exports.SubSelect = class SubSelect
  constructor: (@select, @name=null) -> null
  toString: ->
    ret = []
    ret.push '('
    ret.push indent(@select.toString())
    ret.push if @name then ") #{@name.toString()}" else ")"
    ret.join("\n")

exports.Join = class Join
  constructor: (@right, @conditions=null, @side=null, @mode=null) -> null
  toString: ->
    ret = ''
    ret += "#{@side} " if @side?
    ret += "#{@mode} " if @mode?
    ret + "JOIN #{@right}\n" + indent("ON #{@conditions}")

exports.Union = class Union
  constructor: (@query, @all=false) -> null
  toString: ->
    all = if @all then ' ALL' else ''
    "UNION#{all}\n#{@query.toString()}"

exports.LiteralValue = class LiteralValue
  constructor: (@value, @value2=null) ->
    if @value2
      @nested = true
      @values = @value.values
      @values.push(value2)
    else
      @nested = false
      @values = [@value]
  # TODO: Backtick quotes only supports MySQL, Postgres uses double-quotes
  toString: -> "`#{@values.join('.')}`"

exports.StringValue = class StringValue
  constructor: (@value, @quoteType="''") -> null
  toString: -> "#{@quoteType}#{@value}#{@quoteType}"

exports.NumberValue = class LiteralValue
  constructor: (value) -> @value = Number(value)
  toString: -> @value.toString()

exports.ListValue = class ListValue
  constructor: (value) -> @value = value
  toString: -> "(#{@value.join(', ')})"

exports.ParameterValue = class ParameterValue
  constructor: (value) ->
    @value = value
    @index = parseInt(value.substr(1), 10) - 1
  toString: -> "#{@value}"

exports.ArgumentListValue = class ArgumentListValue
  constructor: (@value, @distinct=false) -> null
  toString: ->
    if @distinct
      "DISTINCT #{@value.join(', ')}"
    else
      "#{@value.join(', ')}"

exports.BooleanValue = class LiteralValue
  constructor: (value) ->
    @value = switch value.toLowerCase()
      when 'true'
        true
      when 'false'
        false
      else
        null
  toString: -> if @value? then @value.toString().toUpperCase() else 'NULL'

exports.FunctionValue = class FunctionValue
  constructor: (@name, @arguments=null, @udf=false) -> null
  toString: ->
    if @arguments
      "#{@name.toUpperCase()}(#{@arguments.toString()})"
    else
      "#{@name.toUpperCase()}()"

exports.Order = class Order
  constructor: (@orderings, @offset) ->
  toString: -> "ORDER BY #{@orderings.join(', ')}" +
    (if @offset then "\n" + @offset.toString() else "")

exports.OrderArgument = class OrderArgument
  constructor: (@value, @direction='ASC') -> null
  toString: -> "#{@value} #{@direction}"

exports.Offset = class Offset
  constructor: (@row_count, @limit) -> null
  toString: -> "OFFSET #{@row_count} ROWS" +
    (if @limit then "\nFETCH NEXT #{@limit} ROWS ONLY" else "")

exports.Limit = class Limit
  constructor: (@value, @offset) -> null
  toString: -> "LIMIT #{@value}" + (if @offset then "\nOFFSET #{@offset}" else "")

exports.Table = class Table
  constructor: (@name, @alias=null, @win=null, @winFn=null, @winArg=null) -> null
  toString: ->
    if @win
      "#{@name}.#{@win}:#{@winFn}(#{@winArg})"
    else if @alias
      "#{@name} AS #{@alias}"
    else
      @name.toString()

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
  toString: -> "(#{@left} #{@operation.toUpperCase()} #{@right})"

exports.UnaryOp = class UnaryOp
  constructor: (@operator, @operand) -> null
  toString: -> "(#{@operator.toUpperCase()} #{@operand})"

exports.Field = class Field
  constructor: (@field, @name=null) -> null
  toString: -> if @name then "#{@field} AS #{@name}" else @field.toString()

exports.Star = class Star
  constructor: () -> null
  toString: -> '*'
  star: true
