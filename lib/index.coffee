gj = require 'get-json-hq'

module.exports = PapiClient = (opts={}) ->
  @baseUrl = opts.baseUrl or 'http://tyler.thankyoupath.com/papi/'
  return this

PapiClient::getAccounts = (opts, cb) ->
  url = @getUrl 'account', 'get_accounts'
  gj url, cb

PapiClient::getUrl = (type, module, opts={}) ->
  @baseUrl+'?t='+type+'&m='+module
