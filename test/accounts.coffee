test = require 'tape'

papiClient = require '..'


test "getAccounts", (t) ->
  t.plan 1
  papiClient.getAccounts {}, (err, accounts) ->
    t.ok accounts[0]
