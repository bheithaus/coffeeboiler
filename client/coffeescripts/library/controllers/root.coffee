# /* Controllers */
angular.module 'coffeeboiler.controllers'

#root scope Controller
.controller 'AppCtrl', ($scope, $http, $location, LoginModal, User) ->
  # handle login modal error here
  $scope.open = LoginModal.open
  $scope.errors = $location.search().incorrect
  $scope.loggedIn = () ->
    User.loggedIn()

  $scope.user = User


