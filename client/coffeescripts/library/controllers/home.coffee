# /* Controllers */
angular.module 'gryfter.controllers'

.controller 'HomeCtrl', ($scope, $http, $location, LoginModal, User) ->
  # handle login modal error here
  $scope.name = 'hey derr'

