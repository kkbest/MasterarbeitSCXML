declare default element namespace 'http://www.w3.org/2005/07/scxml';
declare namespace functx = "http://www.functx.com";


declare function local:first-node
  ( $nodes as node()* )  as node()? {

   ($nodes/.)[1]
 } ;

declare function local:test($datamodel, $events, $count)
{
  
  (:trace(fn:for-each($events/*,local:callFunction($datamodel, ?))) :)

    if(fn:exists($events/*[$count])) then
     let $newDatamodel:=  trace(local:callFunction($datamodel,  $events/*[$count]))
     let $newcount := trace($count+1)
     return local:test($newDatamodel, $events , $newcount)
     else
     $datamodel
     
    
  
};

declare function local:callFunction($datamodel, $event)
{
  switch ($event)
  case $event/self::assign return local:assign($datamodel,$event)
  case $event/self::log return local:log($datamodel, $event)
  default return <ss> </ss>  
  
};

declare function local:assign($datamodel, $event)
{

copy $c := $datamodel
modify (
  replace value of node $c/data[@id = string($event/@location)]/@expr with $event/@expr
)
(: let $nodeToUpdate :=  $datamodel/data[@id = string($event/@location)] :)

 return $c
 
  (:copy $c := $datamodel
 modify replace value of node $c/data[@id = $event/[@location]
  modify rename node $c as 'ccopy' :)
  
};

declare function local:log($datamodel, $event)
{
  let$ log :=trace($event/@expr)
  return $datamodel
};



(: Datamodel -> cook time , door_closed, timer:)
let $scxml := doc('file:///C:\Program Files (x86)\BaseX\masterarbeit\test.scxml')/scxml
let $datamodel := $scxml/datamodel
let $events := $scxml/state/onentry
return local:test($datamodel , $events,1)