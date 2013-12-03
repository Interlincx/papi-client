test = require 'tape'

PapiClient = require '..'
pc = new PapiClient



test "get", (t) ->
  testset = []
  for handle, data of pc.endpoints
    if data.get
      testset.push handle
  t.plan testset.length

  for item in testset
    url = pc.get item, {}, ( err, result ) ->
      if typeof result == 'undefined'
        t.fail('Request for endpoint returned undefined')
      else if typeof result.result != 'undefined' and result.result == 'error'
        t.fail(result.message)
      else
        t.pass('result: '+result.length)
    console.log "testing url: ", url

###
test "schemas", (t) ->
  testset = []
  schemas = pc.getSchemaUrls()
  for url in schemas
    gj url, resultCheck

resultCheck = (err, result) ->
  if result.result == 'error'
    test.fail(result.message)
  else
    test.pass(item+': '+result.length)
###

