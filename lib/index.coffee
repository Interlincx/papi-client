gj = require 'get-json-hq'
schemas = require './schemas.json'
endpoints = require './endpoints.json'


module.exports = PapiClient = (opts={}) ->
  @baseUrl = opts.baseUrl or 'http://tyler.thankyoupath.com/papi/'
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
    url += '&'+handle+'='+val
  return url


PapiClient::deleteProduct = (hive, product_id, cb) ->
  for product, i in hive.products
    if product.hive_product_id == product_id
      hive.products.splice( i, 1 )
      hive_id = hive.hive_id
      break

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
  if params.type is 'creative_instance'
    what = 'creative_instances'
    item_label = 'creative_instance_name'
    item_id_handle = 'creative_instance_id'
    title = 'Pick a Creative Instance'
  if params.type is 'decision_tree'
    what = 'decision_trees'
    item_label = 'decision_tree_name'
    item_id_handle = 'decision_tree_id'
    title = 'Pick a Decision Tree'
  if params.type is 'ad_feed'
    what = 'feeds'
    item_label = 'feed_title'
    item_id_handle = 'ad_feed_id'
    title = 'Pick a Feed'
  if params.type is 'ad'
    what = 'ads'
    item_label = 'ad_name'
    item_id_handle = 'ad_id'
    title = 'Pick an Ad'

  options =
    item_label: item_label
    item_id_handle: item_id_handle
    selected_id: params.selected_id
    title: title
    original_event: e

  _this = @
  @listModal.createModal options, (err) ->
    _this.get what, pass, (err, results) ->
      _this.listModal.populateModal(results, callback, params, e)




PapiClient::formification = require './formify.coffee'
PapiClient::formify = (attrs, input, value, class_name) ->
  return @formification.init(attrs, input, value, class_name)

PapiClient::printForm = require './print_form.coffee'

PapiClient::listModal = require './modal.coffee'
