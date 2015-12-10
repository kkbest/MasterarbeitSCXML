module namespace kk = 'http://www.w3.org/2005/07/kk';
import module namespace scx='http://www.w3.org/2005/07/scxml/extension/';
import module namespace functx = 'http://www.functx.com';
import module namespace mba='http://www.dke.jku.at/MBA'; 
import module namespace sc = 'http://www.w3.org/2005/07/scxml';
import module namespace sync = 'http://www.dke.jku.at/MBA/Synchronization';





declare updating function kk:dotheupdate($dbName,$collectionName, $mbaName)
{
  let $mba := mba:getMBA($dbName, $collectionName, $mbaName)
return 
 replace node $mba with kk:donotUpdate($dbName,$collectionName, $mbaName)  
};


declare function kk:donotUpdate($dbName,$collectionName, $mbaName)
{
  let $mba := mba:getMBA($dbName, $collectionName, $mbaName)
  let $removeInsertedMBA := kk:removeFromInsertLog($mba)
  let $queue := mba:getExternalEventQueue($removeInsertedMBA)
  let $nextEvent := ($queue/event)[1]
  let $nextEventName := <name xmlns="">{fn:string($nextEvent/@name)}</name>
  let $nextEventData := <data xmlns="">{$nextEvent/*}</data>
  let $currentEvent := mba:getCurrentEvent($removeInsertedMBA)
  let $removedMba :=  kk:removeCurrentEventoU($removeInsertedMBA)
  let $insertMba := kk:insertcurrentEventoU($removedMba,$queue,$nextEvent,$nextEventName,$nextEventData,$currentEvent)
  let $currentEmba := kk:dequeueExternalEvent1($insertMba)
 
 let $executableContent :=  kk:getExecutableContents($currentEmba)

 let $foldresults := fold-left($executableContent, $currentEmba, function($mba, $content){ fn:trace(kk:runExecutableContentuA($mba, $content))})


let $changestatusmba := kk:changeCurrentStatusoU($foldresults)

let $currentExternalEventmba := kk:removeCurrentExternalEventuA($changestatusmba)

let $contentsevent := kk:getExecutableContentsEventless($currentExternalEventmba)

let $foldfinal := fold-left($contentsevent, $currentExternalEventmba, function($mba, $content){ fn:trace(kk:runExecutableContentuA($mba, $content))})
(:let $final :=  kk:runExecutableContentuA($currentExternalEventmba, $contentsevent)
:)
let $result := kk:changeCurrentStatusEventlessuA($foldfinal)

 (: let $loadedmba :=kk:loadNextExternalEvent($removeInsertedMBA,$queue,$nextEvent,$nextEventName,$nextEventData,$currentEvent)
  let $mab :=  kk:tryptoupdate($dbName, $collectionName, $mbaName) :)
  

(:kk:changeCurrentStatus($dbName, $collectionName, $mbaName), kk:removeCurrentExternalEvent($dbName, $collectionName, $mbaName), kk:processEventlessTransitions($dbName, $collectionName, $mbaName) :)
 


  return $result

};


declare function kk:removeFromInsertLog($mba as element()) {
 
 copy $mbanew := $mba 
modify(
  
     delete node functx:first-node(
       db:open(mba:getDatabaseName($mba), 'collections.xml')/mba:collections/mba:collection[@ref = mba:getCollectionName($mba)]/mba:new/mba:mba[@name = $mba/@name]
))
return $mbanew
};


declare function kk:removeCurrentEventoU($mba)
{

copy $copymba := $mba
modify(
    mba:removeCurrentEvent($mba))
    return $copymba
};

declare function kk:insertcurrentEventoU($mba,$queue,$nextEvent,$nextEventName,$nextEventData,$currentEvent)
{
  
copy $copymba :=
  $mba
modify (
  if($nextEvent) then 
  (    
 insert node $nextEventName into mba:getCurrentEvent($copymba),
 insert node $nextEventData into mba:getCurrentEvent($copymba) )
else
()
)
return $copymba

  
};

declare function kk:dequeueExternalEvent1($mba as element()) {
  
  copy $mbamod :=
  $mba
modify (
  delete node (mba:getExternalEventQueue($mbamod)/*)[1]
)
return $mbamod
};

declare function kk:eventlessTransitions($mba)
{
  let $contents := kk:getExecutableContentsEventless($mba)
  return $contents
  
};



declare function kk:getExecutableContents($mba)
{

let $scxml := mba:getSCXML($mba)

let $currentEvent := mba:getCurrentEvent($mba)
let $eventName    := $currentEvent/name

let $configuration := mba:getConfiguration($mba)
let $dataModels := sc:selectDataModels($configuration)

let $transitions := 
  if($eventName) then
    sc:selectTransitions($configuration, $dataModels, $eventName)
  else ()
  
let $contents :=
  for $t in $transitions
    return $t/*

return $contents
};



declare function kk:runExecutableContentuA($mba,$content)
  {

copy $copymba := $mba
modify 
(
  let $scxml := mba:getSCXML($copymba)

let $configuration := mba:getConfiguration($copymba)
let $dataModels := sc:selectDataModels($configuration)
return
 typeswitch($content)
    case element(sc:assign) return 
      sc:assign($dataModels, $content/@location, $content/@expr, $content/@type, $content/@attr, $content/*)
    case element(sync:assignAncestor) return
      sync:assignAncestor($copymba, $content/@location, $content/@expr, $content/@type, $content/@attr, $content/*, $content/@level)
    case element(sync:sendAncestor) return 
      sync:sendAncestor($copymba, $content/@event, $content/@level, $content/sc:param, $content/sc:content)
    case element(sync:assignDescendants) return
      sync:assignDescendants($copymba, $content/@location, $content/@expr, $content/@type, $content/@attr, $content/*, $content/@level, $content/@inState, $content/@satisfying)
    case element(sync:sendDescendants) return 
      sync:sendDescendants($copymba, $content/@event, $content/@level, $content/@inState, $content/@satisfying, $content/sc:param, $content/sc:content)
    case element(sync:newDescendant) return 
      sync:newDescendant($copymba, $content/@name, $content/@level, $content/@parents, $content/*)
    default return ()
)
return $copymba

};



declare function kk:changeCurrentStatusoU($mba)
{

copy $copymba := $mba
modify
(

let $scxml := mba:getSCXML($copymba)

let $currentEvent := mba:getCurrentEvent($copymba)
let $eventName    := $currentEvent/name

let $configuration := mba:getConfiguration($copymba)

let $dataModels := sc:selectDataModels($configuration)

let $transitions := 
  if($eventName) then
    sc:selectTransitions($configuration, $dataModels, $eventName)
  else ()

let $exitSet  := sc:computeExitSet($configuration, $transitions)
let $entrySet := sc:computeEntrySet($transitions)

return (
  mba:removeCurrentStates($copymba, $exitSet),
  mba:addCurrentStates($copymba, $entrySet)
)
)
return $copymba
};


declare function kk:removeCurrentExternalEventuA($mba)
{
 
 copy $copymba := $mba
 modify
 mba:removeCurrentEvent($copymba)
 return $copymba

};




declare function kk:getExecutableContentsEventless($mba)
{
let $scxml := mba:getSCXML($mba)

let $configuration := mba:getConfiguration($mba)
let $dataModels := sc:selectDataModels($configuration)

let $transitions := 
  sc:selectEventlessTransitions($configuration, $dataModels)

let $contents :=
  for $t in $transitions
    return $t/*

return $contents
};


declare function kk:changeCurrentStatusEventlessuA($mba)
{

copy $copymba := $mba
modify
(
let $scxml := mba:getSCXML($copymba)

let $configuration := mba:getConfiguration($copymba)

let $dataModels := sc:selectDataModels($configuration)

let $transitions := 
  sc:selectEventlessTransitions($configuration, $dataModels)

let $exitSet  := sc:computeExitSet($configuration, $transitions)
let $entrySet := sc:computeEntrySet($transitions)

return (
  mba:removeCurrentStates($copymba, $exitSet),
  mba:addCurrentStates($copymba, $entrySet)
)
)
return $copymba
};



