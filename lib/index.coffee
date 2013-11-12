gj = require 'get-json-hq'

module.exports =
  getAccounts: (opts, cb) ->
    url = 'http://tyler.thankyoupath.com/papi/?t=account&m=get_accounts'
    gj url, cb
