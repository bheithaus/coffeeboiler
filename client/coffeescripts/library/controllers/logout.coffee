# /* Controllers */
angular.module 'gryfter.controllers'

.controller 'LogoutCtrl', ($scope, $http, Auth, $state) ->
  Auth.logout () ->
    $state.transitionTo 'home'
