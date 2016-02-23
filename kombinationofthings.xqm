module namespace kk = 'http://www.w3.org/2005/07/kk';
import module namespace scx='http://www.w3.org/2005/07/scxml/extension/';
import module namespace functx = 'http://www.functx.com';
import module namespace mba='http://www.dke.jku.at/MBA'; 
import module namespace sc = 'http://www.w3.org/2005/07/scxml';
import module namespace sync = 'http://www.dke.jku.at/MBA/Synchronization';





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
  return  mba:init($mba), kk:removeFromUpdateLog($dbName,$collectionName,$mbaName)
};


declare updating function kk:initSCXMLRest($dbName,$collectionName,$mbaName as xs:string)
{
  
  let $mba   := mba:getMBA($dbName, $collectionName, $mbaName)
let $scxml := mba:getSCXML($mba)

let $configuration := mba:getConfiguration($mba)


(: if not initialState enter First State  :)
return
  if (not ($configuration)) then 
  

    mba:addCurrentStates($mba, map:get(sc:computeEntryInit($scxml)[1],'statesToEnter'))
  else ()

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


declare updating function kk:getNextInternalEvent($dbName,$collectionName,$mbaName)
{
let $mba := mba:getMBA($dbName, $collectionName, $mbaName)
return mba:loadNextInternalEvent($mba)
};

declare function kk:getExecutableContents($dbName, $collectionName, $mbaName)
{

let $mba   := mba:getMBA($dbName, $collectionName, $mbaName)
let $scxml := mba:getSCXML($mba)

let $configuration := mba:getConfiguration($mba)
let $dataModels := sc:selectDataModels($configuration)


let $transitions := 
 mba:getCurrentTransitionsQueue($mba)/transitions/*
  
let $contents :=
  for $t in $transitions
    return $t/*
    
    


let $exitSet := sc:computeExitSetTrans($configuration,$transitions)


let $onExit := for $s in $exitSet
return $s/sc:onexit/reverse(*)


let $exitContents := $onExit


                  
(: TODO entryContents erweitern:)


let $entrySet := if (not (fn:empty(sc:computeEntry($transitions)))) then 
 map:get(sc:computeEntry($transitions)[1],'statesToEnter')
 else
 ()




let $content1 := 
for $s in $entrySet
return ($s/sc:onentry/*,$s/sc:initial/sc:transition/*)


let $content2 :=
if (not (fn:empty(sc:computeEntry($transitions)))) then 
 map:get(sc:computeEntry($transitions)[1],'historyContent')
 else
 ()


(: there has to be done more

 for content in s.onentry.sort(documentOrder):
            executeContent(content)
        if statesForDefaultEntry.isMember(s):
            executeContent(s.initial.transition)
        if defaultHistoryContent[s.id]:
            executeContent(defaultHistoryContent[s.id]) 
            
            :)

let $entryContents := ($content1,$content2)

return  ($exitContents,$contents,$entryContents)
};


declare function kk:getExecutableContentsEnter($dbName, $collectionName, $mbaName)
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
    

let $entrySet := if (not (fn:empty(sc:computeEntry($transitions)))) then 
 map:get(sc:computeEntry($transitions)[1],'statesToEnter')
 else
 ()


let $onentry := $entrySet/sc:onentry/*


let $defaultEntrycontent := 
for $s in $entrySet 
return $s


let $HistoryContent := 
for $s in $entrySet 
return 
if(fn:empty (sc:getHistoryStates($s))) then 
 $s/*
else
()


return ($onentry,$defaultEntrycontent, $HistoryContent)
  
(:

 statesToEnter = new OrderedSet()
    statesForDefaultEntry = new OrderedSet()
    // initialize the temporary table for default content in history states
    defaultHistoryContent = new HashTable() 
    computeEntrySet(enabledTransitions, statesToEnter, statesForDefaultEntry, defaultHistoryContent) 
   
    for s in statesToEnter.toList().sort(entryOrder):
        configuration.add(s)
        statesToInvoke.add(s)
        if binding == "late" and s.isFirstEntry:
            initializeDataModel(datamodel.s,doc.s)
            s.isFirstEntry = false
            
            
        for content in s.onentry.sort(documentOrder):
            executeContent(content)
        if statesForDefaultEntry.isMember(s):
            executeContent(s.initial.transition)
        if defaultHistoryContent[s.id]:
            executeContent(defaultHistoryContent[s.id]) 
        
 
 :)

};




declare updating function kk:runExecutableContent($dbName, $collectionName, $mbaName , $content)
{


let $mba   := mba:getMBA($dbName, $collectionName, $mbaName)
let $scxml := mba:getSCXML($mba)

let $configuration := mba:getConfiguration($mba)
let $dataModels := sc:selectDataModels($configuration)
let $counter := 
if(fn:empty( mba:getCurrentEvent($mba)/data/id/text())) then 
mba:getCounter($mba) -1 
else
 mba:getCurrentEvent($mba)/data/id/text()

return 
  typeswitch($content)
    case element(sc:assign) return 
    
    if (not(fn:empty($dataModels/sc:data[@id=substring($content/@location,2)]))) then 
     (:  sc:selectDataModels($configuration)/sc:data[@id="degree"] :)
      sc:assign($dataModels, $content/@location, $content/@expr, $content/@type, $content/@attr, $content/*, $dbName, $collectionName, $mbaName)
      else
           let $event := <event name="error.execution" xmlns=""></event>           
           return mba:enqueueInternalEvent($mba,$event)
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
        sc:getValue($dataModels, $content/@location, $content/@expr, $content/@type, $content/@attr, $content/*,$counter)
     case element(sc:log) return
         sc:log($dataModels,$content/@expr,$content/*,$counter)
   case element(sc:raise) return
          let $event := <event name="{$content/@event}" xmlns=""></event>           
           return mba:enqueueInternalEvent($mba,$event)
   
     case element(sc:script) return
           () (: TODO: has to be implementent:)
     case element(sc:send) return
            if(not ($content/@target) and not ($content/@targetexpr)) then 

         let $event := <event name="{$content/@event}" xmlns=""></event>           
           return mba:enqueueExternalEvent($mba,$event)
        else
        
           
           
           (:TODO :)
     (:can also be a raise:)
            (: see sendDescendants External ?  TODO: has to be implementent:)
           (: use addEvent:)()
           
      case element(sc:cancel) return
           () (: TODO: has to be implementent:)
        case element(sc:if) return
     () (:TODO has d:)
     
     case element(sc:foreach) return
           () (: TODO: has to be implementent:)     

    default return ()
};




(:
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

};:)



declare updating function kk:changeCurrentStatus($mba,$entrySet,$exitSet)
{


 (
  mba:removeCurrentStates($mba, $exitSet),
  mba:addCurrentStates($mba, $entrySet)
)



};




declare updating function kk:removeCurrentExternalEvent($dbName, $collectionName, $mbaName)
{
 

let $mba := mba:getMBA($dbName, $collectionName, $mbaName)

return mba:removeCurrentEvent($mba)




};








declare function kk:getExecutableContentsEventless($dbName, $collectionName, $mbaName)
{
let $mba   := mba:getMBA($dbName, $collectionName, $mbaName)
let $scxml := mba:getSCXML($mba)

let $configuration := mba:getConfiguration($mba)
let $dataModels := sc:selectDataModels($configuration)



let $transitions := 
 mba:getCurrentTransitionsQueue($mba)/transitions/*
      


let $contents :=
  for $t in $transitions
    return $t/*


let $exitSet :=  sc:computeExitSetTrans($configuration,$transitions)



let $onExit := for $s in $exitSet
return $s/sc:onexit/reverse(*)

 

(: TODO entryContents erweitern:)


let $entrySet := if (not (fn:empty(sc:computeEntry($transitions)))) then 
 map:get(sc:computeEntry($transitions)[1],'statesToEnter')
 else
 ()

let $content1 := 
for $s in $entrySet
return ($s/sc:onentry/*,$s/sc:initial/sc:transition/*)


let $content2 :=

if (not (fn:empty(sc:computeEntry($transitions)))) then 
 map:get(sc:computeEntry($transitions)[1],'historyContent')
 else
 ()
 



(: TODO  there has to be done more

 for content in s.onentry.sort(documentOrder):
            executeContent(content)
        if statesForDefaultEntry.isMember(s):
            executeContent(s.initial.transition)
        if defaultHistoryContent[s.id]:
            executeContent(defaultHistoryContent[s.id]) 
            
            :)

let $entryContents := ($content1,$content2)
let $exitContents := $onExit

return  ($exitContents,$contents,$entryContents)
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
let $entrySet := if (not (fn:empty(sc:computeEntry($transitions)))) then 
 map:get(sc:computeEntry($transitions)[1],'statesToEnter')
 else
 ()

return (
  mba:removeCurrentStates($mba, $exitSet),
  mba:addCurrentStates($mba, $entrySet)
)
};




declare updating function kk:getandExecuteExecutablecontent($dbName, $collectionName, $mbaName,$counter)
{
  let $content := kk:getExecutableContents($dbName, $collectionName, $mbaName)
  return kk:runExecutableContent($dbName, $collectionName, $mbaName, $content[$counter])
};



declare updating function kk:executeExecutablecontent($dbName, $collectionName, $mbaName,$content,$counter)
{
  kk:runExecutableContent($dbName, $collectionName, $mbaName, $content[$counter])
};




(: getExecutableContentsEventless runExecutableContent changeCurrentStatusEventless :)
declare updating function kk:getAndExecuteEventlessTransitions($dbName, $collectionName, $mbaName,$counter)
{
  let $executableContents := kk:getExecutableContentsEventless($dbName, $collectionName, $mbaName)
  return kk:runExecutableContent($dbName, $collectionName, $mbaName, $executableContents[$counter])
  
};

declare updating function kk:removeFromUpdateLog($dbName, $collectionName, $mbaName)
{
  
  let $mba := mba:getMBA($dbName, $collectionName, $mbaName)
return mba:removeFromUpdateLog($mba)
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

 
 


declare updating function kk:dequeueExternalEvent($mba as element()) {
  let $queue := mba:getExternalEventQueue($mba)
  
  return delete node ($queue/*)[1]
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




declare function kk:eventlessTransitions($mba)
{
  let $contents := kk:getExecutableContentsEventless($mba)
 (: let $mba := kk:runExecutableContent($mba):) 
  return $contents
  
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





declare updating function kk:exitStates($dbName,$collectionName,$mbaName,$type)
{
  
  
  
let $mba   := mba:getMBA($dbName, $collectionName, $mbaName)
let $scxml := mba:getSCXML($mba)

let $currentEvent := mba:getCurrentEvent($mba)
let $eventName    := $currentEvent/name

let $configuration := mba:getConfiguration($mba)
let $dataModels := sc:selectDataModels($configuration)


 let $transitions := 
 mba:getCurrentTransitionsQueue($mba)/transitions/*
 
 
let $configuration := mba:getConfiguration($mba)
 
let $exitSet :=  sc:computeExitSetTrans($configuration,$transitions)


(: remove from States to Invoke:)
(:TODO Anschauen exitOrder -> reverted Documentorder:)
(: configuration will be done after enterStates:)





for $state in reverse($exitSet)

 for $h in $state/sc:history
  let $insert := 
  
  for $i in  $configuration
  return 
(:for $h in kk:getStateHistoryNodes($state):)
if ($h/@type = 'deep') then 
  if(sc:isDescendant($i,$state) and sc:isAtomicState($i) and not (fn:deep-equal($i,$state))) then
      <state ref="{$i/@id}"/>
  else ()
else
  if(fn:deep-equal($h/parent::*,$i/parent::*)) then 
      <state ref="{$i/@id}"/> 
else ()


return 
  if (fn:empty(sc:getHistoryStates($h))) then
 insert node <history ref = "{$h/@id}">{$insert}</history> into mba:getHistory($mba)

else
replace node mba:getHistory($mba)/history[@ref=$h/@id]  with <history ref = "{$h/@id}">{$insert}</history> 


};



declare updating function kk:enterStates($dbName,$collectionName,$mbaName,$type)
{
 
  
let $mba   := mba:getMBA($dbName, $collectionName, $mbaName)
let $scxml := mba:getSCXML($mba)

let $currentEvent := mba:getCurrentEvent($mba)
let $eventName    := $currentEvent/name

let $configuration := mba:getConfiguration($mba)
let $dataModels := sc:selectDataModels($configuration)


let $transitions := 
 mba:getCurrentTransitionsQueue($mba)/transitions/*
  
let $entrySet  := if($type = 'init') then
map:get(sc:computeEntryInit($scxml)[1],'statesToEnter')
else 
if (not (fn:empty(sc:computeEntry($transitions)))) then 
 map:get(sc:computeEntry($transitions)[1],'statesToEnter')
 else
 ()

for $state in  $entrySet
return
if (sc:isFinalState($state)) then 
  
  if (fn:empty($state/parent::sc:scxml)) then
  
  
   let $parent:= $state/parent::*
   let $grandparent := $parent/parent::*
   let $eventname := "done.state." || $parent/@id

    let $doneData := for $data in $state/sc:donedata/*
                     return <data> {fn:string( $data/@expr)}</data>
   let $event := <event name="{$eventname}">{$doneData} </event> (:TODO donedata:)


   return 
     if(sc:isParallelState($grandparent)) then 
                 
        if (every $s in sc:getChildStates($grandparent) satisfies sc:isInFinalState($s,$configuration,$entrySet)) then
          
          let $parallelEventName := "done.state." || $grandparent/@id
            let $parallelEvent := <event name="{$parallelEventName}">  </event> 
            return
          (mba:enqueueInternalEvent($mba,$event),mba:enqueueInternalEvent($mba,$parallelEvent))

else
  mba:enqueueInternalEvent($mba,$event)    
    
   else
      mba:enqueueInternalEvent($mba,$event)                 
   
  else
  ()
else
()

};

