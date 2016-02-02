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

return  ($exitContents,$contents,$entryContents)
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




declare updating function kk:getandExecuteExecutablecontent($dbName, $collectionName, $mbaName,$counter)
{
  let $content := kk:getExecutableContents($dbName, $collectionName, $mbaName)
  return kk:runExecutableContent($dbName, $collectionName, $mbaName, $content[$counter])
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


declare function kk:getHistory($history, $state)
{
   return
};

declare function kk:getStateHistoryNodes($state)
{
  return
};



declare updating function kk:exitStates($dbName,$collectionName,$mbaName)
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

(:TODO Anschauen exitOrder -> reverted Documentorder:)

for $state in $exitSet 

 for $h in $state/sc:history
(:for $h in kk:getStateHistoryNodes($state):)
return if ($h/type = 'deep') then 

let $input := $configuration
let $newNode :=  <history ref = "{$h/@id}">{$input}</history>
return 
insert node $newNode into mba:getHistory($mba)

else
let $input := sc:getDescendantStates($state)
let $newNode :=  <history ref =  "{$h/@id}">{$input}</history>
return
insert node $newNode into mba:getHistory($mba)

 (:the list of all immediate children of s that are members of the current configuration:) 
 (: executeContent and delete from configuration probably later but could be done at least for executecontent :)
 (: for h in s.history do history:)
(:vermutlich müss mann da replace machen.. aber vorerst mal:)

(:if(kk:getHistory/@type = 'deep') then
insert node  <history ref="stateid"> 
              $configuration </history>into $history (: of all atomic descendants of s that are members in the current configuration :)       :)
};


declare updating function kk:exitStatesE($dbName,$collectionName,$mbaName)
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

(:TODO Anschauen exitOrder -> reverted Documentorder:)

for $state in $exitSet 

 for $h in $state/sc:history
(:for $h in kk:getStateHistoryNodes($state):)
return if ($h/type = 'deep') then 

let $newNode :=  <history ref = "{$h/@id}"> asdf</history>
return 
insert node $newNode into mba:getHistory($mba)

else
let $newNode :=  <history ref =  "{$h/@id}"> asdf</history>
return
insert node $newNode into mba:getHistory($mba)

 (:the list of all immediate children of s that are members of the current configuration:) 
 (: executeContent and delete from configuration probably later but could be done at least for executecontent :)
 (: for h in s.history do history:)
(:vermutlich müss mann da replace machen.. aber vorerst mal:)

(:if(kk:getHistory/@type = 'deep') then
insert node  <history ref="stateid"> 
              $configuration </history>into $history (: of all atomic descendants of s that are members in the current configuration :)       :)
};



declare updating function kk:enterStatesI($dbName,$collectionName,$mbaName)
{
  
  
  
let $mba   := mba:getMBA($dbName, $collectionName, $mbaName)
let $scxml := mba:getSCXML($mba)

let $currentEvent := mba:getCurrentEvent($mba)
let $eventName    := $currentEvent/name

let $configuration := mba:getConfiguration($mba)
let $dataModels := sc:selectDataModels($configuration)

let $history := mba:getHistory($mba)
let $transitions := 
  if($eventName) then
    sc:selectTransitions($configuration, $dataModels, $eventName)
  else ()
  
let $entrySet  := sc:computeEntrySet($transitions)

return ()



(: add to configuration -> I do that later :)
(:dataBinding ? :)
(:exeCuteContent of onEntry

and of Defaultentry and Defaulthistorycontent:)



(: :)

(: is it a Final State ? :)
(: if yes enqueue new internal Event and depending on add parallelFinalStates:)

        
        
};



declare updating function kk:enterStates($dbName,$collectionName,$mbaName)
{
  
  
  
let $mba   := mba:getMBA($dbName, $collectionName, $mbaName)
let $scxml := mba:getSCXML($mba)

let $currentEvent := mba:getCurrentEvent($mba)
let $eventName    := $currentEvent/name

let $configuration := mba:getConfiguration($mba)
let $dataModels := sc:selectDataModels($configuration)

let $history := mba:getHistory($mba)
let $transitions := 
  if($eventName) then
    sc:selectTransitions($configuration, $dataModels, $eventName)
  else ()
  
let $entrySet  := sc:computeEntrySet($transitions)

return ()


(: :)

(: is it a Final State ? :)
(: if yes enqueue new internal Event and depending on add parallelFinalStates

   
   First, compute the list of all the states that will be entered as a result of taking the transitions in enabledTransitions. Add them to statesToInvoke so that invoke processing can be done at the start of the next macrostep. Convert statesToEnter to a list and sort it in entryOrder. For each state s in the list, first add s to the current configuration. Then if we are using late binding, and this is the first time we have entered s, initialize its data model. Then execute any onentry handlers. If s's initial state is being entered by default, execute any executable content in the initial transition. If a history state in s was the target of a transition, and s has not been entered before, execute the content inside the history state's default transition. Finally, if s is a final state, generate relevant Done events. If we have reached a top-level final state, set running to false as a signal to stop processing.

procedure enterStates(enabledTransitions):
    statesToEnter = new OrderedSet()
    statesForDefaultEntry = new OrderedSet()
    // initialize the temporary table for default content in history states
    defaultHistoryContent = new HashTable() 
    computeEntrySet(enabledTransitions, statesToEnter, statesForDefaultEntry, defaultHistoryContent) 
   
    for s in statesToEnter.toList().sort(entryOrder):
         if binding == "late" and s.isFirstEntry:
            initializeDataModel(datamodel.s,doc.s)
            s.isFirstEntry = false
        for content in s.onentry.sort(documentOrder):
            executeContent(content)
        if statesForDefaultEntry.isMember(s):
            executeContent(s.initial.transition)
        if defaultHistoryContent[s.id]:
            executeContent(defaultHistoryContent[s.id]) 
        if isFinalState(s):
            if isSCXMLElement(s.parent):
                running = false
            else:
                parent = s.parent
                grandparent = parent.parent
                internalQueue.enqueue(new Event("done.state." + parent.id, s.donedata))
                if isParallelState(grandparent):
                    if getChildStates(grandparent).every(isInFinalState):
                        internalQueue.enqueue(new Event("done.state." + grandparent.id))     
        :)
};

