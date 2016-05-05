import module namespace mba = 'http://www.dke.jku.at/MBA';

declare variable $dbName external;
declare variable $collectionName external;

let $collection := mba:getCollection($dbName, $collectionName)

for $mba in $collection//mba:mba
  return mba:init($mba)