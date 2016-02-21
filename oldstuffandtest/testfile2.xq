import module namespace kk = 'http://www.w3.org/2005/07/kk';
import module namespace scx='http://www.w3.org/2005/07/scxml/extension/';
import module namespace functx = 'http://www.functx.com';
import module namespace mba='http://www.dke.jku.at/MBA'; 
import module namespace sc = 'http://www.w3.org/2005/07/scxml';
import module namespace sync = 'http://www.dke.jku.at/MBA/Synchronization';


declare variable $dbName := 'myMBAse';
declare variable $collectionName := 'JohannesKeplerUniversity';
declare variable $mbaName := 'InformationSystems';
declare variable $transType := 'internal';


let $mba   := mba:getMBA($dbName, $collectionName, $mbaName)
let $scxml := mba:getSCXML($mba)

let $configuration := mba:getConfiguration($mba)
let $dataModels := sc:selectDataModels($configuration)

let $currentEvent := mba:getCurrentEvent($mba)

let $eventName    :=
$currentEvent/name


let $mba   := mba:getMBA($dbName, $collectionName, $mbaName)
let $scxml := mba:getSCXML($mba)

let $configuration := mba:getConfiguration($mba)
let $dataModels := sc:selectDataModels($configuration)


let $transitions := 
 mba:getCurrentTransitionsQueue($mba)/transitions/*
  
let $contents :=
  for $t in $transitions
    return $t/*
    
    
let $mba   := mba:getMBA($dbName, $collectionName, $mbaName)
let $scxml := mba:getSCXML($mba)

let $configuration := mba:getConfiguration($mba)
let $dataModels := sc:selectDataModels($configuration)

let $currentEvent := mba:getCurrentEvent($mba)

let $eventName    :=
$currentEvent/name

let $event := $eventName
let $transitions := 

 if (fn:empty($event)) then 
  ()
 else
  let $atomicStates :=
    $configuration[sc:isAtomicState(.)]
  
  let $dataBindings :=
    for $dataModel in $dataModels
      for $data in $dataModel/sc:data
        return map:entry($data/@id, $data)
  
  let $declare :=
    for $dataModel in $dataModels
      for $data in $dataModel/sc:data
        return 
          'declare variable $' || $data/@id || ' external; '
        
  let $enabledTransitions :=
    for $state in $atomicStates 
      return ('hallo',$state, sc:getProperAncestors($state))

      
      
  return $enabledTransitions
    return $transitions
  
  
  (: let $transitions :=
        
        
         for $t in $s/sc:transition
         let $evaluation := try
         {
            xquery:eval(scx:importModules() ||
                        fn:string-join($declare) || 
                        scx:builtInFunctionDeclarations() ||
                       'return ' || $t/@cond, 
                       map:merge($dataBindings))
         } 
         catch *
         {
           fn:false()
         }
         return
         
         if((sc:matchesEventDescriptors(
                             $event,
                             fn:tokenize($t/@event, '\s')
                           ) and (not($t/@cond) or
                                 $evaluation )) )then 
                           $t
                       
                           
                           else
                           ()
                            
      return $transitions[1]
  
  return sc:removeConflictingTransitions($configuration,$enabledTransitions)
  
  
  :)