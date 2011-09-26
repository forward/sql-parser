SQL Parser
==========

SQL Parser is a lexer, grammar and parser for SQL written in JS. Currently it is only capable of parsing faily basic SELECT queries but full SQL support will hopefully come in time. See the specs for examples of currently supported queries.

Lexer
-----

The lexer takes a SQL query string as input and returns a stream of tokens in the format 

    ['NAME', 'value', lineNumber]

Here is a simple example...

    lexer.tokenize('select * from my_table')
    
    [
      ['SELECT','select',1], 
      ['STAR','*',1], 
      ['FROM','from',1], 
      ['LITERAL','my_table',1]
    ]

The tokenized output is in a format compatible with JISON.


Parser
------

The parser is currently very silly and just reproduces the input stream, more coming soon.