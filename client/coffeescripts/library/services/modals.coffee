angular.module 'coffeeboiler.services'

.factory 'LoginModal', ($modal, $log) ->
  open: () ->
    modalInstance = $modal.open
      templateUrl: 'partials/session/login'
      controller: 'LoginInstanceCtrl'

.factory 'RegisterModal', ($modal, $log) ->
  open: () ->
    modalInstance = $modal.open
      templateUrl: 'partials/session/register'
      controller: 'RegisterInstanceCtrl'
