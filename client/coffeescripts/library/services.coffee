# Services
# 
angular.module 'gryfter.services', [] 

.factory 'Session', ($resource) ->
  $resource '/authentication'

.service 'User', (Session, $cookieStore, $window) ->
  current = $window.sessionStorage.token
  
  user = 
    login: (user) ->
      $window.sessionStorage.token = user.token
      current = user.token

    logout: ->
      delete $window.sessionStorage.token
      current = null

    loggedIn: ->
      current

.factory 'Auth', ($rootScope, Session, User, $state, LoginModal) ->
  auth =
    login: (provider, user, callback) ->
      if typeof callback isnt 'function'
        callback = angular.noop

      Session.save
        provider: provider
        name: user.name
        password: user.password
      , (data) ->
        # success
        User.login data
        callback()
      , (data) ->
        # error
        User.logout()
        $scope.message = 'Error: Invalid user or password';

    logout: (callback) ->
      if typeof callback isnt 'function'
        callback = angular.noop

      Session.remove () ->
        User.logout()
        callback()

    monitor: () ->
      $rootScope.$on '$stateChangeStart', (event, current, prev) ->
        if current.authenticate and not User.loggedIn()
          # User isn’t authenticated
          $state.transitionTo 'home'
          LoginModal.open()
          event.preventDefault()

.factory 'LoginModal', ($modal, $log) ->
  modal = 
    open: () ->
      modalInstance = $modal.open
        templateUrl: 'partials/session/login'
        controller: 'LoginInstanceCtrl'


.factory 'authInterceptor', ($rootScope, $q, $window, $location) ->
  request: (config) ->
    config.headers = config.headers or {}
    if $window.sessionStorage.token
      config.headers.Authorization = 'Bearer ' + $window.sessionStorage.token;
    
    config

  responseError: (response) ->
    if response.status is 401
      $location.path '/'

    response or $q.when response

