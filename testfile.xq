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
 
 let $transitions := 
 mba:getCurrentTransitionsQueue($mba)/transitions/*
 
 
let $configuration := mba:getConfiguration($mba)
 
let $exitSet :=  sc:computeExitSet2($configuration,$transitions)



let $entrySet := if (not (fn:empty(sc:computeEntry($transitions)))) then 
 map:get(sc:computeEntry($transitions)[1],'statesToEnter')
 else
 ()


let $ids := functx:value-intersect($exitSet/@id, $entrySet/@id)

let $exitSet := $exitSet[not (@id=$ids)]


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

let $transitions := 
(
switch($transType)
case('external')
 return 
  sc:selectTransitions($configuration, $dataModels, $eventName)
case('internal')
return 
  sc:selectTransitions($configuration, $dataModels, $eventName)
case('eventless')
  return 
  sc:selectEventlessTransitions($configuration, $dataModels)
default
  return ()
)



 let $mba   := mba:getMBA($dbName, $collectionName, $mbaName)
 
 let $transitions := 
 mba:getCurrentTransitionsQueue($mba)/transitions/*
 
 
let $configuration := mba:getConfiguration($mba)
 
let $exitSet :=  sc:computeExitSetTrans2($configuration,$transitions)



let $entrySet := if (not (fn:empty(sc:computeEntry($transitions)))) then 
 map:get(sc:computeEntry($transitions)[1],'statesToEnter')
 else
 ()


let $ids := functx:value-intersect($exitSet/@id, $entrySet/@id)

let $exitSet := $exitSet[not (@id=$ids)]


let $scxml := mba:getSCXML($mba)

let $configuration := mba:getConfiguration($mba)
let $dataModels := sc:selectDataModels($configuration)

return  kk:changeCurrentStatus($mba,(),$exitSet)