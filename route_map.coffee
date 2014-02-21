routes = require './routes'
library = require './library'
middleware = library.middleware


module.exports = (app) ->
  app.get '/',             routes.index
  app.get '/partials/(*)', routes.partial

  app.post '/register', library.authentication.register

  # session
  app.get  '/authentication', library.authentication.session
  app.post '/authentication', library.authentication.login
  app.del  '/authentication', library.authentication.logout
  
  app.get '/api/list', (req, res) ->
    console.log 'test'
    res.send 200

  # angularJS Entry point
  app.get '*', routes.index

