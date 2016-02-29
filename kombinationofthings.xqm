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
    
    


let $exitSet := reverse(mba:getCurrentExitSet($mba))


let $onExit := for $s in $exitSet
return $s/sc:onexit/reverse(*)


let $exitContents := $onExit


                  
(: TODO entryContents erweitern:)



(: there has to be done more

 for content in s.onentry.sort(documentOrder):
            executeContent(content)
        if statesForDefaultEntry.isMember(s):
            executeContent(s.initial.transition)
        if defaultHistoryContent[s.id]:
            executeContent(defaultHistoryContent[s.id]) 
            
            :)



return  ($exitContents,$contents)
};






declare updating function kk:runExecutableContent($dbName, $collectionName, $mbaName , $content)
{


let $mba   := mba:getMBA($dbName, $collectionName, $mbaName)
let $scxml := mba:getSCXML($mba)

let $configuration := mba:getConfiguration($mba)
let $dataModels := sc:selectAllDataModels($mba)
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
     let $test := fn:trace('something')
     return 
      sc:assign($dataModels, $content/@location, $content/@expr, $content/@type, $content/@attr, $content/*, $dbName, $collectionName, $mbaName)
      else
        let $test := fn:trace('someelse')
           let $event := <event name="error.execution" type="platform" xmlns=""></event>           
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
         sc:log($dataModels,$content/@expr,$content/@label, $content/*,$counter,  $dbName, $collectionName, $mbaName)
   case element(sc:raise) return
          let $event := <event name="{$content/@event}" type="internal" xmlns=""></event>           
           return mba:enqueueInternalEvent($mba,$event)
   
     case element(sc:script) return
           () (: TODO: has to be implementent:)
     case element(sc:send) return
     
      let $test := fn:trace("sc:send")
      return 
      
       let $eventtext := if (fn:empty($content/@event)) then 
            if(fn:empty($content/@eventexpr)) then 
            ()
            else 
        sc:eval($content/@eventexpr, $dataModels)
        else 
        $content/@event
 let $location := if (fn:empty($content/@target)) then
   if(fn:empty($content/@targetexpr)) then 
            ()
            else 
      sc:eval($content/@targetexpr,$dataModels)
      else
      $content/@target 
      
      
        let $test := fn:trace($content/sc:param, "params1")
      let $params :=
      
         for $p in $content/sc:param
         return 
         element {$p/@name}{sc:eval($p/@expr, $dataModels)}
       
       let $test := fn:trace($params, "params")
       
         
         
         
      let $eventbody := 
      ($params, 
       $content/sc:content/text())
        
        let $test := fn:trace($eventbody, "sc:send")
        
        
        
        return 
            if(not ($location) or $location = '#_internal') then 
        let $test := fn:trace($eventtext, "eventText")
         let $event := <event name="{$eventtext}" type="internal" xmlns=""> {$eventbody}</event>           
           return mba:enqueueExternalEvent($mba,$event)
        else
        
           
           
           (:TODO :)
     (:can also be a raise:)
            (: see sendDescendants External ?  TODO: has to be implementent:)
           (: use addEvent:)()
           
      case element(sc:cancel) return
           () (: TODO: has to be implementent:)
        case element(sc:if) return
     
let $ifcontent :=  
if (sc:evaluateCond($content/@cond, $dataModels)) then 
let $til :=
if(fn:empty($content/sc:elseif)) then 
$content/sc:else
else $content/sc:elseif

let $index := 
try
{functx:index-of-node($content/*,$til)
}
catch *
{

  fn:count($content/*)+1
  
}


return $content/*[fn:position()<$index]
else
(: finde das erste elseif das ok ist. :)
  let $elseifs := $content/*[self::sc:elseif and sc:evaluateCond(./@cond, $dataModels)][1]
   return
 if(not(fn:empty($elseifs))) then 
 
  let $til :=  $elseifs/following-sibling::node()[(self::sc:elseif or self::sc:else)][1]
  let $index := functx:index-of-node($elseifs/following-sibling::node(),$til)
return
 $elseifs/following-sibling::node()[fn:position()<$index]
 
 else
  $content/*[self::sc:else]/following-sibling::node()
  for $c in $ifcontent 
  return  kk:runExecutableContent($dbName, $collectionName, $mbaName , $c)
     
     case element(sc:foreach) return
     ()
            (: TODO: has to be implementent:)     

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








declare function kk:getExecutableContentsEnter($dbName, $collectionName, $mbaName)
{
let $mba   := mba:getMBA($dbName, $collectionName, $mbaName)
let $scxml := mba:getSCXML($mba)

let $configuration := mba:getConfiguration($mba)
let $dataModels := sc:selectDataModels($configuration)



let $transitions := 
 mba:getCurrentTransitionsQueue($mba)/transitions/*
      

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
 

return  ($content1,$content2)
};



declare function kk:getExecutableContentsEnter($dbName, $collectionName, $mbaName, $state, $historyContent)
{
let $mba   := mba:getMBA($dbName, $collectionName, $mbaName)
let $scxml := mba:getSCXML($mba)

let $configuration := mba:getConfiguration($mba)
let $dataModels := sc:selectDataModels($configuration)


let $transitions := 
 mba:getCurrentTransitionsQueue($mba)/transitions/*
      

let $content1 := 

($state/sc:onentry/*,$state/sc:initial/sc:transition/*)


let $content2 :=

$historyContent
 

return  ($content1,$content2)
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




(: getExecutableContentsEventless runExecutableContent changeCurrentStatusEventless 
declare updating function kk:getAndExecuteEventlessTransitions($dbName, $collectionName, $mbaName,$counter)
{
  let $executableContents := kk:getExecutableContentsEventless($dbName, $collectionName, $mbaName)
  return kk:runExecutableContent($dbName, $collectionName, $mbaName, $executableContents[$counter])
  
};
:)
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
 (insert node <history ref = "{$h/@id}">{$insert}</history> into mba:getHistory($mba), mba:removestatesToInvoke($mba,$exitSet))

else
(replace node mba:getHistory($mba)/history[@ref=$h/@id]  with <history ref = "{$h/@id}">{$insert}</history> , mba:removestatesToInvoke($mba,$exitSet))


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


 let $params :=
      
         for $p in $state/sc:donedata/sc:param
         return 
         element {$p/@name}{sc:eval($p/@expr, $dataModels)}
       
       let $test := fn:trace($params, "params")
       
         
 let  $content :=
 
    for $c in $state/sc:donedata/sc:content
    return 
    if ($c/@expr) then
     <data> (:{sc:eval($c/@expr,$dataModels)}:) 'blub'</data> 
     
     else <data>(:{$c/content/*}:) 'nas'</data>    
         
     (: let $eventbody := 
      ($params, 
       $state/sc:donedata/sc:content/text())
       
       
    let $doneData := for $data in $state/sc:donedata/*
                     return <data> {fn:string( $data/@expr)}</data>:)
                     
                     
    let $test:= ($params,$content)                 
   let $event := <event name="{$eventname} " type="platform">{ $test} </event> (:TODO donedata:)


   return 
     if(sc:isParallelState($grandparent)) then 
                 
        if (every $s in sc:getChildStates($grandparent) satisfies sc:isInFinalState($s,$configuration,$state)) then
          
          let $parallelEventName := "done.state." || $grandparent/@id
            let $parallelEvent := <event name="{$parallelEventName}">  </event> 
            return
          (mba:enqueueInternalEvent($mba,$event),mba:enqueueInternalEvent($mba,$parallelEvent),  mba:addstatesToInvoke($mba,$state), kk:initDatamodel($state,$mba))

else
  (mba:enqueueInternalEvent($mba,$event) , mba:addstatesToInvoke($mba,$state) , kk:initDatamodel($state,$mba)  )
    
   else
   (   mba:enqueueInternalEvent($mba,$event)  ,  mba:addstatesToInvoke($mba,$state), kk:initDatamodel($state,$mba)         )      
   
  else
  ( mba:addstatesToInvoke($mba,$state), kk:initDatamodel($state,$mba))
else
( mba:addstatesToInvoke($mba,$state), kk:initDatamodel($state,$mba))

};



declare updating function kk:enterStatesSingle($dbName,$collectionName,$mbaName,$state as element())
{
 
  
let $mba   := mba:getMBA($dbName, $collectionName, $mbaName)
let $scxml := mba:getSCXML($mba)

let $currentEvent := mba:getCurrentEvent($mba)
let $eventName    := $currentEvent/name

let $configuration := mba:getConfiguration($mba)
let $dataModels := sc:selectDataModels($configuration)


return
if (sc:isFinalState($state)) then 
  
  if (fn:empty($state/parent::sc:scxml)) then
  
  
   let $parent:= $state/parent::*
   let $grandparent := $parent/parent::*
   let $eventname := "done.state." || $parent/@id


 let $params :=
      
      try
 {
   
         for $p in $state/sc:donedata/sc:param
         return 
         element {$p/@name}{sc:eval($p/@expr, $dataModels)}
       
}
catch *
{
    let $test := fn:trace("errorinContent")   
  return $err:code
  
}   
       

  let $content :=

 try
 {
    for $c in $state/sc:donedata/sc:content
    return 
    if ($c/@expr) then
     <data> {sc:eval($c/@expr,$dataModels)}</data> 
     
     else 
     <data>{$c/text()}</data>    
         
}
catch *
{
    let $test := fn:trace("errorinContent")   
  return $err:code
  
}  

 
let $error
:=
if (fn:matches(fn:string($content),'^err:') ) then 
 fn:true()
else 
 fn:false()
 
 
 let $errorParams
:=
if (fn:matches(fn:string($params),'^err:') ) then 
 fn:true()
else 
 fn:false()


let $content := 
       if ($error) then 
       ()
       else
       $content
       
     let $eventError := <event name="error.execution" type="platform" xmlns=""></event>           
            

let $params := 
       if ($errorParams) then 
       ()
       else
       $params
       
     let $eventError := <event name="error.execution" type="platform" xmlns=""></event>                 
                    
      let $eventbody := 
      ($params, 
       $state/sc:donedata/sc:content/text())
       
       
   (: let $doneData := for $data in $state/sc:donedata/*
                     return <data> {fn:string( $data/@expr)}</data>:)
                     
                     
    let $test:= ($params,$content)                 
   let $event := <event name="{$eventname}" type="platform">{ $test} </event> (:TODO donedata:)


   return 
     if(sc:isParallelState($grandparent)) then 
                 
        if (every $s in sc:getChildStates($grandparent) satisfies sc:isInFinalState($s,$configuration,$state)) then
          
          let $parallelEventName := "done.state." || $grandparent/@id
            let $parallelEvent := <event name="{$parallelEventName}" type="platform">  </event> 
            return
          if ($error or $errorParams) then 
          (mba:enqueueInternalEvent($mba,$eventError), mba:enqueueInternalEvent($mba,$event),mba:enqueueInternalEvent($mba,$parallelEvent),  mba:addstatesToInvoke($mba,$state), kk:initDatamodel($state,$mba),  mba:addCurrentStates($mba, $state))
          
          else 
          
            (mba:enqueueInternalEvent($mba,$event),mba:enqueueInternalEvent($mba,$parallelEvent),  mba:addstatesToInvoke($mba,$state), kk:initDatamodel($state,$mba),  mba:addCurrentStates($mba, $state))
            

else
  if ($error or $errorParams) then 
  (mba:enqueueInternalEvent($mba,$eventError), mba:enqueueInternalEvent($mba,$event) , mba:addstatesToInvoke($mba,$state) , kk:initDatamodel($state,$mba) ,  mba:addCurrentStates($mba, $state) )
   else 
     (mba:enqueueInternalEvent($mba,$event) , mba:addstatesToInvoke($mba,$state) , kk:initDatamodel($state,$mba) ,  mba:addCurrentStates($mba, $state) )
 
   else
     if ($error or $errorParams) then 
     
   (mba:enqueueInternalEvent($mba,$eventError),    mba:enqueueInternalEvent($mba,$event)  ,  mba:addstatesToInvoke($mba,$state), kk:initDatamodel($state,$mba) ,  mba:addCurrentStates($mba, $state)        )   
     else   
      (   mba:enqueueInternalEvent($mba,$event)  ,  mba:addstatesToInvoke($mba,$state), kk:initDatamodel($state,$mba) ,  mba:addCurrentStates($mba, $state)        )  
   
  else
  
  ( mba:addstatesToInvoke($mba,$state), kk:initDatamodel($state,$mba),  mba:addCurrentStates($mba, $state))
else
( mba:addstatesToInvoke($mba,$state), kk:initDatamodel($state,$mba),  mba:addCurrentStates($mba, $state))

};





declare updating function kk:initDatamodel($states,$mba)
{
  
  let $scxml := mba:getSCXML($mba)
let $configuration := mba:getConfiguration($mba)
let $dataModels := sc:selectDataModels($configuration)

let $test := fn:trace('isinInit')
return
if ($scxml/@binding='late' ) then 

  for $s in $states
  let $data := $s/sc:datamodel/*
  let $test := fn:trace($data,'dataisinInit')
  for $d in $data 
  return 
   

if ($d/@expr) then
(try
         {
           let $value := sc:eval($d/@expr,$dataModels)
           let $test := fn:trace("hallo")
           return insert node <data id="{$d/@id}">{$value} </data> into $s/sc:datamodel, delete node $d
            
         } 
         catch *
         {
            let $test := fn:trace("hallo2")
            let $event := <event name="error.execution" type="platform" xmlns=""></event>           
           return mba:enqueueInternalEvent($mba,$event), insert node <data id="{$d/@id}"></data> into $s/sc:datamodel, delete node $d
           
         })

else if($d/@src)  then
(try
         {
           let $value :=  
           if (fn:substring-before($d/@src, ':') = 'file') then 
           
             let $test := fn:trace("hallofile")
          return fn:unparsed-text(fn:substring-after($d/@src,':'))
          else
          ()
           
           let $test := fn:trace("hallo")
           return insert node <data id="{$d/@id}">{$value} </data> into $scxml/sc:datamodel, delete node $d
            
         } 
         catch *
         {
            let $test := fn:trace("hallo2")
            let $event := <event name="error.execution" type="platform" xmlns=""></event>           
           return mba:enqueueInternalEvent($mba,$event), insert node <data id="{$d/@id}"></data> into $scxml/sc:datamodel, delete node $d
           
         })
         
else       
  let $test := fn:trace('no expr')
  return ()

else
 let $test := fn:trace('no latebinding')
 return ()
  
};
