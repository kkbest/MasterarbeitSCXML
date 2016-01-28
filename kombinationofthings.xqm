module namespace kk = 'http://www.w3.org/2005/07/kk';
import module namespace scx='http://www.w3.org/2005/07/scxml/extension/';
import module namespace functx = 'http://www.functx.com';
import module namespace mba='http://www.dke.jku.at/MBA'; 
import module namespace sc = 'http://www.w3.org/2005/07/scxml';
import module namespace sync = 'http://www.dke.jku.at/MBA/Synchronization';


declare updating function kk:startProcess($dbName,$collectionName,$mbaName)
{
  
 let $mba   := mba:getMBA($dbName, $collectionName, $mbaName)
  let $scxml := mba:getSCXML($mba)
 
 return mba:init($mba)
};



declare function kk:getNewMultilevelBusinessArtifacts($dbName, $collectionName)
{
  

let $document := db:open($dbName, 'collections.xml')
let $collectionEntry := $document/mba:collections/mba:collection[@name = $collectionName]

for $entry in $collectionEntry/mba:new/mba:mba
  return mba:getMBA($dbName, $collectionName, $entry/@ref)
};


declare updating function kk:initMBA($dbName,$collectionName,$mbaName as xs:string)
{
  
  let $mba := mba:getMBA($dbName, $collectionName, $mbaName)
 let $scxml :=  mba:getSCXML($mba)
  return  mba:init($mba),kk:initSCXML($dbName,$collectionName,$mbaName), kk:removeFromUpdateLog($dbName,$collectionName,$mbaName)

};


declare updating function kk:initMBARest($dbName,$collectionName,$mbaName as xs:string)
{
  
  let $mba := mba:getMBA($dbName, $collectionName, $mbaName)
 let $scxml :=  mba:getSCXML($mba)
  return  mba:init($mba)
};


declare updating function kk:initSCXMLRest($dbName,$collectionName,$mbaName as xs:string)
{
  
  let $mba   := mba:getMBA($dbName, $collectionName, $mbaName)
let $scxml := mba:getSCXML($mba)

let $configuration := mba:getConfiguration($mba)

return
  if (not ($configuration)) then 
    mba:addCurrentStates($mba, sc:getInitialStates($scxml))
  else ()


};


declare function kk:initComponents ($dbName,$collectionName,$mbaName as xs:string)
{
  
  let $mba := mba:getMBA($dbName, $collectionName, $mbaName)
 let $scxml :=  mba:getSCXML($mba)
 let $initmba := kk:init($mba) 
 let $initscxml := kk:initSCXML($initmba)
 return kk:removeFromUpdateLog($initscxml)
 
};

declare function kk:removeFromUpdateLog($mba)
{
  
 copy $copymba := $mba
 modify
 (mba:removeFromUpdateLog($mba))
 return $copymba
};

declare function kk:init($mba as element()) {
 
 copy $copymba :=  $mba
 modify
 (
 
  let $scxml := mba:getSCXML($copymba)
  let $initialStates := sc:getInitialStates($scxml)
  
  return (
    if (not ($scxml/sc:datamodel/sc:data[@id = '_event'])) then
      insert node <sc:data id = "_event"/> into $scxml/sc:datamodel
    else (),
    if (not ($scxml/sc:datamodel/sc:data[@id = '_x'])) then
      insert node 
        <sc:data id = "_x">
          <db xmlns="">{mba:getDatabaseName($copymba)}</db>
          <collection xmlns="">{mba:getCollectionName($copymba)}</collection>
          <name xmlns="">{fn:string($copymba/@name)}</name>
          <currentStatus xmlns=""/>
          <externalEventQueue xmlns=""/>
        </sc:data>
      into $scxml/sc:datamodel
    else (),
    if (not ($copymba/mba:concretizations)) then
      insert node <mba:concretizations/> into $copymba
    else ()
  )
)
return $copymba
};


declare function kk:initSCXML($mba)
{
  
copy  $copbymba  := $mba
modify
(

let $scxml := mba:getSCXML($copbymba)
let $configuration := mba:getConfiguration($copbymba)
return
  if (not ($configuration)) then 
    mba:addCurrentStates($copbymba, sc:getInitialStates($scxml))
  else ()
)
return $copbymba

};


