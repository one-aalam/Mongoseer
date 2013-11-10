'use strict'

angular.module('mongoseerApp')
  .controller 'DbCtrl', ['$scope','$routeParams','Db', ($scope, $routeParams, Db) ->
  	$scope.collections = []
  	dbReq = Db.getColl($routeParams.dbname)
  	dbReq.success (data)->
  		console.log data
  		$scope.collections = data
  ]
