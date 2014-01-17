test = require 'tape'

PapiClient = require '..'
pc = new PapiClient baseUrl:'http://production.lincx.co/'
pc.message_type = 'json'


testset = []


sample_ids =
  creative_instance:
    expect: 'object'
    get: [
      {instance_id: 'e35481f8-98a9-43b8-8040-ff97e1277e38'}
      {creative_template: 'classic_adpage'}
    ]
  creatives:
    get: [
      {piece_handle: 'buttons'}
    ]
  creative_template:
    expect: 'string'
    get: [
      {creative_template: 'classic_adpage'}
      {sub_template: 'classic_textad'}
    ]
  gateways:
    get: [
      {account_id: 'C-DNXL'}
    ]
  account:
    get: [
      {account_id: 'C-DNXL'}
    ]
  address:
    get: [
      {address_id: '0285a6b8-11ca-4bb1-93fc-80656303330b'}
    ]
  user:
    get: [
      {user_id: 'U-UQQ6'}
    ]
  ad:
    get: [
      {ad_id: '626d8bfd-a009-410c-a06f-c9fa1957947f'}
    ]
  feed:
    get: [
      {feed_id: '34e1a482-6581-427b-b0c4-dab0b6318f74'}
    ]
  feed:
    get: [
      {feed_id: '34e1a482-6581-427b-b0c4-dab0b6318f74'}
    ]
  creative:
    get: [
      {creative_id: 'dbc9f6d1-e56d-4998-8808-92c380dbf74a'}
      {creative_id: '95629a93-61b4-4a8f-afcf-c8063e443eb9'}
    ]

item = ''

test "get", (t) ->
  for handle, data of pc.endpoints
    if data.get
      testset.push handle
  t.plan testset.length

  testEndpoint(t)

getParams = (item) ->
  params = {}
  if typeof sample_ids[item] != 'undefined' and typeof sample_ids[item].get != 'undefined' and sample_ids[item].get.length > 0
    params = sample_ids[item].get.pop()
  return params


getNext = () ->
  if testset.length > 0
    item = testset.pop()
  else
    return false
  params = getParams(item)
  return {item:item, params:params}

testEndpoint = (t) ->
  if cur = getNext()
    {item,params} = cur
    console.log "\n"
    console.log "----Start-----------------"
    console.log "------"+item+"----------"
    console.log "passing params: ", params
    url = pc.get item, params, ( err, result ) ->
      if typeof result == 'undefined'
        console.log "\n\nOMG\n\n"
        t.fail("\nRequest for endpoint returned undefined")
      else if typeof result.result != 'undefined' and result.result == 'error'
        console.log "\n\nOMG\n\n"
        fail_msg = ''
        for msg in result.message_collective
          console.log msg
        t.fail("\ncaught api error")
      else
        obj_item = "Unknown result type\n"
        if result instanceof Array
          type = "ARRAY"
          obj_item = "length: "+result.length
        else if typeof result == 'object'
          type = "OBJECT"
          for handle, value of result
            obj_item = "attribute - "+handle+': '+value
            break
        else if typeof result == 'string' || typeof result.length == 'undefined'
          type = "STRING?"
          obj_item = "String returned - possible error\n"
        console.log "RESULT\ntype: "+type
        console.log obj_item
        console.log "\n"
        t.ok(result, " - endpoint: "+item)
      console.log "------"+item+"----------"
      console.log "----Done-----------------"
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

