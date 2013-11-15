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
  }

PapiClient::endpoints = {
  gateways: {
      type: "gateway"
      get: "get_gateways"
      }
  gateway: {
      type: "gateway"
      get: "get_gateway"
      save: "save_gateway"
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


PapiClient::get = (what, opts, cb) ->
  endpoint = @endpoints[what]
  pieces = {type:endpoint.type, module:endpoint.get}
  url = @getUrl( pieces, opts )
  gj url, cb

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



###
PapiClient::writeFileNow = () ->
  fs.writeFile "asdf", "Hey there!", (err) ->
    if err
      console.log err
    else
      console.log "The file was saved!"
###

PapiClient::formify = require './formify.coffee'

