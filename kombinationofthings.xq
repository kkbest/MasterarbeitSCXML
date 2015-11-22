(:module namespace kk = 'http://www.w3.org/2005/07/kk';:)
import module namespace scx='http://www.w3.org/2005/07/scxml/extension/';
import module namespace functx = 'http://www.functx.com';
import module namespace mba='http://www.dke.jku.at/MBA'; 
import module namespace sc = 'http://www.w3.org/2005/07/scxml';
import module namespace sync = 'http://www.dke.jku.at/MBA/Synchronization';


declare updating function local:startProcess($dbName,$collectionName,$mbaName)
{
  
 let $mba   := mba:getMBA($dbName, $collectionName, $mbaName)
  let $scxml := mba:getSCXML($mba)
 
 return mba:init($mba)
};



declare function local:getNewMultilevelBusinessArtifacts($dbName, $collectionName)
{
  

let $document := db:open($dbName, 'collections.xml')
let $collectionEntry := $document/mba:collections/mba:collection[@name = $collectionName]

for $entry in $collectionEntry/mba:new/mba:mba
  return mba:getMBA($dbName, $collectionName, $entry/@ref)
};


declare updating function local:initMBA($dbName,$collectionName,$mbaName as xs:string)
{
  
  let $mba := mba:getMBA($dbName, $collectionName, $mbaName)
 let $scxml :=  mba:getSCXML($mba)
  return  mba:init(mba:getMBA($dbName, $collectionName, $mbaName)), local:initSCXML($dbName,$collectionName,$mbaName)

};


declare updating function local:initSCXML($dbName,$collectionName,$mbaName as xs:string)
{
  
  

let $mba   := mba:getMBA($dbName, $collectionName, $mbaName)
let $scxml := mba:getSCXML($mba)
let $configuration := mba:getConfiguration($mba)
return
  if (not ($configuration)) then 
    mba:addCurrentStates($mba, sc:getInitialStates($scxml))
  else ()
};

declare function local:getupdatedMBAS($dbName, $collectionName)
{
  let $document := db:open($dbName, 'collections.xml')
let $collectionEntry := $document/mba:collections/mba:collection[@name = $collectionName]

for $entry in $collectionEntry/mba:updated/mba:mba
  return mba:getMBA($dbName, $collectionName, $entry/@ref)

};


declare updating function local:removeFromInsertLog($dbName, $collectionName, $mbaName)
{
let $mba := mba:getMBA($dbName, $collectionName, $mbaName)
return mba:removeFromInsertLog($mba)
};

declare updating function local:getNextExternalEvent($dbName,$collectionName,$mbaName)
{
let $mba := mba:getMBA($dbName, $collectionName, $mbaName)
return mba:loadNextExternalEvent($mba)
};

declare function local:getExecutableContents($dbName, $collectionName, $mbaName)
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

return $contents
};

declare updating function local:runExecutableContent($dbName, $collectionName, $mbaName , $content)
{


let $mba   := mba:getMBA($dbName, $collectionName, $mbaName)
let $scxml := mba:getSCXML($mba)

let $configuration := mba:getConfiguration($mba)
let $dataModels := sc:selectDataModels($configuration)

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
    default return ()
};

declare updating function local:changeCurrentStatus($dbName, $collectionName, $mbaName)
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

declare updating function local:removeCurrentExternalEvent($dbName, $collectionName, $mbaName)
{
 

let $mba := mba:getMBA($dbName, $collectionName, $mbaName)

return mba:removeCurrentEvent($mba)

};

(: getExecutableContentsEventless runExecutableContent changeCurrentStatusEventless :)
declare updating function local:processEventlessTransitions($dbName, $collectionName, $mbaName)
{
  let $executableContents := local:getExecutableContentsEventless($dbName, $collectionName, $mbaName)
  for $content in $executableContents
  return local:runExecutableContent($dbName, $collectionName, $mbaName, $content),local:changeCurrentStatusEventless($dbName, $collectionName, $mbaName)
};

declare function local:getExecutableContentsEventless($dbName, $collectionName, $mbaName)
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

declare updating function local:changeCurrentStatusEventless($dbName, $collectionName, $mbaName)
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

declare updating function local:getandExecuteExecutablecontent($dbName, $collectionName, $mbaName)
{
  for $content in local:getExecutableContents($dbName, $collectionName, $mbaName)
  return local:runExecutableContent($dbName, $collectionName, $mbaName, $content)
};

declare updating function local:macrostep($dbName, $collectionName, $mbaName)
{
  
  local:removeFromInsertLog($dbName, $collectionName, $mbaName), local:getNextExternalEvent($dbName, $collectionName, $mbaName), local:getandExecuteExecutablecontent($dbName, $collectionName, $mbaName), local:changeCurrentStatus($dbName, $collectionName, $mbaName), local:removeCurrentExternalEvent($dbName, $collectionName, $mbaName), local:processEventlessTransitions($dbName, $collectionName, $mbaName)
};



let $database := "myMBAse",
$collections := "JohannesKeplerUniversity",
$mbas := local:getNewMultilevelBusinessArtifacts($database,$collections)
(:for $name in $mbas/@name
return local:initMBA($database,$collections,$name)
:)
let $updatedmbas := local:getupdatedMBAS($database,$collections)
return $updatedmbas