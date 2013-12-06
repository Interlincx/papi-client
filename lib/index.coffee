gj = require 'get-json-hq'
schemas = require './schemas.json'


module.exports = PapiClient = (opts={}) ->
  @baseUrl = opts.baseUrl or 'http://tyler.thankyoupath.com/papi/'
  #@script_options = @populateScriptOptions()
  @schemas = schemas
  return this

PapiClient::semiStaticSchemas = {
  tags: {
      type: "tag"
      module: "get_tags"
      }
  creative_sub_templates: {
      type: "creative"
      module: "schema_sub_templates"
      }
  ad_templates: {
      type: "ad"
      module: "schema_templates"
      }
  creative_templates: {
      type: "creative"
      module: "schema_templates"
      }
  creative_pieces: {
      type: "creative"
      module: "schema_pieces"
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
  ad: {
      title: "Ad"
      type: "ad"
      get: "get_ad"
      save: "save_ad"
      }
  ads: {
      title: "Ads"
      type: "ad"
      get: "get_ads"
      }
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
  creative: {
      title: "Creative"
      type: "creative"
      get: "get_creative"
      save: "save_creative"
      delete: "delete_creative"
      }
  creatives: {
      title: "Creatives"
      type: "creative"
      get: "get_creatives_detail"
      }
  creative_instances: {
      title: "Creative Instances"
      type: "creative"
      get: "get_instances"
      }
  creative_instance: {
      title: "Creative Instance"
      type: "creative"
      get: "get_instance"
      save: "save_instance"
      }
  gateway: {
      title: "Gateway"
      type: "gateway"
      #get: "get_gateway"
      save: "save_gateway"
      delete: "delete_gateway"
      }
  hive: {
      title: "Hive"
      type: "hive"
      #get: "get_hives"
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

  return url


PapiClient::isSubTable = (table) ->
  if typeof @schemas.tables[table] != 'undefined'
    return true
  return false

PapiClient::copyObj = (obj) ->
  return JSON.parse(JSON.stringify(obj))

PapiClient::schemify = (what, obj) ->
  if typeof obj[0] != 'undefined'
    result = []
    for row in obj
      result.push( @schemify(what, row) )
  else
    result = {}
    switch what
      when 'ad_creative'
        result = @schemifyAdCreative( obj )
      when 'ad_tag'
        result = @schemifyAdTags( obj )
      else
        for handle, value of obj
          type = typeof value
          if type == 'string' or type == 'number' or type == 'boolean' or value == null
            if typeof @schemas.tables[what].fields[handle] != 'undefined'
              result[handle] = @copyObj(@schemas.tables[what].fields[handle])
              result[handle].value = value
            else
              result[handle] =
                value: value
          else if @isSubTable handle
            result[handle] = @schemify handle, value
  return result
  
PapiClient::unschemify = (what, obj) ->
  result = []
  if typeof obj[0] != 'undefined'
    for row in obj
      result.push( @unschemify(what, row) )
  else
    for handle, data of obj
      if typeof data.value != 'undefined'
        result[handle] = data.value
      else if @isSubTable handle
        result[handle] = @unschemify handle, data
  return result

PapiClient::schemifyAdTags = (obj) ->
  result = @copyObj( @schemas.tags )
  for data in obj
    for item in result
      if data.tag_id == item.tag_id
        item.selected = true
  console.log 'TAGS', result
  return result

PapiClient::schemifyAdCreative = (obj) ->
  result = @copyObj( @schemas.ad_templates )
  for handle, data of result
    for name, schema of data.pieces
      if typeof obj[handle][name] != 'undefined'
        schema.value = obj[handle][name]
  return result


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
    success: (data, textStatus, jqXHR) ->
      console.log "success data: ", data
      if data.success is false
        _this.saveError()
      else if data.result is 'error'
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

PapiClient::getCreativeTypes = (index, index_value) ->
  result = []
  for handle, item of @schemas.creative_pieces
    if item[index] == index_value
      result.push item
  return result


PapiClient::adpagePieceSelect = (callback, params, e) ->
  if typeof params.selected_id == 'undefined'
    params.selected_id = ''
  pass = {}

  if params.type is 'account'
    what = 'accounts'
    item_label = 'company_name'
    item_id_handle = 'account_id'
    title = 'Pick an Account'


  options =
    item_label: item_label
    item_id_handle: item_id_handle
    selected_id: params.selected_id
    title: title

  _this = @
  @listModal.createModal options, (err) ->
    _this.get what, pass, (err, results) ->
      _this.listModal.populateModal(results, callback, params, e)



###
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
###


PapiClient::formification = require './formify.coffee'
PapiClient::formify = (attrs, input) ->
  return @formification.init(attrs, input)

PapiClient::printForm = require './print_form.coffee'

PapiClient::listModal = require './modal.coffee'
