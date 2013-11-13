test = require 'tape'

PapiClient = require '..'
pc = new PapiClient

test "getAccounts", (t) ->
  t.plan 1
  pc.getAccounts {}, (err, accounts) ->
    t.ok accounts[0]
