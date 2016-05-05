

import module namespace mba = 'http://www.dke.jku.at/MBA';
import module namespace kk = 'http://www.w3.org/2005/07/kk'; 

declare variable $dbName external;
declare variable $collectionName external;
declare variable $mbaName external;
declare variable $externalEvent external;

let $mba := mba:getMBA($dbName, $collectionName, $mbaName)
let $newEvent :=  copy $c := $externalEvent
   modify
   insert node <id>{kk:getCounter($dbName, $collectionName, $mbaName)}</id>  into $c
   return $c
   
return mba:enqueueExternalEvent($mba, $newEvent),kk:updateCounter($dbName,$collectionName,$mbaName)
