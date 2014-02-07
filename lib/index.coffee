gj = require 'get-json-hq'
pj = require './post-json'
schemas = require './schemas.json'
endpoints = require './endpoints.json'


module.exports = PapiClient = (opts={}) ->
  @message_type = 'display'
  #@message_type = 'json'

  #@baseUrl = opts.baseUrl or 'http://tyler.thankyoupath.com/papi/'
  @baseUrl = opts.baseUrl or 'http://production.lincx.co/'
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

  ###
  url = @getUrl( pieces, opts )
  gj url, (err, result) ->
    _this.checkForError( err, result, cb )
  ###
  url = @getUrl( pieces )
  console.log url
  pj url, opts, (err, result) ->
    body = JSON.parse(result.body)
    _this.checkForError( err, body, cb )

  return url


PapiClient::ajax = (options) ->
  if window? and window.XMLHttpRequest
    req = new XMLHttpRequest()
  else
    # IE6, IE5
    req = new ActiveXObject("Microsoft.XMLHTTP")

  sendData = {}
  if options.data?
    sendData = options.data

  req.onreadystatechange = ->
    if req.readyState == 4 && req.status == 200
      if options.success?
        console.log "REQ", req
        options.success(req.response, req.statusText)
    ###
    else
      if options.error?
        options.error(req.statusText)
    ###

  contentType = 'application/x-www-form-urlencoded'
  if options.contentType?
    contentType = options.contentType

  type = 'POST'
  if options.type?
    type = options.type

  req.open(type, options.url, true)
  req.setRequestHeader("Content-type", contentType)
  req.responseType = 'json'
  if options.data?
    req.send(options.data)
  else
    req.send()


PapiClient::checkForError = (err, result, cb) ->
  if @message_type == 'display'
    if typeof result == 'undefined'
      return @showError( 'Uncaught Papi Error' )
    else if result.success is false
      return @showError( result.message )
    else if result.result is 'error'
      return @showError( result.message_collective )
  cb( err, result )

PapiClient::save = (what, obj, cb) ->
  console.log "json stringify: ", obj
  post_data = JSON.stringify obj
  console.log 'POST', post_data
  _this = this

  endpoint = @endpoints[what]
  pieces = {type:endpoint.type, module:endpoint.save}
  url = @getUrl( pieces )
  options =
    type: 'POST'
    contentType: 'application/json'
    processData: false
    url: url
    data: post_data
    success: (data, textStatus) ->
      console.log "success data: ", data
      if data.success is false
        _this.showError( data.message_collective )
      else if data.result is 'error'
        _this.showError( data.message_collective )
      else
        if _this.message_type == 'display'
          console.log 'Successful Save!'
        cb( data )

    error: (err) ->
      return _this.showError(err)

  @ajax options

PapiClient::showError = (msg) ->
  m = ''
  if msg?
    if typeof msg[0] != 'undefined' and typeof msg != 'string'
      console.log msg.join("\n")
      for item in msg
        m += "\n"+item
    else
      m = msg

  if @message_type == 'display'
    console.log 'Papi Error!! '+m
  else
    return {result:'error',message:m}

PapiClient::getCreativeTypes = (index, index_value) ->
  result = []
  for handle, item of @schemas.creative_pieces
    if item[index] == index_value
      result.push item
  return result


PapiClient::listModal = require './modal.coffee'
