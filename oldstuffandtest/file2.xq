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


declare function local:eval($query, $dataModels) as item()*
{
  
  let $dataBindings :=
    for $dataModel in $dataModels
      for $data in $dataModel/sc:data
        return map:entry($data/@id, $data)
  
  let $declare :=
    for $dataModel in $dataModels
      for $data in $dataModel/sc:data
        return 
          ' declare variable $' || $data/@id || ' external ;'
    
           
    let $evaluation := try
         {
            xquery:eval(scx:importModules() ||
                        fn:string-join($declare) || 
                        scx:builtInFunctionDeclarations() ||
                       'return ' || $query, 
                       map:merge($dataBindings))
         } 
         catch *
         {
           fn:false()
         }
         
         return $evaluation
         
               
          
};


 let $mba   := mba:getMBA($dbName, $collectionName, $mbaName)
 let $mba   := mba:getMBA($dbName, $collectionName, $mbaName)
let $scxml := mba:getSCXML($mba)

let $currentEvent := mba:getCurrentEvent($mba)
let $eventName    := $currentEvent/name

let $configuration := mba:getConfiguration($mba)
let $dataModels := sc:selectDataModels($configuration)
let $event := $eventName


          
 let $mba   := mba:getMBA($dbName, $collectionName, $mbaName)
let $scxml := mba:getSCXML($mba)
let $content1 := 

for $s in mba:getConfiguration($mba)
return ($s/sc:onentry/*,$s/sc:initial/sc:transition/*)


let $content2 :=map:get(sc:computeEntryInit($scxml)[1],'historyContent')
let $content := ($content1,$content2)

let $content :=  $content[1]

let $item :=  local:eval($content/@item,$dataModels)

let $array :=  local:eval($content/@array,$dataModels)
return
for $a in $array
let $item := 
return $content



