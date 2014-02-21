window.myapp_constants = {
  some_url: 'http://www.example.com'
};

angular.module('gryfter.controllers', []);

angular.module('gryfter.controllers').controller('CreateCtrl', function($scope, $http, $location, LoginModal, User) {
  return $scope.name = 'hey derr';
});

angular.module('gryfter.controllers').controller('HomeCtrl', function($scope, $http, $location, LoginModal, User) {
  return $scope.name = 'hey derr';
});

angular.module('gryfter.controllers').controller('ListCtrl', function($scope, $http, $location, LoginModal, User) {
  $http.get('/api/list').success(function() {
    return console.log('ars', arguments);
  });
  return $scope.entities = [
    {
      name: 'one'
    }, {
      name: 'two'
    }
  ];
});

angular.module('gryfter.controllers').controller('LoginInstanceCtrl', function($scope, $modalInstance, Auth, $state) {
  $scope.user = {};
  $scope.login = function() {
    return Auth.login('password', {
      name: $scope.user.name,
      password: $scope.user.password
    }, function(error) {
      if (!error) {
        $modalInstance.dismiss();
        return $state.transitionTo('home');
      } else {
        return console.log('ERROR');
      }
    });
  };
  return $scope.cancel = function() {
    return $modalInstance.dismiss('cancel');
  };
}).controller('LoginCtrl', function(LoginModal) {
  return LoginModal.open();
});

angular.module('gryfter.controllers').controller('LogoutCtrl', function($scope, $http, Auth, $state) {
  return Auth.logout(function() {
    return $state.transitionTo('home');
  });
});

angular.module('gryfter.controllers').controller('AppCtrl', function($scope, $http, $location, LoginModal, User) {
  $scope.open = LoginModal.open;
  $scope.errors = $location.search().incorrect;
  $scope.loggedIn = function() {
    return User.loggedIn();
  };
  return $scope.user = User;
});

'use strict';
angular.module('gryfter.directives', []).directive('gryft', function() {
  return {
    restrict: 'A',
    scope: {
      meta: '='
    },
    template: '<h4>{{creator}}</h4>' + '<span class="price">{{price}}</span>' + '<img class="img-rounded col-xs-12 clearfix" src="{{src}}"/>',
    link: function($scope, element, attrs) {
      var meta;
      meta = $scope.meta;
      if (meta._id) {
        $scope.src = "" + gryfter_constants.gryft_base + meta._id + ".jpg";
        $scope.creator = meta.creator;
        return $scope.price = meta.price || 'no price';
      }
    }
  };
}).directive('tagManager', function() {
  return {
    restrict: 'E',
    scope: {
      tags: '='
    },
    template: '<div class="tags">' + '<a ng-repeat="(idx, tag) in tags" class="tag" ng-click="remove(idx)">{{tag}}</a>' + '</div>' + '<input type="text" placeholder="Add a tag..." ng-model="new_value"></input> ' + '<a class="btn" ng-click="add()">Add</a>',
    link: function($scope, $element) {
      var input;
      input = angular.element($element.children()[1]);
      $scope.add = function() {
        $scope.tags.push($scope.new_value);
        return $scope.new_value = "";
      };
      $scope.remove = function(idx) {
        return $scope.tags.splice(idx, 1);
      };
      return input.bind('keypress', function(event) {
        if (event.keyCode === 13) {
          return $scope.$apply($scope.add);
        }
      });
    }
  };
});

angular.module('myApp.filters', []).filter('interpolate', function(version) {
  return function(text) {
    return String(text).replace(/\%VERSION\%/mg, version);
  };
});

angular.module('gryfter.services', []).factory('Session', function($resource) {
  return $resource('/authentication');
}).service('User', function(Session, $cookieStore, $window) {
  var current, user;
  current = $window.sessionStorage.token;
  return user = {
    login: function(user) {
      $window.sessionStorage.token = user.token;
      return current = user.token;
    },
    logout: function() {
      delete $window.sessionStorage.token;
      return current = null;
    },
    loggedIn: function() {
      return current;
    }
  };
}).factory('Auth', function($rootScope, Session, User, $state, LoginModal) {
  var auth;
  return auth = {
    login: function(provider, user, callback) {
      if (typeof callback !== 'function') {
        callback = angular.noop;
      }
      return Session.save({
        provider: provider,
        name: user.name,
        password: user.password
      }, function(data) {
        User.login(data);
        return callback();
      }, function(data) {
        User.logout();
        return $scope.message = 'Error: Invalid user or password';
      });
    },
    logout: function(callback) {
      if (typeof callback !== 'function') {
        callback = angular.noop;
      }
      return Session.remove(function() {
        User.logout();
        return callback();
      });
    },
    monitor: function() {
      return $rootScope.$on('$stateChangeStart', function(event, current, prev) {
        if (current.authenticate && !User.loggedIn()) {
          $state.transitionTo('home');
          LoginModal.open();
          return event.preventDefault();
        }
      });
    }
  };
}).factory('LoginModal', function($modal, $log) {
  var modal;
  return modal = {
    open: function() {
      var modalInstance;
      return modalInstance = $modal.open({
        templateUrl: 'partials/session/login',
        controller: 'LoginInstanceCtrl'
      });
    }
  };
}).factory('authInterceptor', function($rootScope, $q, $window, $location) {
  return {
    request: function(config) {
      config.headers = config.headers || {};
      if ($window.sessionStorage.token) {
        config.headers.Authorization = 'Bearer ' + $window.sessionStorage.token;
      }
      return config;
    },
    responseError: function(response) {
      if (response.status === 401) {
        $location.path('/');
      }
      return response || $q.when(response);
    }
  };
});

var gryfter;

gryfter = angular.module('gryfter', ['ui.router', 'ui.bootstrap', 'ngCookies', 'ngResource', 'gryfter.controllers', 'gryfter.directives', 'gryfter.services']).config(function($stateProvider, $urlRouterProvider, $locationProvider, $httpProvider) {
  $httpProvider.interceptors.push('authInterceptor');
  $locationProvider.html5Mode(true);
  $stateProvider.state('home', {
    url: '/',
    templateUrl: 'partials/home',
    controller: 'HomeCtrl'
  }).state('create', {
    url: '/create',
    templateUrl: 'partials/entity/create',
    controller: 'CreateCtrl',
    authenticate: true
  }).state('list', {
    url: '/entities',
    templateUrl: 'partials/entity/list',
    controller: 'ListCtrl'
  }).state('show', {
    url: '/entities/:id',
    templateUrl: 'partials/entity/show',
    controller: 'ShowCtrl'
  }).state('login', {
    controller: 'LoginCtrl'
  }).state('logout', {
    url: '/logout',
    controller: 'LogoutCtrl'
  });
  return $urlRouterProvider.otherwise('/capture');
}).run([
  '$rootScope', '$state', 'Auth', function($rootScope, $state, Auth) {
    return Auth.monitor();
  }
]);