declare updating function kk:initSCXML($dbName,$collectionName,$mbaName as xs:string)
{
  
  

let $mba   := mba:getMBA($dbName, $collectionName, $mbaName)
let $scxml := mba:getSCXML($mba)
let $configuration := mba:getConfiguration($mba)
return
  if (not ($configuration)) then 
    mba:addCurrentStates($mba, sc:getInitialStates($scxml))
  else ()
};

declare function kk:getupdatedMBAS($dbName, $collectionName)
{
  let $document := db:open($dbName, 'collections.xml')
let $collectionEntry := $document/mba:collections/mba:collection[@name = $collectionName]

for $entry in $collectionEntry/mba:updated/mba:mba
  return mba:getMBA($dbName, $collectionName, $entry/@ref)

};


declare updating function kk:removeFromInsertLog($dbName, $collectionName, $mbaName)
{
let $mba := mba:getMBA($dbName, $collectionName, $mbaName)
return mba:removeFromInsertLog($mba)
};

declare updating function kk:getNextExternalEvent($dbName,$collectionName,$mbaName)
{
let $mba := mba:getMBA($dbName, $collectionName, $mbaName)
return mba:loadNextExternalEvent($mba)
};

declare function kk:getExecutableContents($dbName, $collectionName, $mbaName)
{

let $mba   := mba:getMBA($dbName, $collectionName, $mbaName)
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
    
    
let $exitSet  := sc:computeExitSet($configuration, $transitions)
let $entrySet := sc:computeEntrySet($transitions)

let $exitContents := $exitSet/sc:onexit/*
let $entryContents := $entrySet/sc:onentry/*

return ($exitContents,$contents,$entryContents)
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

    
let $exitSet  := sc:computeExitSet($configuration, $transitions)
let $entrySet := sc:computeEntrySet($transitions)

let $exitContents := $exitSet/sc:onexit/*
let $entryContents := $entrySet/sc:onentry/*

return ($exitContents,$contents,$entryContents)
};

declare updating function kk:runExecutableContent($dbName, $collectionName, $mbaName , $content)
{


let $mba   := mba:getMBA($dbName, $collectionName, $mbaName)
let $scxml := mba:getSCXML($mba)

let $configuration := mba:getConfiguration($mba)
let $dataModels := sc:selectDataModels($configuration)
let $counter :=  mba:getCurrentEvent($mba)/data/id/text()

return 
  typeswitch($content)
    case element(sc:assign) return 
      sc:assign($dataModels, $content/@location, $content/@expr, $content/@type, $content/@attr, $content/*)
    case element(sync:assignAncestor) return
      sync:assignAncestor($mba, $content/@location, $content/@expr, $content/@type, $content/@attr, $content/*, $content/@level)
    case element(sync:sendAncestor) return 
      sync:sendAncestor($mba, $content/@event, $content/@level, $content/sc:param, $content/sc:content)
    case element(sync:assignDescendants) return
      sync:assignDescendants($mba, $content/@location, $content/@expr, $content/@type, $content/@attr, $content/*, $content/@level, $content/@inState, $content/@satisfying)
    case element(sync:sendDescendants) return 
      sync:sendDescendants($mba, $content/@event, $content/@level, $content/@inState, $content/@satisfying, $content/sc:param, $content/sc:content)
    case element(sync:newDescendant) return 
      sync:newDescendant($mba, $content/@name, $content/@level, $content/@parents, $content/*)
    case element(sc:getValue) return
        sc:getValue($dataModels, $content/@location, $content/@expr, $content/@type, $content/@attr, $content/*, $counter)
     case element(sc:log) return
         sc:log($dataModels,$content/@expr,$content/*,$counter)
     case element(sc:script) return
           () (: TODO: has to be implementent:)
     case element(sc:send) return
           () (: TODO: has to be implementent:)
      case element(sc:cancel) return
           () (: TODO: has to be implementent:)
       case element(sc:raise) return
           () (: TODO: has to be implementent:)     
     
    

    default return ()
};





declare updating function kk:changeCurrentStatus($dbName, $collectionName, $mbaName)
{


let $mba   := mba:getMBA($dbName, $collectionName, $mbaName)
let $scxml := mba:getSCXML($mba)

let $currentEvent := mba:getCurrentEvent($mba)
let $eventName    := $currentEvent/name

let $configuration := mba:getConfiguration($mba)

let $dataModels := sc:selectDataModels($configuration)

let $transitions := 
  if($eventName) then
    sc:selectTransitions($configuration, $dataModels, $eventName)
  else ()

let $exitSet  := sc:computeExitSet($configuration, $transitions)
let $entrySet := sc:computeEntrySet($transitions)

return (
  mba:removeCurrentStates($mba, $exitSet),
  mba:addCurrentStates($mba, $entrySet)
)

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

declare updating function kk:removeCurrentExternalEvent($dbName, $collectionName, $mbaName)
{
 

let $mba := mba:getMBA($dbName, $collectionName, $mbaName)

return mba:removeCurrentEvent($mba)

};

declare function kk:removeCurrentExternalEventuA($mba)
{
 
 copy $copymba := $mba
 modify
 mba:removeCurrentEvent($copymba)
 return $copymba

};


declare function kk:removeCurrentExternalEventsauber($mba)
{
    
 copy $copymba := $mba
 modify
  let $scxml := mba:getSCXML($copymba)
  let $currentEvent := $scxml/sc:datamodel/sc:data[@id = '_event']
  return delete nodes $currentEvent/*
 return $copymba
};
 


(: getExecutableContentsEventless runExecutableContent changeCurrentStatusEventless :)
declare updating function kk:runEventlessTransitions($dbName, $collectionName, $mbaName)
{
  let $executableContents := kk:getExecutableContentsEventless($dbName, $collectionName, $mbaName)
  for $content in $executableContents
  return kk:runExecutableContent($dbName, $collectionName, $mbaName, $content)
};

declare function kk:processEventlessTransitionsuA($dbName, $collectionName, $mbaName)
{
  (:  let $executableContents := kk:getExecutableContentsEventless($dbName, $collectionName, $mbaName)
      for $content in $executableContents
      
    for
  let $v := 1
  return $v :)
  return
};


declare updating function kk:processEventlessTransitions($dbName, $collectionName, $mbaName)
{
  kk:runEventlessTransitions($dbName, $collectionName, $mbaName),kk:changeCurrentStatusEventless($dbName, $collectionName, $mbaName)
};

declare function kk:getExecutableContentsEventless($dbName, $collectionName, $mbaName)
{
let $mba   := mba:getMBA($dbName, $collectionName, $mbaName)
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

declare updating function kk:changeCurrentStatusEventless($dbName, $collectionName, $mbaName)
{
  let $mba   := mba:getMBA($dbName, $collectionName, $mbaName)
let $scxml := mba:getSCXML($mba)

let $configuration := mba:getConfiguration($mba)

let $dataModels := sc:selectDataModels($configuration)

let $transitions := 
  sc:selectEventlessTransitions($configuration, $dataModels)

let $exitSet  := sc:computeExitSet($configuration, $transitions)
let $entrySet := sc:computeEntrySet($transitions)

return (
  mba:removeCurrentStates($mba, $exitSet),
  mba:addCurrentStates($mba, $entrySet)
)
};

declare function kk:changeCurrentStatusEventlessoU($mba)
{
  return
};

declare updating function kk:getandExecuteExecutablecontent($dbName, $collectionName, $mbaName)
{
  for $content in kk:getExecutableContents($dbName, $collectionName, $mbaName)
  return kk:runExecutableContent($dbName, $collectionName, $mbaName, $content)
};

declare updating function kk:getandExecuteExecutablecontent($dbName, $collectionName, $mbaName,$counter)
{
  let $content := kk:getExecutableContents($dbName, $collectionName, $mbaName)
  return kk:runExecutableContent($dbName, $collectionName, $mbaName, $content[$counter])
};



declare updating function kk:test($dbName,$collectionName,$mbaName)
{
  for $i in (1 to 5)
    return kk:macrostep($dbName,$collectionName,$mbaName, $i)
  
};

declare updating function kk:macrostep($dbName, $collectionName, $mbaName)
{
  
 (: kk:removeFromInsertLog($dbName, $collectionName, $mbaName), kk:getNextExternalEvent($dbName, $collectionName, $mbaName), kk:getandExecuteExecutablecontent($dbName, $collectionName, $mbaName), kk:changeCurrentStatus($dbName, $collectionName, $mbaName), kk:removeCurrentExternalEvent($dbName, $collectionName, $mbaName), kk:processEventlessTransitions($dbName, $collectionName, $mbaName) :)
 
 
 kk:removeFromInsertLog($dbName, $collectionName, $mbaName), kk:getNextExternalEvent($dbName, $collectionName, $mbaName), kk:tryptoupdate($dbName, $collectionName, $mbaName)
 (:,kk:changeCurrentStatus($dbName, $collectionName, $mbaName), kk:removeCurrentExternalEvent($dbName, $collectionName, $mbaName), kk:processEventlessTransitions($dbName, $collectionName, $mbaName) :)
 
};


declare updating function kk:macrostep($dbName,$collectionName,$mbaName,$counter)
{
  
  switch($counter)
  case 1
    return kk:removeFromInsertLog($dbName, $collectionName, $mbaName)
  case 2
    return kk:getNextExternalEvent($dbName, $collectionName, $mbaName)
  case 3
   return kk:tryptoupdate($dbName, $collectionName, $mbaName)
  default
  return ()
  
};


declare updating function kk:reload($dbName,$collectionName,$mbaName,$counter)
{
  (:
  if($counter > 4) then
  $counter := 1 
    switch($counter)
  case 1
    kk:macrostep :)
    
   ()
  
};

declare updating function kk:removeFromUpdateLog($dbName, $collectionName, $mbaName)
{
  
  let $mba := mba:getMBA($dbName, $collectionName, $mbaName)
return mba:removeFromUpdateLog($mba)
};

declare updating function kk:tostep($database, $collections, $name)
{
(:  let $updatedmbas := kk:getupdatedMBAS($database,$collections)
  for $name in $updatedmbas/@name
  return :)
   kk:macrostep($database, $collections, $name)
};

declare updating function kk:tryptoupdate($dbName, $collectionName, $mbaName)
{

let $mba   := fn:trace(mba:getMBA($dbName, $collectionName, $mbaName))
let $configuration := mba:getConfiguration($mba)
let $dataModels := sc:selectDataModels($configuration)

let $v := kk:getExecutableContents($dbName, $collectionName, $mbaName)
  for $content in kk:getExecutableContents($dbName, $collectionName, $mbaName)
return 

typeswitch($content)
case element(sc:assign) return
       sc:assign($dataModels, $content/@location, $content/@expr, $content/@type, $content/@attr, $content/*) 
case element(sc:assignAnestor) return
()
default return ()

};


declare function kk:getcurrentExternalEvent($mba)
{
  let $queue := mba:getExternalEventQueue($mba)
  let $nextEvent := ($queue/event)[1]
  let $nextEventName := <name xmlns="">{fn:string($nextEvent/@name)}</name>
  let $nextEventData := <data xmlns="">{$nextEvent/*}</data>
  let $currentEvent := mba:getCurrentEvent($mba)
  return $currentEvent
};




declare function kk:removeFromUpdateohneU($dbName, $collectionName, $mbaName)
{
let $mba := mba:getMBA($dbName, $collectionName, $mbaName)
return if(fn:empty($mba)) then
()
else
kk:removeFromInsertLog($mba)
};
 
 
declare function kk:removeFromInsertLog($mba as element()) {
 
 copy $mbanew := $mba 
modify(
  
     delete node functx:first-node(
       db:open(mba:getDatabaseName($mba), 'collections.xml')/mba:collections/mba:collection[@ref = mba:getCollectionName($mba)]/mba:new/mba:mba[@name = $mba/@name]
))
return $mbanew
};

declare function kk:loadNextExternalEvent($mba,$queue,$nextEvent,$nextEventName,$nextEventData,$currentEvent)
{
  
    copy $mbamod :=
  $mba
modify (
  mba:removeCurrentEvent($mba),
   (: kk:insertnode($mba, $nextEvent, $nextEventName, $currentEvent, $nextEventData),:)
   kk:dequeueExternalEvent($mba)
)
return $mbamod

};

declare updating function kk:dequeueExternalEvent($mba as element()) {
  let $queue := mba:getExternalEventQueue($mba)
  
  return delete node ($queue/*)[1]
};



declare updating function kk:loadNextExternalEvent23($mba as element()) {
  let $queue := mba:getExternalEventQueue($mba)
  let $nextEvent := ($queue/event)[1]
  let $nextEventName := <name xmlns="">{fn:string($nextEvent/@name)}</name>
  let $nextEventData := <data xmlns="">{$nextEvent/*}</data>
  let $currentEvent := mba:getCurrentEvent($mba)
  
  return (
    mba:removeCurrentEvent($mba),
    kk:insertnode($mba, $nextEvent, $nextEventName, $currentEvent, $nextEventData)
    (:if ($nextEvent) then insert node $nextEventName into $currentEvent else (),
    if ($nextEvent) then insert node $nextEventData into $currentEvent else (), 
    mba:dequeueExternalEvent($mba) :)
  )
};


declare updating function kk:insertnode($mba as element(), $nextEvent, $nextEventName, $currentEvent, $nextEventData)
{
  if ($nextEvent) then insert node $nextEventName into $currentEvent else (),
    if ($nextEvent) then insert node $nextEventData into $currentEvent else ()
  
};


 (: let $queue := mba:getExternalEventQueue($mba)
  let $nextEvent := ($queue/event)[1]
  let $nextEventName := <name xmlns="">{fn:string($nextEvent/@name)}</name>
  let $nextEventData := <data xmlns="">{$nextEvent/*}</data>
  let $currentEvent := mba:getCurrentEvent($mba)
:)

declare function kk:removeCurrentEvent($mba as element()) {
  
  
  copy $mbamod :=
  $mba
modify (
  delete nodes mba:getCurrentEvent($mba)/*
)
return $mbamod
 
};

declare function kk:dequeueExternalEvent1($mba as element()) {
  
  copy $mbamod :=
  $mba
modify (
  delete node (mba:getExternalEventQueue($mbamod)/*)[1]
)
return $mbamod
};

declare function kk:runExecutableContent123($dbName, $collectionName, $mbaName , $content)
{
 


copy  $mbanew :=
  mba:getMBA($dbName, $collectionName, $mbaName)
modify ( 
  typeswitch($content)
    case element(sc:assign) return 
      sc:assign(sc:selectDataModels(mba:getConfiguration(mba:getMBA($dbName, $collectionName, $mbaName))), $content/@location, $content/@expr, $content/@type, $content/@attr, $content/*)
    case element(sync:assignAncestor) return
      sync:assignAncestor(mba:getMBA($dbName, $collectionName, $mbaName), $content/@location, $content/@expr, $content/@type, $content/@attr, $content/*, $content/@level)
    case element(sync:sendAncestor) return 
      sync:sendAncestor(mba:getMBA($dbName, $collectionName, $mbaName), $content/@event, $content/@level, $content/sc:param, $content/sc:content)
    case element(sync:assignDescendants) return
      sync:assignDescendants(mba:getMBA($dbName, $collectionName, $mbaName), $content/@location, $content/@expr, $content/@type, $content/@attr, $content/*, $content/@level, $content/@inState, $content/@satisfying)
    case element(sync:sendDescendants) return 
      sync:sendDescendants(mba:getMBA($dbName, $collectionName, $mbaName), $content/@event, $content/@level, $content/@inState, $content/@satisfying, $content/sc:param, $content/sc:content)
    case element(sync:newDescendant) return 
      sync:newDescendant(mba:getMBA($dbName, $collectionName, $mbaName), $content/@name, $content/@level, $content/@parents, $content/*)
    default return ()
)
return $mbanew

};


declare function kk:runExecutableContentuA($mba,$content)
  {
(:declare variable $dbName external;
declare variable $collectionName external;
declare variable $mbaName external;
declare variable $content external;

let $mba   := mba:getMBA($dbName, $collectionName, $mbaName) :)

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
(:
let $scxml := mba:getSCXML($mba)

let $configuration := mba:getConfiguration($mba)
let $dataModels := sc:selectDataModels($configuration)
dscdgfdsgftA<GFVFVD<YAYbn cyvxcv asdfw2
return 
  typeswitch($content)
    case element(sc:assign) return 
      sc:assign($dataModels, $content/@location, $content/@expr, $content/@type, $content/@attr, $content/*)
    case element(sync:assignAncestor) return
      sync:assignAncestor($mba, $content/@location, $content/@expr, $content/@type, $content/@attr, $content/*, $content/@level)
    case element(sync:sendAncestor) return 
      sync:sendAncestor($mba, $content/@event, $content/@level, $content/sc:param, $content/sc:content)
    case element(sync:assignDescendants) return
      sync:assignDescendants($mba, $content/@location, $content/@expr, $content/@type, $content/@attr, $content/*, $content/@level, $content/@inState, $content/@satisfying)
    case element(sync:sendDescendants) return 
      sync:sendDescendants($mba, $content/@event, $content/@level, $content/@inState, $content/@satisfying, $content/sc:param, $content/sc:content)
    case element(sync:newDescendant) return 
      sync:newDescendant($mba, $content/@name, $content/@level, $content/@parents, $content/*)
    default return () :)
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

(:let $max := fn:fold($executableContent,$currentEmba,kk:runExecutableConttentua($content,$mba)) :)

(:let $firstresult :=   fn:for-each($executableContent, kk:runExecutableContentuA($currentEmba, $executableContent))
:)
(:let $firstresult := kk:runExecutableContentuA($currentEmba, $executableContent) :)

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


declare function kk:fortesting($dbName,$collectionName, $mbaName)
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

(:let $firstresult :=   fn:for-each($executableContent, kk:runExecutableContentuA($currentEmba, $executableContent))

let $firstresult := kk:runExecutableContentuA($currentEmba, $executableContent)
let $changestatusmba := kk:changeCurrentStatusoU($firstresult)

let $currentExternalEventmba := kk:removeCurrentExternalEventuA($changestatusmba)

let $contentsevent := kk:getExecutableContentsEventless($currentExternalEventmba)
let $final :=  kk:runExecutableContentuA($currentExternalEventmba, $contentsevent)

let $result := kk:changeCurrentStatusEventlessuA($final) :)

 (: let $loadedmba :=kk:loadNextExternalEvent($removeInsertedMBA,$queue,$nextEvent,$nextEventName,$nextEventData,$currentEvent)
  let $mab :=  kk:tryptoupdate($dbName, $collectionName, $mbaName) :)
  

(:kk:changeCurrentStatus($dbName, $collectionName, $mbaName), kk:removeCurrentExternalEvent($dbName, $collectionName, $mbaName), kk:processEventlessTransitions($dbName, $collectionName, $mbaName) :)
 


  return $executableContent

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


declare function kk:eventlessTransitions($mba)
{
  let $contents := kk:getExecutableContentsEventless($mba)
 (: let $mba := kk:runExecutableContent($mba):) 
  return $contents
  
};
(:
Object[] executableContents = getExecutableContentsEventless(mba);

		for (Object content : executableContents) {
			runExecutableContent(mba, content);
		}

		changeCurrentStatusEventless(mba);
 :)   

declare updating function kk:dotheupdate($dbName,$collectionName, $mbaName)
{
  let $mba := mba:getMBA($dbName, $collectionName, $mbaName)
return 
 replace node $mba with kk:donotUpdate($dbName,$collectionName, $mbaName)  
};




declare updating function kk:dotheupdatetest($dbName,$collectionName, $mbaName)
{
  let $mba := mba:getMBA($dbName, $collectionName, $mbaName)
return 
 replace node $mba with kk:donotUpdatetest($dbName,$collectionName, $mbaName)  
};

declare updating function kk:dotheupdatetestOLD($dbName,$collectionName, $mbaName)
{
  let $mba := mba:getMBA($dbName, $collectionName, $mbaName)
return 
 replace node $mba with kk:donotUpdatetestOLD($dbName,$collectionName, $mbaName)  
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


declare function kk:loadNextExternalEventua($mba)
{

  let $rcemba := kk:removeCurrentEventua($mba)
  let $insertEventmba := kk:insertEvent($rcemba)
  let $dequeueEventmba := kk:dequeueExternalEventuA($mba)
  return $dequeueEventmba
};


declare function kk:dequeueExternalEventuA($mba)
{
  
  
  
  copy $copymba := $mba
  modify
  (
      let $queue := mba:getExternalEventQueue($copymba)
  return delete node ($queue/*)[1]
)
return $copymba
};

declare function kk:removeCurrentEventua($mba)
{
  
  copy $copymba := $mba
  modify
  (
    let $currentEvent := mba:getCurrentEvent($copymba)
  return delete nodes $currentEvent/*
)
return $copymba
};

declare function kk:insertEvent($mba)
{
  let $queue := mba:getExternalEventQueue($mba)
  let $nextEvent := ($queue/event)[1]
  let $nextEventName := <name xmlns="">{fn:string($nextEvent/@name)}</name>
  let $nextEventData := <data xmlns="">{$nextEvent/*}</data>
  let $currentEvent := mba:getCurrentEvent($mba)
  return
  copy $insertEventmba := $mba 
  modify (
    
     if ($nextEvent) then insert node $nextEventName into $currentEvent else (),
    if ($nextEvent) then insert node $nextEventData into $currentEvent else ()
  )
  return $insertEventmba
};

declare function kk:donotUpdatetestOLD($dbName,$collectionName, $mbaName)
{
  let $mba := mba:getMBA($dbName, $collectionName, $mbaName)
  let $removeInsertedMBA := kk:removeFromInsertLog($mba)  
 let $loadNExtEvent :=  kk:loadNextExternalEventua($removeInsertedMBA)
  
  (:
  executablecontents
let $firstresult := kk:runExecutableContentuA($currentEmba, $executableContent)
let $changestatusmba := kk:changeCurrentStatusoU($firstresult)

let $currentExternalEventmba := kk:removeCurrentExternalEventuA($changestatusmba)

let $contentsevent := kk:getExecutableContentsEventless($currentExternalEventmba)
let $final :=  kk:runExecutableContentuA($currentExternalEventmba, $contentsevent)

let $result := kk:changeCurrentStatusEventlessuA($final)
:)
 (: let $loadedmba :=kk:loadNextExternalEvent($removeInsertedMBA,$queue,$nextEvent,$nextEventName,$nextEventData,$currentEvent)
  let $mab :=  kk:tryptoupdate($dbName, $collectionName, $mbaName) :)
  

(:kk:changeCurrentStatus($dbName, $collectionName, $mbaName), kk:removeCurrentExternalEvent($dbName, $collectionName, $mbaName), kk:processEventlessTransitions($dbName, $collectionName, $mbaName) :)
 


  return $loadNExtEvent

};

declare function kk:loadNextExternalEventuA($mba)
{
  copy $copymba := $mba
  modify
  (
    let $queue := mba:getExternalEventQueue($mba)
  let $nextEvent := ($queue/event)[1]
  let $nextEventName := <name xmlns="">{fn:string($nextEvent/@name)}</name>
  let $nextEventData := <data xmlns="">{$nextEvent/*}</data>
  let $currentEvent := mba:getCurrentEvent($mba)
  
  return (
    mba:removeCurrentEvent($copymba),
    if ($nextEvent) then insert node $nextEventName into $currentEvent else (),
    if ($nextEvent) then insert node $nextEventData into $currentEvent else (),
    mba:dequeueExternalEvent($copymba)
  )
)
return $copymba
};

declare function kk:donotUpdatetest($dbName,$collectionName, $mbaName)
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
  
  let $executableContent :=  fn:trace(kk:getExecutableContents($currentEmba)) 
  let $content :=  $executableContent[1]
(:     let $foldresults := fold-left($executableContent, $currentEmba, 
 
 function ($currentEmba, $content){ :)
 let $scxml := mba:getSCXML($currentEmba)
      
      let $configuration := mba:getConfiguration($currentEmba)
      let $dataModels := sc:selectDataModels($configuration)
     let $update := 
       typeswitch($content)
          case element(sc:assign) return 
            copy $copymba := $currentEmba
              modify 
              (
            sc:assign($dataModels, $content/@location, $content/@expr, $content/@type, $content/@attr, $content/*)
              )
              return $copymba
          case element(sync:newDescendant) return 
               
               let $name := $content/@name
             let $level := $content/@level
             let $parents := $content/@parents
             let $collection := mba:getCollection($dbName, $collectionName)
              let $nodelist := $content/*

        
        let $name := 
          if ($name) then sync:eval($name, $dataModels) 
          else functx:capitalize-first($level) || 
            count($collection/mba:mba[@topLevel = $level])
        
        let $parents := 
          if ($parents) then sync:eval($parents, $dataModels) else fn:string($currentEmba/@name)
          
       let $parentElements := 
          for $p in $parents return mba:getMBA($dbName, $collectionName, $p)
        
            
         let $new := mba:concretize($parentElements, $name, $level)
               
                

        return  copy $parentElementscopy := $parentElements
          modify 
          (
                insert node $new into 
               $parentElementscopy[1]/mba:concretizations
            ) 
            
            return $parentElementscopy


      default return (  1 + '2')

      
      
let $changestatusmba := kk:changeCurrentStatusoU($update)

let $currentExternalEventmba := kk:removeCurrentExternalEventuA($changestatusmba)

let $contentsevent := kk:getExecutableContentsEventless($currentExternalEventmba)

(:
let $foldfinal := fold-left($contentsevent, $currentExternalEventmba, function($mba, $content){ fn:trace(kk:runExecutableContentuA($mba, $content))})
let $final :=  kk:runExecutableContentuA($currentExternalEventmba, $contentsevent)
:)

let $result := kk:changeCurrentStatusEventlessuA($contentsevent)


  return $result


};


declare function kk:dowithRest($dbName,$collectionName, $mbaName)
{
 (: let $string := string-join(($dbName,$collectionName,$mbaName), '/' )
  let $url := 'http://localhost:8984/'
  
  let $f1  := doc(fn:concat($url, 'removeFromInsertLog/', $string ))
  let $f2  := doc(fn:concat($url, 'getNextExternalEvent/', $string ))

  let $f3  := doc(fn:concat($url, 'tryptoupdate/', $string ))
  let $f4  := doc(fn:concat($url, 'changeCurrentStatus/', $string ))
  let $f5  := doc(fn:concat($url, 'removeCurrentExternalEvent/', $string ))

  let $f7  := doc(fn:concat($url, 'processEventlessTransitions/', $string ))

return mba:getMBA($dbName, $collectionName, $mbaName)

:)

let $string := string-join(($dbName,$collectionName,$mbaName), '/' )

let $url := 'http://localhost:8984/'




(:let $f1  := doc(fn:concat($url, 'removeFromInsertLog/', $string )):)
return doc('http://localhost:8984/removeFromInsertLog/myMBAse/JohannesKeplerUniversity/InformationSystems'),
 mba:getMBA($dbName, $collectionName, $mbaName)


};


declare function kk:getResult($dbName,$collectionName, $mbaName,$id)
{


    let $mba := mba:getMBA($dbName, $collectionName, $mbaName)
   return $mba/mba:topLevel/mba:elements/sc:scxml/sc:datamodel/sc:data[@id='_x']/response/response[@ref=$id]

};


declare function kk:getCounter($dbName,$collectionName,$mbaName)
{
    let $mba := mba:getMBA($dbName, $collectionName, $mbaName)
     return $mba/*/*/sc:scxml/sc:datamodel/sc:data[@id='_x']/response/counter/text()
};

declare updating function kk:updateCounter($dbName,$collectionName,$mbaName)
{
  
    let $mba := mba:getMBA($dbName, $collectionName, $mbaName)
  let $oldValue :=   $mba/*/*/sc:scxml/sc:datamodel/sc:data[@id='_x']/response/counter/text()
  let $newCounter := <counter>{$oldValue + 1}</counter>
  return replace value of node   $mba/*/*/sc:scxml/sc:datamodel/sc:data[@id='_x']/response/counter with $newCounter
};



  (:if ($nextEvent) then insert node $nextEventName into $currentEvent else (),
  
(:

let $database := "myMBAse",
$collections := "JohannesKeplerUniversity",
$mbas := kk:getNewMultilevelBusinessArtifacts($database,$collections)
for $name in $mbas/@name
return kk:initMBA($database,$collections,$name)

let $updatedmbas := kk:getupdatedMBAS($database,$collections)
return $updatedmbas 
return kk:tostep($database, $collections):) :) 