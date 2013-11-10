'use strict'

angular.module('mongoseerApp')
  .controller 'MainCtrl', ['$scope','Db', ($scope, Db) ->
    $scope.awesomeThings = [
      'HTML5 Boilerplate'
      'AngularJS'
      'Karma'
    ]

    $scope.dbs = []

    $scope.refresh = (db) ->
    	dbReq = Db.get(db)
    	dbReq.success (data) ->
    		$scope.dbs = data
  ]