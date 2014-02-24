# /* Controllers */
angular.module 'coffeeboiler.controllers'

.controller 'RegisterInstanceCtrl', ($scope, $modalInstance, $state, Auth) ->
  $scope.user = {}

  $scope.register = () ->
    Auth.create $scope.user, (errors) ->
      if not errors
        $modalInstance.dismiss()
        $state.transitionTo 'home'
      else
        for field, error of errors
          $scope[field + '_error'] = error

  $scope.cancel = () ->
    $modalInstance.dismiss 'cancel'

.controller 'LoginCtrl', (LoginModal) ->  
  LoginModal.open()
