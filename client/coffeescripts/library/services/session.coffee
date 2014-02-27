# Services
# 
angular.module 'coffeeboiler.services'

.factory 'Session', ($resource) ->
  $resource '/authentication'

.factory 'User', ($resource) ->
  $resource '/register'

.service 'socket', (UserSession) ->
  io.connect window.location.origin, { query: 'token=' + UserSession.loggedIn() }

.service 'UserSession', ($window) ->
  current = $window.sessionStorage.token
  
  session = 
    login: (user) ->
      $window.sessionStorage.token = user.token
      current = user.token

    logout: ->
      delete $window.sessionStorage.token
      current = null

    loggedIn: ->
      current

.factory 'Auth', ($rootScope, Session, UserSession, $state, LoginModal, User) ->
  login: (provider, user, callback) ->
    if typeof callback isnt 'function'
      callback = angular.noop

    Session.save
      provider: provider
      name: user.name
      password: user.password
    , (data) ->
      if not data.error
        # success
        UserSession.login data
        callback()
      else 
        UserSession.logout()
        callback data.error

  create: (user, callback) ->
    if typeof callback isnt 'function'
      callback = angular.noop

    User.save user, (data) ->
      UserSession.login data if not data.errors

      callback(data.errors)

  logout: (callback) ->
    if typeof callback isnt 'function'
      callback = angular.noop

    Session.remove () ->
      UserSession.logout()
      callback()

  monitor: () ->
    $rootScope.$on '$stateChangeStart', (event, current, prev) ->
      if current.authenticate and not UserSession.loggedIn()
        # User isn’t authenticated
        $state.transitionTo 'home'
        LoginModal.open()
        event.preventDefault()

.factory 'authInterceptor', ($q, UserSession, $injector) ->
  $state = LoginModal = null

  request: (config) ->
    config.headers = config.headers or {}
    if UserSession.loggedIn() and config.url.match /^\/api/
      config.headers.Authorization = 'Bearer ' + UserSession.loggedIn()
    
    config

  responseError: (response) ->
    if response.status is 401
      $state = $injector.get '$state'
      LoginModal = $injector.get 'LoginModal'
      UserSession.logout()
      $state.transitionTo 'home'
      LoginModal.open()



    response or $q.when response
