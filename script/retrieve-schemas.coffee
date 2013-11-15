async = require 'async'
gj = require 'get-json-hq'
fs = require 'fs'

PapiClient = require '../lib/index.coffee'
pc = new PapiClient

schemas = pc.getSchemaUrls()

targetFile = __dirname+'/../lib/schemas.json'

urls = []
for handle, url of schemas
  urls.push url

async.mapSeries urls, gj, (err, result) ->
  return console.error err if err
  console.log 'SCHAD', schemas.length
  final = {}
  i = 0
  for handle, url of schemas
    final[handle] = result[i]
    i++
  fs.writeFileSync targetFile, (JSON.stringify final, null, 2)
