# /* Controllers */
angular.module 'coffeeboiler.controllers'

.controller 'LoginInstanceCtrl', ($scope, $modalInstance, Auth, $state) ->
  $scope.user = {}

  $scope.login = () ->
    Auth.login 'password',
      name: $scope.user.name
      password: $scope.user.password
    , (error) ->
      if not error
        $modalInstance.dismiss()
        $state.transitionTo 'home'
      else 
        console.log 'ERROR'

  $scope.cancel = () ->
    $modalInstance.dismiss('cancel')


.controller 'LoginCtrl', (LoginModal) ->  
  LoginModal.open()
