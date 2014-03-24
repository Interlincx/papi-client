gj = require 'get-json-hq'
pj = require './post-json.coffee' #this is a custom post-json that adds in teh port handling
schemas = require './schemas.json'
endpoints = require './endpoints.json'


module.exports = PapiClient = (opts={}) ->

  @baseUrl = opts.baseUrl or 'http://tyler.thankyoupath.com/papi/'
  #@baseUrl = opts.baseUrl or 'http://production.lincx.co/'
  #@script_options = @populateScriptOptions()
  @schemas = schemas
  @endpoints = endpoints
  return this


PapiClient::getUrl = (endpoint, opts={}) ->
  url = ''
  if endpoint.type
    url = @baseUrl+'?key=45c71a73-e335-4eb0-bce7-31da3cd558b1&t='+endpoint.type+'&m='+endpoint.module
  else
    url = @baseUrl+'?key=45c71a73-e335-4eb0-bce7-31da3cd558b1&e='+endpoint
  for handle, val of opts
    if typeof val == 'object'
      val = JSON.stringify(val)
    url += '&'+handle+'='+val
  return url


PapiClient::deleteProduct = (hive, product_id, cb) ->
  for product, i in hive.products
    if product.hive_product_id == product_id
      hive.products.splice( i, 1 )
      hive_id = hive.hive_id
      break

  @save( 'hive', hive, cb )

PapiClient::archives = (what, opts, cb) ->
  endpoint = @endpoints[what]
  pieces = {type:endpoint.type, module:endpoint.archives}

  url = @getUrl( pieces, opts )
  _this = this
  gj url, (err, result) ->
    _this.checkForError( err, result, cb )

PapiClient::delete = (what, opts, cb) ->
  endpoint = @endpoints[what]
  pieces = {type:endpoint.type, module:endpoint.delete}

  url = @getUrl( pieces, opts )
  _this = this
  gj url, (err, result) ->
    _this.checkForError( err, result, cb )

PapiClient::get = (what, opts, cb) ->
  post_data = JSON.stringify opts
  _this = this

  endpoint = @endpoints[what]
  pieces = {type:endpoint.type, module:endpoint.get}

  url = @getUrl( pieces )
  console.log url
  pj url, opts, (err, result) ->
    _this.checkForError( err, result, cb )
    #body = JSON.parse(result.body)
    #_this.checkForError( err, body, cb )

  return url



PapiClient::checkForError = (err, result, cb) ->
  body = result.body
  if err?
    console.log "Error"
    console.log err
    cb( err, body )
  if typeof body == 'undefined'
    err = @buildError( 'Uncaught Papi Error' )
  else
    try
      body = JSON.parse(body)
      if body.success is false
        err = @buildError( body.message )
      else if body.result is 'error'
        err = @buildError( body.message_collective )
    catch error
      err = @buildError( body )

  cb( err, body )

PapiClient::save = (what, opts, cb) ->
  post_data = JSON.stringify opts
  _this = this

  endpoint = @endpoints[what]
  pieces = {type:endpoint.type, module:endpoint.save}

  url = @getUrl( pieces )
  pj url, opts, (err, result) ->
    _this.checkForError( err, result, cb )

  return url


PapiClient::buildError = (msg) ->
  m = ''
  if msg?
    if typeof msg[0] != 'undefined' and typeof msg != 'string'
      console.log msg.join("\n")
      for item in msg
        m += "\n"+item
    else
      m = msg
  return new Error(m)

PapiClient::getCreativeTypes = (index, index_value) ->
  result = []
  for handle, item of @schemas.creative_pieces
    if item[index] == index_value
      result.push item
  return result

PapiClient::getTableColumns = (table_name, additional) ->
  columns = []
  for hand, att of @schemas.tables[table_name].fields
    if typeof att.client_visible == 'undefined' or att.client_visible
      c =
        property: hand
        title: att.title
      columns.push c

      for add in additional
        if add.property is hand
          for p, v of add
            c[p] = v

  for add in additional
    found = false
    for hand, att of @schemas.tables[table_name].fields
      if add.property is hand
        found = true
    if !found
      columns.push add
  return columns



PapiClient::listModal = require './modal.coffee'
