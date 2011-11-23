child_process = require('child_process')

task 'spec', 'Run All Specs', (options) ->
  jasmine = child_process.spawn('node_modules/jasmine-node/bin/jasmine-node', ['--coffee', 'spec'])
  jasmine.stdout.pipe(process.stdout)
  jasmine.stderr.pipe(process.stderr)