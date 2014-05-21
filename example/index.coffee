
PapiClient = require '../lib/index.coffee'
pc = new PapiClient baseUrl:'/example/accounts'

pc.getAccounts {}, (err, accounts) ->
  console.log accounts
