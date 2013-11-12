assert = require 'assert'

papiClient = require '..'

assert.ok papiClient

papiClient.getAccounts {}, (err, accounts) ->
  assert.ok accounts[0]
  console.log accounts[0]
