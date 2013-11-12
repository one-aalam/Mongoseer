'use strict'

angular.module('mongoseerApp')
  .factory 'breadcrumb', ['$rootScope', '$location', ($rootScope, $location) ->
    
    bc = [] # Breadcrumbs store
    
    $rootScope.$on '$routeChangeSuccess', (e, current) ->
    	pathParts = $location.path().split('/')
    	crumb = (idx) ->
    		 path: pathParts.slice(0, idx + 1).join('/')
    		 label: pathParts[idx]
    	pathParts.shift()
    	bc = (crumb(p) for i,p in pathParts)

    {
      all: () ->
        bc
      first: () ->
      	bc[0] || {}
    }
  ]
