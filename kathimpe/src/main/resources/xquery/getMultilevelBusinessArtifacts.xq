import module namespace mba = 'http://www.dke.jku.at/MBA';

declare variable $dbName external;
declare variable $collectionName external;

let $collection := mba:getCollection($dbName, $collectionName)

return $collection//mba:mba