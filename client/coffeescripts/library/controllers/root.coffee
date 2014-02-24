# /* Controllers */
angular.module 'coffeeboiler.controllers'

#root scope Controller
.controller 'AppCtrl', ($scope, $location, LoginModal, RegisterModal, UserSession, Auth, $state) ->
  # handle login modal error here
  $scope.logout = ->
    Auth.logout ->
      $state.transitionTo 'home'

  $scope.login = LoginModal.open
  $scope.register = RegisterModal.open

  $scope.loggedIn = ->
    UserSession.loggedIn()

  $scope.user = UserSession





