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
  path_options: {
      type: "decision_tree"
      module: "schema_path_options"
      }
  }

PapiClient::endpoints = {
  adpage_pieces: {
      type: "decision_tree"
      get: "get_adpage_pieces"
      }
  users: {
      title: "Users"
      type: "user"
      get: "get_users"
      }
  user: {
      title: "User"
      type: "user"
      get: "get_user"
      save: "save_user"
      }
  ad: {
      title: "Ad"
      type: "ad"
      get: "get_ad"
      save: "save_ad"
      }
  decision_tree: {
      title: "Decision Tree"
      type: "decision_tree"
      get: "get_decision_tree"
      save: "save_decision_tree"
      }
  decision_trees: {
      title: "Decision Trees"
      type: "decision_tree"
      get: "get_decision_trees"
      }
  feed: {
      title: "Feed"
      type: "ad"
      get: "get_feed"
      save: "save_feed"
      }
  feeds: {
      title: "Feeds"
      type: "ad"
      get: "get_feeds"
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
      save: "save_account"
      }
  address: {
      title: "Address"
      type: "account"
      get: "get_address"
      save: "save_address"
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
PapiClient::formify = (attrs, input, value, class_name) ->
  return @formification.init(attrs, input, value, class_name)

PapiClient::printForm = require './print_form.coffee'

PapiClient::listModal = require './modal.coffee'
