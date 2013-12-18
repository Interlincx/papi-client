test = require 'tape'

PapiClient = require '..'
pc = new PapiClient


testset = []

test "get", (t) ->
  for handle, data of pc.endpoints
    if data.get
      testset.push handle
  t.plan testset.length

  testEndpoint(t)


testEndpoint = (t) ->
  if testset.length > 0
    item = testset.pop()
    url = pc.get item, {}, ( err, result ) ->
      if typeof result == 'undefined'
        t.fail('Request for endpoint returned undefined')
      else if typeof result.result != 'undefined' and result.result == 'error'
        fail_msg = ''
        for msg in result.message_collective
          console.log msg
        t.fail('caught api error')
      else
        if typeof result.length == 'undefined'
          for handle, value of result
            t.ok(result, 'attribute - '+handle+': '+value)
            break
        else
          t.ok(result, 'result length: '+result.length)
      testEndpoint(t)
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

