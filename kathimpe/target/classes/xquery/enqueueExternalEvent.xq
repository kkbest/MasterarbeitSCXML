

import module namespace mba = 'http://www.dke.jku.at/MBA';
import module namespace sc  = 'http://www.w3.org/2005/07/scxml';

declare variable $dbName external;
declare variable $collectionName external;
declare variable $mbaName external;
declare variable $externalEvent external;

let $mba := mba:getMBA($dbName, $collectionName, $mbaName)
let $newEvent :=  copy $c := $externalEvent
   modify
   insert node <id>{sc:getCounter($dbName, $collectionName, $mbaName)}</id>  into $c
   return $c
   
return mba:enqueueExternalEvent($mba, $newEvent),sc:updateCounter($dbName,$collectionName,$mbaName)
