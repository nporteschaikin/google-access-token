express     = require 'express'
body_parser = require 'body-parser'
google      = require 'googleapis'
inquirer    = require 'inquirer'
colors      = require 'colors'
argv        = require('minimist') process.argv.slice(2), alias: p: 'port'

inquirer.prompt [

  {
    type: 'input'
    name: 'client_id'
    message: 'Google client ID?'
  }

  {
    type: 'input'
    name: 'client_secret'
    message: 'Google client secret?'
  }

  {
    type: 'input'
    name: 'scope'
    message: 'Scope of permissions? (separated by commas)'
  }

  {
    type: 'list'
    name: 'access_type'
    message: 'Access type?'
    choices: ['online', 'offline']
  }

  {
    type: 'input'
    name: 'port'
    message: 'Port to run app on?'
    default: 3000
  }

], (answers) ->

  app = express()
  app.use body_parser.json()

  console.log()

  server = app.listen answers.port, ->
    addr = server.address()
    console.log "! ".bold.green + "Visit ".bold.white + "#{addr.address}:#{addr.port}!".white
    console.log "! ".bold.green + "Be sure to set your Google app's callback URL to " + "http://#{addr.address}:#{addr.port}/callback".green

    client  = new google.auth.OAuth2 answers.client_id, answers.client_secret, "http://#{addr.address}:#{addr.port}/callback"

    app.get '/', (req, res) ->
      redirect_url = client.generateAuthUrl access_type: answers.access_type, scope: answers.scope.split(/,\s*/)
      res.redirect redirect_url

    app.get '/callback', (req, res) ->
      code = req.query.code
      client.getToken code, (err, tokens) -> res.json tokens
