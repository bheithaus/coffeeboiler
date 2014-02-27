window.coffeeboiler_constants = {
  some_url: 'http://www.example.com'
};

'use strict';
angular.module('coffeeboiler.directives', []).directive('gryft', function() {
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
        $scope.src = "" + coffeeboiler_constants.gryft_base + meta._id + ".jpg";
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

angular.module('coffeeboiler.filters', []).filter('interpolate', function(version) {
  return function(text) {
    return String(text).replace(/\%VERSION\%/mg, version);
  };
});

angular.module('coffeeboiler.controllers', []);

angular.module('coffeeboiler.controllers').controller('CreateCtrl', function($scope, $http, $location, LoginModal, User) {
  return $scope.name = 'hey derr';
});

angular.module('coffeeboiler.controllers').controller('HomeCtrl', function($scope, $http, $location, LoginModal, User) {
  return $scope.name = 'hey derr';
});

angular.module('coffeeboiler.controllers').controller('ListCtrl', function($scope, $http, $location, LoginModal, User) {
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

angular.module('coffeeboiler.controllers').controller('LoginInstanceCtrl', function($scope, $modalInstance, Auth, $state) {
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
        return $scope.error = true;
      }
    });
  };
  return $scope.cancel = function() {
    return $modalInstance.dismiss('cancel');
  };
}).controller('LoginCtrl', function(LoginModal) {
  return LoginModal.open();
});

angular.module('coffeeboiler.controllers').controller('LogoutCtrl', function($scope, $http, Auth, $state) {
  return Auth.logout(function() {
    return $state.transitionTo('home');
  });
});

angular.module('coffeeboiler.controllers').controller('RegisterInstanceCtrl', function($scope, $modalInstance, $state, Auth) {
  $scope.user = {};
  $scope.register = function() {
    return Auth.create($scope.user, function(errors) {
      var error, field, _results;
      if (!errors) {
        $modalInstance.dismiss();
        return $state.transitionTo('home');
      } else {
        _results = [];
        for (field in errors) {
          error = errors[field];
          _results.push($scope[field + '_error'] = error);
        }
        return _results;
      }
    });
  };
  return $scope.cancel = function() {
    return $modalInstance.dismiss('cancel');
  };
}).controller('LoginCtrl', function(LoginModal) {
  return LoginModal.open();
});

angular.module('coffeeboiler.controllers').controller('AppCtrl', function($scope, $location, LoginModal, RegisterModal, UserSession, Auth, $state) {
  $scope.logout = function() {
    return Auth.logout(function() {
      return $state.transitionTo('home');
    });
  };
  $scope.login = LoginModal.open;
  $scope.register = RegisterModal.open;
  $scope.loggedIn = function() {
    return UserSession.loggedIn();
  };
  return $scope.user = UserSession;
});

angular.module('coffeeboiler.services', []);

angular.module('coffeeboiler.services').factory('LoginModal', function($modal, $log) {
  return {
    open: function() {
      var modalInstance;
      return modalInstance = $modal.open({
        templateUrl: 'partials/session/login',
        controller: 'LoginInstanceCtrl'
      });
    }
  };
}).factory('RegisterModal', function($modal, $log) {
  return {
    open: function() {
      var modalInstance;
      return modalInstance = $modal.open({
        templateUrl: 'partials/session/register',
        controller: 'RegisterInstanceCtrl'
      });
    }
  };
});

angular.module('coffeeboiler.services').factory('Session', function($resource) {
  return $resource('/authentication');
}).factory('User', function($resource) {
  return $resource('/register');
}).service('socket', function(UserSession) {
  return io.connect(window.location.origin, {
    query: 'token=' + UserSession.loggedIn()
  });
}).service('UserSession', function($window) {
  var current, session;
  current = $window.sessionStorage.token;
  return session = {
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
}).factory('Auth', function($rootScope, Session, UserSession, $state, LoginModal, User) {
  return {
    login: function(provider, user, callback) {
      if (typeof callback !== 'function') {
        callback = angular.noop;
      }
      return Session.save({
        provider: provider,
        name: user.name,
        password: user.password
      }, function(data) {
        if (!data.error) {
          UserSession.login(data);
          return callback();
        } else {
          UserSession.logout();
          return callback(data.error);
        }
      });
    },
    create: function(user, callback) {
      if (typeof callback !== 'function') {
        callback = angular.noop;
      }
      return User.save(user, function(data) {
        if (!data.errors) {
          UserSession.login(data);
        }
        return callback(data.errors);
      });
    },
    logout: function(callback) {
      if (typeof callback !== 'function') {
        callback = angular.noop;
      }
      return Session.remove(function() {
        UserSession.logout();
        return callback();
      });
    },
    monitor: function() {
      return $rootScope.$on('$stateChangeStart', function(event, current, prev) {
        if (current.authenticate && !UserSession.loggedIn()) {
          $state.transitionTo('home');
          LoginModal.open();
          return event.preventDefault();
        }
      });
    }
  };
}).factory('authInterceptor', function($q, UserSession, $injector) {
  var $state, LoginModal;
  $state = LoginModal = null;
  return {
    request: function(config) {
      config.headers = config.headers || {};
      if (UserSession.loggedIn() && config.url.match(/^\/api/)) {
        config.headers.Authorization = 'Bearer ' + UserSession.loggedIn();
      }
      return config;
    },
    responseError: function(response) {
      if (response.status === 401) {
        $state = $injector.get('$state');
        LoginModal = $injector.get('LoginModal');
        UserSession.logout();
        $state.transitionTo('home');
        LoginModal.open();
      }
      return response || $q.when(response);
    }
  };
});

var coffeeboiler;

coffeeboiler = angular.module('coffeeboiler', ['ui.router', 'ui.bootstrap', 'ngCookies', 'ngResource', 'coffeeboiler.controllers', 'coffeeboiler.directives', 'coffeeboiler.services']).config(function($stateProvider, $urlRouterProvider, $locationProvider, $httpProvider) {
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
  return $urlRouterProvider.otherwise('/');
}).run([
  '$rootScope', '$state', 'Auth', function($rootScope, $state, Auth) {
    return Auth.monitor();
  }
]);
