# /* Controllers */
angular.module 'coffeeboiler.controllers'

.controller 'ListCtrl', ($scope, $http, $location, LoginModal, User) ->
  $http.get('/api/list')
  .success () ->
    console.log 'ars', arguments
    
  # handle login modal error here
  $scope.entities = [
    { name: 'one' }
    { name: 'two' }
  ]

