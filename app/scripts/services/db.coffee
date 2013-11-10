'use strict'

angular.module('mongoseerApp')
  .factory 'Db', ['$http', ($http) ->
    # Service logic
    # ...

    apiEP = 'http://localhost:3000/api/dbs'

    # Public API here
    {
      get: (db) ->
         if db then $http.get(apiEP + '/' + db.name) else $http.get(apiEP)
      getColl: (db) ->
         if db then $http.get(apiEP + '/' + db) else $http.get(apiEP)
      getDocs: (db, coll) ->
         if db and coll then $http.get(apiEP + '/' + db + '/' + coll) else $http.get(apiEP)
      getDoc: (db, coll, doc) ->
         if db and coll and doc then $http.get(apiEP + '/' + db + '/' + coll + '/' + doc) else $http.get(apiEP)
    }
  ]
