express     = require 'express'
body_parser = require 'body-parser'
google      = require 'googleapis'
colors      = require 'colors'

module.exports = (config) ->

  app = express()
  app.use body_parser.json()

  address = (address, port, path) ->
    if address is '0.0.0.0' then address = 'localhost'
    addr = "http://#{address}:#{port}/"
    if path then addr += path
    addr

  scope = config.scope.split /,\s*/
  scope[index] = "https://www.googleapis.com/auth/#{scope[index]}" for sc, index in scope

  console.log()

  server = app.listen config.port, ->
    addr = server.address()
    console.log "! ".bold.green + "Visit ".bold.white + "#{address(addr.address, addr.port)}".white
    console.log "! ".bold.green + "Be sure to set your Google app's callback URL to " + address(addr.address, addr.port, 'callback').green

    client  = new google.auth.OAuth2 config.client_id, config.client_secret, address(addr.address, addr.port, 'callback')

    app.get '/', (req, res) ->
      redirect_url = client.generateAuthUrl access_type: config.access_type, scope: scope
      res.redirect redirect_url

    app.get '/callback', (req, res) ->
      code = req.query.code
      client.getToken code, (err, tokens) -> res.json tokens
