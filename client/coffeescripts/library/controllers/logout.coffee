# /* Controllers */
angular.module 'coffeeboiler.controllers'

.controller 'LogoutCtrl', ($scope, $http, Auth, $state) ->
  Auth.logout () ->
    $state.transitionTo 'home'
