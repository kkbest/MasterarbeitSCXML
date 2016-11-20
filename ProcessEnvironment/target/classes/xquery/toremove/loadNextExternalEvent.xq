import module namespace mba = 'http://www.dke.jku.at/MBA';

declare variable $dbName external;
declare variable $collectionName external;
declare variable $mbaName external;

let $mba := mba:getMBA($dbName, $collectionName, $mbaName)

return mba:loadNextExternalEvent($mba)