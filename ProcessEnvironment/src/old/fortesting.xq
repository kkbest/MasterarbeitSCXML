import module namespace mba = 'http://www.dke.jku.at/MBA';
import module namespace sc  = 'http://www.w3.org/2005/07/scxml';
import module namespace kk = 'http://www.w3.org/2005/07/kk';

declare variable $dbName external;
declare variable $collectionName external;
declare variable $mbaName external;


 let $mba := mba:getMBA($dbName, $collectionName, $mbaName)
 let $queue := mba:getExternalEventQueue($mba)
  let $nextEvent := ($queue/event)[1]
  let $nextEventName := <name xmlns="">{fn:string($nextEvent/@name)}</name>
  let $nextEventData := <data xmlns="">{$nextEvent/*}</data>
  let $currentEvent := mba:getCurrentEvent($mba)
  return mba:getExternalEventQueue($mba)/event[1]


