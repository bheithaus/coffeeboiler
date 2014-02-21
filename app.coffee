express = require 'express'
events = require 'events'
http =  require 'http'
https = require 'https'
path = require 'path'
fs = require 'fs'
io = require 'socket.io'
utils = require 'lodash'
expressJwt = require 'express-jwt'
mongoose = require 'mongoose'
library = require './library'

GLOBAL.config = require './config'

# fake
privateKey  = fs.readFileSync 'sslcert/server.key', 'utf8'
certificate = fs.readFileSync 'sslcert/server.crt', 'utf8'
credentials = 
  key: privateKey
  cert: certificate

db = mongoose.connect config.db
app = express()

# helper
paths =
  bower:  express.static path.join(__dirname, '/bower_components')
  public: express.static path.join(__dirname, '/public')

#  all environments
app.set 'port', process.env.PORT || 3000
app.set 'views', path.join(__dirname, '/views')
app.set 'view engine', 'jade'

app.use express.favicon()
app.use express.logger('dev')
app.use express.json()
app.use express.urlencoded()
app.use express.methodOverride()
app.use express.cookieParser()
app.use express.bodyParser()
app.use express.session({ secret: 'keyboard cat' })

# static files
app.use paths.bower
app.use paths.public

# protect /api routes with JWT
app.use '/api', expressJwt({ secret: config.JWT_Token })


app.use app.router

# development only
if 'development' == app.get('env')
  app.use express.errorHandler()

# ROUTES
routes = require('./route_map')(app)

# setup Servers
server = http.createServer(app)
httpsServer = https.createServer(credentials, app);


## start servers
# https
httpsServer.listen 3001, () =>
  console.log 'Express HTTPS on port ' + 3001

# http
server.listen app.get('port'), () =>
  console.log 'Express server listening on port ' + app.get('port')

# socket.io
io = io.listen server
io.set 'log level', 1


# New client joining
io.sockets.on 'connection', (socket) ->
  address = socket.handshake.address
  client_ip = address.address

  socket.on 'ready', ->
    id = client_ip
  
    socket.emit 'attach-client', 
      id: id

