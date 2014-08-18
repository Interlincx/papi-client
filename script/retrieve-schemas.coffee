async = require 'async'
gj = require 'get-json-hq'
fs = require 'fs'

schema_endpoints = require '../lib/schema_endpoints.json'

PapiClient = require '../lib/index.coffee'
pc = new PapiClient

schemas = {}
for handle, data of schema_endpoints
  schemas[handle] = pc.getUrl data


targetFile = __dirname+'/../lib/schemas.json'

urls = []
for handle, url of schemas
  console.log url
  urls.push url



async.mapSeries urls, gj, (err, result) ->
  #return console.error err if err
  final = {}
  i = 0
  for handle, url of schemas
    final[handle] = result[i]

    switch handle
      when 'script_info'
        pipeline_data =
          title: "Pipeline"
          options: []
      
        for version, data of result[i].script_versions
          tmp =
            title: data['title']
            handle: version
          pipeline_data.options.push tmp
        final['script_options'] = []
        final['script_options'].push pipeline_data
 
    i++
  fs.writeFileSync targetFile, (JSON.stringify final, null, 2)


