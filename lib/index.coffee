gj = require 'get-json-hq'
schemas = require './schemas.json'


module.exports = PapiClient = (opts={}) ->
  @baseUrl = opts.baseUrl or 'http://tyler.thankyoupath.com/papi/'
  @script_options = @populateScriptOptions()
  @schemas = schemas
  return this

PapiClient::semiStaticSchemas = {
  creative_templates: {
      type: "creative"
      module: "get_templates"
      }
  script_info: {
      type: "pipeline"
      module: "get_script_info"
      }
  swarm_settings: {
      type: "swarm"
      module: "get_swarm_settings"
      }
  tables: {
      type: "utils"
      module: "get_schemas"
      }
  }

PapiClient::endpoints = {
  accounts: {
      title: "Accounts"
      type: "account"
      get: "get_accounts"
      }
  account: {
      title: "Account"
      type: "account"
      get: "get_account"
      }
  gateways: {
      title: "Gateways"
      type: "gateway"
      get: "get_gateways"
      }
  gateway: {
      title: "Gateway"
      type: "gateway"
      get: "get_gateway"
      save: "save_gateway"
      delete: "delete_gateway"
      }
  hive: {
      title: "Hive"
      type: "hive"
      get: "get_hives"
      save: "save_hive"
      }
  product: {
      title: "Pipeline"
      type: "pipeline"
      save: "save_new_product"
      delete: "delete_product"
      }
  }

PapiClient::getSchemaUrls = ->
  result = {}
  for handle, data of @semiStaticSchemas
    result[handle] = @getUrl data
  return result


PapiClient::getUrl = (endpoint, opts={}) ->
  url = ''
  if endpoint.type
    url = @baseUrl+'?t='+endpoint.type+'&m='+endpoint.module
  else
    url = @baseUrl+'?e='+endpoint
  for handle, val of opts
    url += '&'+handle+'='+val
  return url


PapiClient::deleteProduct = (hive, product_id, cb) ->
  i = 0
  for product in hive.products
    if product.hive_product_id == product_id
      hive.products.splice( i, 1 )
      hive_id = hive.hive_id
      break
    i++

  @save( 'hive', hive, cb )

PapiClient::delete = (what, opts, cb) ->
  endpoint = @endpoints[what]
  pieces = {type:endpoint.type, module:endpoint.delete}

  url = @getUrl( pieces, opts )
  gj url, cb

PapiClient::get = (what, opts, cb) ->
  endpoint = @endpoints[what]
  pieces = {type:endpoint.type, module:endpoint.get}

  url = @getUrl( pieces, opts )
  gj url, cb


PapiClient::isSubTable = (table) ->
  if typeof @schemas.tables[table] != 'undefined'
    return true
  return false

PapiClient::schemify = (what, obj) ->
  result = []
  if typeof obj[0] != 'undefined'
    for row in obj
      result.push( @schemify(what, row) )
  else
    for handle, value of obj
      type = typeof value
      if type == 'string' or type == 'number' or type == 'boolean'
        if typeof @schemas.tables[what].fields[handle] != 'undefined'
          result[handle] = @schemas.tables[what].fields[handle]
          result[handle].value = value
        else
          result[handle] =
            value: value
      else if @isSubTable handle
        result[handle] = @schemify handle, value
  return result

#REMOVE THIS
PapiClient::getAccounts = (opts, cb) ->
  url = @getUrl {type:'account', module:'get_accounts'}
  gj url, cb


PapiClient::save = (what, obj, cb) ->
  console.log "@toJSON(): ", obj
  post_data = JSON.stringify obj
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
    success: (data, textStatus, jqXHR) ->
      console.log "success data: ", data
      if data.success is false
        _this.saveError()
      else
        $.gritter.add
          title: 'Notice'
          text: 'Saved Successfully!'
          time: 3000
        cb( data )

    error: (err) ->
      _this.saveError()

  $.ajax options

PapiClient::saveError = ->
  $.gritter.add
    title: 'Notice'
    text: 'Save Failed!!!!'
    time: 3000


PapiClient::populateScriptOptions = ->
  script_options = []
  pipeline_data =
    title: "Pipeline"
    options: []

  for version, data of schemas.script_info.script_versions
    tmp =
      title: data['title']
      handle: version
    pipeline_data.options.push tmp
  script_options.push pipeline_data

  return script_options


PapiClient::formify = require './formify.coffee'

