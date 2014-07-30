

hq = require 'hyperquest'
url = require 'url'

module.exports = (target_url, data, cb) ->
  body = undefined
  buffer = undefined
  opts = undefined
  ws = undefined
  body = JSON.stringify(data)
  opts = headers:
    "Content-Type": "application/json"
    "Content-Length": body.length

  if window? and target_url.indexOf 'http' != 0
    cur = url.parse(target_url)
    cur.port = window.location.port
    cur.hostname = window.location.hostname
    cur.protocol = window.location.protocol
    target_url = url.format(cur)

  ws = hq.put(target_url, opts)
  ws.end body
  buffer = ""
  ws.on "data", (chunk) ->
    buffer += chunk

  ws.on "error", (err) ->
    cb err

  ws.on "end", ->
    res = undefined
    res = ws.response
    res.body = buffer
    cb null, res

