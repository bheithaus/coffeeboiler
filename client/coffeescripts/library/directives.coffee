'use strict'

# /* Directives */
angular.module 'coffeeboiler.directives', []
.directive 'gryft', 
  () ->
    restrict: 'A'
    scope: { meta: '=' }
    template: '<h4>{{creator}}</h4>'+
    '<span class="price">{{price}}</span>'+ 
    '<img class="img-rounded col-xs-12 clearfix" src="{{src}}"/>'

    link: ($scope, element, attrs) ->
      meta = $scope.meta
      if meta._id
        $scope.src = "#{ coffeeboiler_constants.gryft_base }#{ meta._id }.jpg"
        $scope.creator = meta.creator
        $scope.price = meta.price || 'no price'



.directive 'tagManager', () ->
    restrict: 'E'
    scope: { tags: '=' }
    template:
      '<div class="tags">' +
          '<a ng-repeat="(idx, tag) in tags" class="tag" ng-click="remove(idx)">{{tag}}</a>' +
      '</div>' +
      '<input type="text" placeholder="Add a tag..." ng-model="new_value"></input> ' +
      '<a class="btn" ng-click="add()">Add</a>'

    link: ( $scope, $element ) ->
      # // FIXME: this is lazy and error-prone
      input = angular.element( $element.children()[1] );

      # // This adds the new tag to the tags array
      $scope.add = () ->
        $scope.tags.push( $scope.new_value );
        $scope.new_value = "";
      
      
      # // This is the ng-click handler to remove an item
      $scope.remove =  ( idx ) ->
        $scope.tags.splice( idx, 1 );
    
      
      # // Capture all keypresses
      input.bind( 'keypress',  ( event ) ->
          # // But we only care when Enter was pressed
          if ( event.keyCode == 13 )
              # // There's probably a better way to handle this...
              $scope.$apply( $scope.add );
          
      )