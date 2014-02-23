coffeeboiler = angular.module 'coffeeboiler', [
  'ui.router'
  'ui.bootstrap'
  'ngCookies'
  'ngResource'
  'coffeeboiler.controllers'
  'coffeeboiler.directives'
  'coffeeboiler.services'
]

.config ($stateProvider, $urlRouterProvider, $locationProvider, $httpProvider) ->
  $httpProvider.interceptors.push 'authInterceptor'

  # html location
  $locationProvider.html5Mode true

  $stateProvider
    .state 'home',
      url: '/'
      templateUrl: 'partials/home'
      controller: 'HomeCtrl'

    .state 'create',
      url: '/create'
      templateUrl: 'partials/entity/create'
      controller: 'CreateCtrl'
      authenticate: true

    .state 'list',
      url: '/entities'
      templateUrl: 'partials/entity/list'
      controller: 'ListCtrl'

    .state 'show',
      url: '/entities/:id'
      templateUrl: 'partials/entity/show'
      controller: 'ShowCtrl'

    .state 'login',
      # templateUrl: 'partials/session/login'
      controller: 'LoginCtrl'

    .state 'logout',
      url: '/logout'
      controller: 'LogoutCtrl'

  # For any unmatched url, redirect to /state1
  $urlRouterProvider.otherwise '/capture'

.run ['$rootScope', '$state', 'Auth', ($rootScope, $state, Auth) ->
  Auth.monitor()
]