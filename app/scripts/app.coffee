'use strict'

angular.module('mongoseerApp', [
  'ngCookies',
  'ngResource',
  'ngSanitize'
])
  .config ['$routeProvider', ($routeProvider) ->
    $routeProvider
      .when '/',
        templateUrl: 'views/main.html'
        controller: 'MainCtrl'
      .when '/db',
        templateUrl: 'views/db.html',
        controller: 'DbCtrl'
      .when '/db/:dbname',
        templateUrl: 'views/db.html',
        controller: 'DbCtrl'
      .when '/db/:dbname/:collname',
        templateUrl: 'views/coll.html',
        controller: 'CollCtrl'
      .when '/db/:dbname/:collname/:docid',
        templateUrl: 'views/doc.html',
        controller: 'DocCtrl'
      .otherwise
        redirectTo: '/'
  ]
