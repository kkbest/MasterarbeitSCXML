import module namespace mba = 'http://www.dke.jku.at/MBA';

declare variable $dbName external;
declare variable $collectionName external;

let $document := db:open($dbName, 'collections.xml')
let $collectionEntry := $document/mba:collections/mba:collection[@name = $collectionName]

for $entry in $collectionEntry/mba:updated/mba:mba
  return mba:getMBA($dbName, $collectionName, $entry/@ref)
