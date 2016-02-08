import module namespace kk = 'http://www.w3.org/2005/07/kk';
import module namespace scx='http://www.w3.org/2005/07/scxml/extension/';
import module namespace functx = 'http://www.functx.com';
import module namespace mba='http://www.dke.jku.at/MBA'; 
import module namespace sc = 'http://www.w3.org/2005/07/scxml';
import module namespace sync = 'http://www.dke.jku.at/MBA/Synchronization';


declare variable $dbName := 'myMBAse';
declare variable $collectionName := 'JohannesKeplerUniversity';
declare variable $mbaName := 'InformationSystems';


declare function local:mult($x, $y)
{
  $x * $y
};


declare function local:runExecutableContentuA($mba,$content)
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
    default return ()
)
return $copymba
};


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
  let $executableContent1 :=  kk:getExecutableContents($currentEmba)[1]
  
(:  
   let $foldresults := fold-left(?, $currentEmba, function($content, $mba){ fn:trace(local:runExecutableContentuA($mba, $content), "info")})
   
   let $test1 := fold-left(?, $currentEmba, function($mba, $content){ fn:trace(local:runExecutableContentuA($mba, $content), "help")})
:)


 let $todo :=  fold-left(?, $currentEmba, function($mba, $content){ fn:trace($content), "trace"})
 let $scxml := mba:getSCXML($currentEmba)

let $configuration := mba:getConfiguration($currentEmba)
let $dataModels := sc:selectDataModels($configuration)


let $expression :=
    if (not( $executableContent/@expr) or  $executableContent/@expr = '') 
    then '() '
    else  $executableContent/@expr
    
let $locations := $executableContent/@location 


let $from-digits := fold-left(?, 0,  function($d, $n) {fn:trace( 10 * $n + $d) }
)

let $newValues := $expression


return (
 $currentEmba
)
(:    


    
    $from-digits(1 to 5)
 
  $test1($executableContent1)
)
return $executableContent :)
