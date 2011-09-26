child_process = require('child_process')

task 'spec', 'Run All Specs', (options) ->
  child_process.spawn(
    'node_modules/jasmine-node/bin/jasmine-node',
    ['--coffee', 'spec'],
    customFds: [process.stdin, process.stdout, process.stderr]
  )