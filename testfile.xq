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

let $currentEvent := mba:getCurrentEvent($mba)

let $eventName    :=
$currentEvent/name

 let $mba   := mba:getMBA($dbName, $collectionName, $mbaName)
 
 let $transitions := 
 mba:getCurrentTransitionsQueue($mba)/transitions/*
 
 
let $configuration := mba:getConfiguration($mba)
 
let $exitSet :=  sc:computeExitSetTrans($configuration,$transitions)



let $entrySet := if (fn:empty($transitions)) then ()
  else
    let $statesToEnterStart := 
      for $t in $transitions
        return sc:getTargetStates($t)
    
    let $stateLists :=
      map:merge((
        map:entry('statesToEnter', ()),
        map:entry('statesForDefaultEntry', ()),
         map:entry('historyContent',())  
      ))
      
    let $addDescendants := fn:fold-left(?, $stateLists,
      function($stateListsResult, $s) {
        let $statesToEnter := 
          map:get($stateListsResult, 'statesToEnter')
        let $statesForDefaultEntry := 
          map:get($stateListsResult, 'statesForDefaultEntry')
           let $historyContent := 
          map:get($stateListsResult, 'historyContent')  
          
        let $f := function($statesToEnter, $statesForDefaultEntry,$historyContent) { 
          map:merge((
            map:entry('statesToEnter', $statesToEnter),
            map:entry('statesForDefaultEntry', $statesForDefaultEntry),
         map:entry('historyContent',$historyContent)  
          ))
        }
        
        return
          sc:addDescendantStatesToEnter($s, $statesToEnter, $statesForDefaultEntry, $f, $historyContent)
      }
    )
    
    let $stateLists := $addDescendants($statesToEnterStart)
   
    let $stateLists := 
      (
       for $t in $transitions
         let $ancestor := sc:getTransitionDomainTrans($t)
         let $addAncestors := fn:fold-left(?, $stateLists,
           function($stateListsResult, $s) {
             let $statesToEnter := 
               map:get($stateListsResult, 'statesToEnter')
             let $statesForDefaultEntry := 
               map:get($stateListsResult, 'statesForDefaultEntry')
                let $historyContent := 
          map:get($stateListsResult, 'historyContent')  
              
             let $f := function($statesToEnter, $statesForDefaultEntry,$historyContent) { 
               map:merge((
                 map:entry('statesToEnter', $statesToEnter),
                 map:entry('statesForDefaultEntry', $statesForDefaultEntry),
                 map:entry('historyContent', $historyContent)
               ))
             }
             
             return
               sc:addAncestorStatesToEnter($s, $ancestor, $statesToEnter, $statesForDefaultEntry, $f, $historyContent)
           }
         )
         
         for $s in sc:getTargetStates($t)
           return $addAncestors($s)
      )

    return $stateLists

return $entrySet