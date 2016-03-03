
module namespace page = 'http://basex.org/kk/web-page';



import module namespace kk = 'http://www.w3.org/2005/07/kk';
import module namespace scx='http://www.w3.org/2005/07/scxml/extension/';
import module namespace functx = 'http://www.functx.com';
import module namespace mba='http://www.dke.jku.at/MBA'; 
import module namespace sc = 'http://www.w3.org/2005/07/scxml';
import module namespace sync = 'http://www.dke.jku.at/MBA/Synchronization';



(:
declare
  %rest:path("/getcounter/{$dbName}/{$collectionName}/{$mbaName}")
  %rest:GET
   function page:getCounter(
    $dbName as xs:string, $collectionName as xs:string , $mbaName as xs:string)
{


 kk:getCounter($dbName, $collectionName, $mbaName) 
kk:updateCounter($dbName, $collectionName, $mbaName)

};:)



declare
  %rest:path("/foradding")
  %output:method("xhtml")
  %output:omit-xml-declaration("no")
  %output:doctype-public("-//W3C//DTD XHTML 1.0 Transitional//EN")
  %output:doctype-system("http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd")
  function page:start()
  as element(Q{http://www.w3.org/1999/xhtml}html)
{
  <html xmlns="http://www.w3.org/1999/xhtml">
    <head>
      <title>Event Adding Service</title>
      <link rel="stylesheet" type="text/css" href="static/style.css"/>
    </head>
    <body>
      <div class="right"><img src="static/basex.svg" width="96"/></div>
      <h2>Event Adding Service</h2>
			<div>Welcome to the Event Adding Service, which allow you to add Events to the Event Queue</div>


declare variable $dbName := 'myMBAse';
declare variable $collectionName := 'JohannesKeplerUniversity';
declare variable $mbaName := 'InformationSystems';


      <h3>Adding Event 2</h3>
      <p>This allows one to add Prepared and own events to Event Queue</p>
      <form method="post" action="addEvent">
        <p>Your dbName:<br />
        <input name="dbName" size="50"></input> <br />
                Your collectionName:<br />
        <input name="collectionName" size="50"></input> <br />
               Your mbaName:<br />
        <input name="mbaName" size="50"></input> <br />
        
        <h4> EventType </h4>
          <fieldset>
    <input type="radio" name="event" value="setDegree"/> setDegree<br/>
    <input type="radio" name="event" value="addSchool"/>addSchool  <br/>
    <input type="radio" name="event" value="addDegree"/>addDegree<br/>
    <input type="radio" name="event" value="removeDegree"/>removeDegree <br/>
    <input type="radio" name="event" value="addCourse"/>addCourse  <br/>
    
    <input type="radio" name="event" value="removeDegree"/>removeDegree<br/>
<input type="radio" name="event" value=""/>Other​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​

<h4> Input </h4>
<input type="text" name="addText" />
  </fieldset>

  
        <input type="submit" /></p>
        
        
      </form>
    </body>
  </html>
};







declare
  %rest:path("/addEvent")
  %rest:POST
  %rest:form-param("message","{$message}", "(no message)")
    %rest:form-param("event","{$event}", "(no event)")
%rest:form-param("addText","{$addText}", "(no addText)")
%rest:form-param("dbName","{$dbName}", "(no dbName)")
%rest:form-param("collectionName","{$collectionName}", "(no collectionName)")
%rest:form-param("mbaName","{$mbaName}", "(no mbaName)")
  %rest:header-param("User-Agent", "{$agent}")
updating  function page:addEvent(
    $message as xs:string,
    $agent   as xs:string*, 
  $event, $addText, $dbName, $collectionName, $mbaName)
{
  
(:  let $addText := functx:trim($addText):)
  let $mba := mba:getMBA($dbName, $collectionName, $mbaName)


let $externalEvent := 
   
   switch($event)
  
   case "setDegree" 
         return 
         <event name="{$event}" xmlns="">
            <degree xmlns="">{$addText}</degree>
            <id>{mba:getCounter( $mba )}</id>
      </event>

    case "addSchool" 

      return
       <event name="{$event}" xmlns="">
          <name xmlns="">{$addText}</name>
          <id>{mba:getCounter( $mba )}</id>
        </event>
        
       case "addDegree"
             return
              <event name="{$event}" xmlns="">
          <text xmlns="">{$addText}</text>
          <id>{mba:getCounter( $mba )}</id>
        </event>
        case "removeDegree"
              return
       <event name="{$event}" xmlns="">
          <text xmlns="">{$addText}</text>
          <id>{mba:getCounter( $mba )}</id>
        </event>
         case "addCourse"
               return
       <event name="{$event}" xmlns="">
         <name xmlns="">{$addText}</name>
          <id>{mba:getCounter( $mba )}</id>
        </event>
       
   default
   


return 
   copy $c := fn:parse-xml-fragment(fn:replace($addText, '"', "'"))/*
   modify
   insert node <id>{mba:getCounter( $mba )}</id>  into $c
   return $c
   
      
  return mba:enqueueExternalEvent($mba, $externalEvent),kk:updateCounter($dbName,$collectionName,$mbaName),
db:output(<response> 
  <result> added Eevent</result>
    <addText> {$addText}</addText>
  <parse> {fn:replace($addText, '"', "'") }</parse>
  <counter> {mba:getCounter( mba:getMBA($dbName, $collectionName, $mbaName) )}</counter>
</response>)
   
   (: return  :)
  
};









declare
  %rest:path("/add/{$dbName}/{$collectionName}/{$mbaName}/{$value}")
  %rest:GET
  updating function page:addEventtoQueue(
    $dbName as xs:string, $collectionName as xs:string , $mbaName as xs:string, $value as xs:string)
{


let $externalEvent := <event name="setDegree" type="external" xmlns="">
<degree xmlns="">{$value}</degree>
<id>{mba:getCounter(mba:getMBA($dbName, $collectionName, $mbaName))}</id>
</event>
 
let $mba := mba:getMBA($dbName, $collectionName, $mbaName)

(: get Counter, update Counter and add Event to Eventqueue:)

return mba:enqueueExternalEvent($mba, $externalEvent),kk:updateCounter($dbName,$collectionName,$mbaName),
db:output(<response> 
  <result> added Eevent</result>
  <value> {$value}</value> 
  <counter> {mba:getCounter(mba:getMBA($dbName, $collectionName, $mbaName))}</counter>
</response>)


};



declare
  %rest:path("/addEvent/{$dbName}/{$collectionName}/{$mbaName}/{$event}")
  %rest:GET
  updating function page:addEvent(
    $dbName as xs:string, $collectionName as xs:string , $mbaName as xs:string, $event as xs:string)
{

 let $mba := mba:getMBA($dbName, $collectionName, $mbaName)
 let $externalEvent :=
   copy $c := fn:parse-xml-fragment(fn:replace($event, '"', "'"))/*
   modify
   insert node <id>{mba:getCounter( $mba )}</id>  into $c
   return $c
   
      
  return mba:enqueueExternalEvent($mba, $externalEvent),kk:updateCounter($dbName,$collectionName,$mbaName),
db:output(<response> 
  <result> added Eevent</result>
    <addText> {$event}</addText>
  <counter> {mba:getCounter( mba:getMBA($dbName, $collectionName, $mbaName) )}</counter>
</response>)


};



(:
this function returns a Result for an mba with an certain Id
:)
declare
  %rest:path("/getResult/{$dbName}/{$collectionName}/{$mbaName}/{$id}")
  %rest:GET
  function page:getResult(
    $dbName as xs:string, $collectionName as xs:string , $mbaName as xs:string, $id as xs:string)
{



kk:getResult($dbName, $collectionName, $mbaName, $id)


};


declare
  %rest:path("/initMBA/{$dbName}/{$collectionName}/{$mbaName}")
  %rest:GET
  updating function page:initMba(
    $dbName as xs:string, $collectionName as xs:string , $mbaName as xs:string)
{


let $url := 'http://pagehost:8984/'
return

 kk:initMBARest($dbName,$collectionName,$mbaName),
 db:output(<rest:forward>{fn:concat('/initSCXML/', string-join(($dbName,$collectionName,$mbaName,0), '/' ))}</rest:forward>)

};


declare
  %rest:path("/initSCXML/{$dbName}/{$collectionName}/{$mbaName}/{$counter}")
  %rest:GET
  updating function page:initSCXML(
    $dbName as xs:string, $collectionName as xs:string , $mbaName as xs:string, $counter as xs:integer)
{


if($counter = 0) then 

  let $mba   := mba:getMBA($dbName, $collectionName, $mbaName)
  return (
  mba:createDatamodel($mba)

,
 db:output(<rest:forward>{fn:concat('/initSCXML/', string-join(($dbName,$collectionName,$mbaName,1), '/' ))}</rest:forward>))
 else

(

  (kk:initSCXMLRest($dbName,$collectionName,$mbaName)
,
 db:output(<rest:forward>{fn:concat('/executeInit/', string-join(($dbName,$collectionName,$mbaName,0), '/' ))}</rest:forward>))) 
 
 
};


declare
  %rest:path("/executeInit/{$dbName}/{$collectionName}/{$mbaName}/{$icounter}")
  %rest:GET
  updating function page:enterInitalStates(
    $dbName as xs:string, $collectionName as xs:string , $mbaName as xs:string, $icounter as xs:integer)
{

let $icounterneu := $icounter +1
  let $mba   := mba:getMBA($dbName, $collectionName, $mbaName)
let $scxml := mba:getSCXML($mba)
let $content1 := 

for $s in mba:getConfiguration($mba)
return ($s/sc:onentry/*,$s/sc:initial/sc:transition/*)


let $content2 :=map:get(sc:computeEntryInit($scxml)[1],'historyContent')
let $content := ($content1,$content2)

let $max := fn:count($content)

return

if ($icounter <= $max) then  
 ( kk:runExecutableContent($dbName, $collectionName, $mbaName, $content[$icounter]), 
 db:output(<rest:forward>{fn:concat('/executeInit/', string-join(($dbName,$collectionName,$mbaName,$icounterneu), '/' ))}</rest:forward>))
 else
 ( kk:runExecutableContent($dbName, $collectionName, $mbaName, $content[$icounter]), 
 db:output(<rest:forward>{fn:concat('/enterStatesInit/', string-join(($dbName,$collectionName,$mbaName), '/' ))}</rest:forward>))
 
  
 
};

declare
  %rest:path("/enterStatesInit/{$dbName}/{$collectionName}/{$mbaName}")
  %rest:GET
  updating function page:enterStatesInit(
    $dbName as xs:string, $collectionName as xs:string , $mbaName as xs:string)
{

(: maybee some inital Things:)
(: move Forward to Eventless Transitions :)

kk:enterStates($dbName,$collectionName,$mbaName,'init')

 ,  db:output(<rest:forward>{fn:concat('/startProcess/', string-join(($dbName,$collectionName,$mbaName), '/' ))}</rest:forward>)


};





declare
  %rest:path("/startProcess/{$dbName}/{$collectionName}/{$mbaName}")
  %rest:GET
  updating function page:startProcess(
    $dbName as xs:string, $collectionName as xs:string , $mbaName as xs:string)
{

(: maybee some inital Things:)
(: move Forward to Eventless Transitions :)

 kk:removeFromInsertLog($dbName, $collectionName, $mbaName),
  db:output(<rest:forward>{fn:concat('/internalTransitions/', string-join(($dbName,$collectionName,$mbaName), '/' ))}</rest:forward>)

};




declare
  %rest:path("/internalTransitions/{$dbName}/{$collectionName}/{$mbaName}")
  %rest:GET
  updating function page:internalTransitions(
    $dbName as xs:string, $collectionName as xs:string , $mbaName as xs:string)
{

let $mba   := mba:getMBA($dbName, $collectionName, $mbaName)
let $scxml := mba:getSCXML($mba)

let $configuration := mba:getConfiguration($mba)
let $dataModels := sc:selectAllDataModels($mba)

let $enabledTransitions := sc:selectEventlessTransitions($configuration,$dataModels)




return if (fn:empty($enabledTransitions)) then 

let $internalEvent := mba:getInternalEventQueue($mba)/*
return
if(fn:empty($internalEvent)) then

( kk:getNextExternalEvent($dbName, $collectionName, $mbaName),db:output(<rest:forward>{fn:concat('/transitions/', string-join(($dbName,$collectionName,$mbaName,'0','external'), '/' ))}</rest:forward>))
 
else
(kk:getNextInternalEvent($dbName, $collectionName, $mbaName), db:output(<rest:forward>{fn:concat('/transitions/', string-join(($dbName,$collectionName,$mbaName,'0','internal'), '/' ))}</rest:forward>))
else
( (), db:output(<rest:forward>{fn:concat('/transitions/', string-join(($dbName,$collectionName,$mbaName,'0', 'eventless'), '/' ))}</rest:forward>))


};


declare
  %rest:path("/transitions/{$dbName}/{$collectionName}/{$mbaName}/{$counter}/{$transType}")
  %rest:GET
  updating function page:internalTransitions(
    $dbName as xs:string, $collectionName as xs:string , $mbaName as xs:string, $counter, $transType as xs:string)
{

let $mba   := mba:getMBA($dbName, $collectionName, $mbaName)
let $scxml := mba:getSCXML($mba)

let $configuration := mba:getConfiguration($mba)
let $dataModels := sc:selectAllDataModels($mba)

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


let $insert :=

for $t in $transitions
let $s :=  sc:getSourceState($t)
return <transitions ref="{$s/@id}">
{$t}</transitions>



 
let $exitSet :=  sc:computeExitSet2($configuration,$transitions)





return 
(mba:updateCurrentExitSet($mba,$exitSet),mba:updatecurrentTransitions($mba,$insert), db:output(<rest:forward>{fn:concat('/microstep/', string-join(($dbName,$collectionName,$mbaName,$counter,$transType), '/' ))}</rest:forward>))

};




declare
  %rest:path("/microstep/{$dbName}/{$collectionName}/{$mbaName}/{$counter}/{$transType}")
  %rest:GET
  updating function page:microstep(
    $dbName as xs:string, $collectionName as xs:string , $mbaName as xs:string, $counter as xs:integer, $transType as xs:string)
{
  
 
let $mba   := mba:getMBA($dbName, $collectionName, $mbaName)
let $scxml := mba:getSCXML($mba)



let $content := 
   kk:getExecutableContents($dbName, $collectionName, $mbaName)

  
  
let $max := fn:count($content)
let $counterneu := $counter + 1

(:EnterStates with Content or transitions.. to Check:)


return if ($counter = 0) then 
(
kk:exitStates($dbName,$collectionName,$mbaName,$transType),
   db:output(<rest:forward>{fn:concat('/microstep/', string-join(($dbName,$collectionName,$mbaName,$counterneu,$transType), '/' ))}</rest:forward>)
)
else if ($counter <= $max) then
 (kk:executeExecutablecontent($dbName, $collectionName, $mbaName, $content, $counter),
   db:output(<rest:forward>{fn:concat('/microstep/', string-join(($dbName,$collectionName,$mbaName,$counterneu, $transType), '/' ))}</rest:forward>))
 else
 (: (kk:enterStates($dbName, $collectionName, $mbaName,$transType), :)
   db:output(<rest:forward>{fn:concat('/enterContents/', string-join(($dbName,$collectionName,$mbaName, 0, 1, $transType), '/' ))}</rest:forward>)
   
};

declare
  %rest:path("/enterContents/{$dbName}/{$collectionName}/{$mbaName}/{$counterContent}/{$counterEntry}/{$transType}")
  %rest:GET
  updating function page:enterContents(
    $dbName as xs:string, $collectionName as xs:string , $mbaName as xs:string, $counterContent as xs:integer, $counterEntry as xs:integer,  $transType as xs:string)
{
  
 
let $mba   := mba:getMBA($dbName, $collectionName, $mbaName)
let $scxml := mba:getSCXML($mba)

  
   let $transitions := 
 mba:getCurrentTransitionsQueue($mba)/transitions/*
 
  
let $entrySet := if (not (fn:empty(sc:computeEntry($transitions)))) then 
 map:get(sc:computeEntry($transitions)[1],'statesToEnter')
 else
 ()
let $historyContent :=  if (not (fn:empty(sc:computeEntry($transitions)))) then 
 map:get(sc:computeEntry($transitions)[1],'historyContent')
 else
 ()
  let $state := $entrySet[$counterEntry]
  
 let $content :=  kk:getExecutableContentsEnter($dbName, $collectionName, $mbaName,$state,$historyContent)
 let $max := fn:count($content)

 return
 if (fn:empty($state)) then 
  
  let $maxStates := fn:count($entrySet)
 return 
 if ($counterEntry < $maxStates) then 
  db:output(<rest:forward>{fn:concat('/enterContents/', string-join(($dbName,$collectionName,$mbaName,0, $counterEntry +1 , $transType), '/' ))}</rest:forward>)
 else 
 db:output(<rest:forward>{fn:concat('/controller/', string-join(($dbName,$collectionName,$mbaName, $transType), '/' ))}</rest:forward>) 

else

  
   if ($counterContent = 0 ) then 
   
(  kk:enterStatesSingle($dbName,$collectionName,$mbaName,$state),
   db:output(<rest:forward>{fn:concat('/enterContents/', string-join(($dbName,$collectionName,$mbaName, $counterContent+1, $counterEntry, $transType), '/' ))}</rest:forward>))
  
else if ($counterContent <= $max) then
  
  ( kk:executeExecutablecontent($dbName, $collectionName, $mbaName, $content, $counterContent),  db:output(<rest:forward>{fn:concat('/enterContents/', string-join(($dbName,$collectionName,$mbaName, $counterContent+1, $counterEntry, $transType), '/' ))}</rest:forward>))
 
 
 else
 
 let $maxStates := fn:count($entrySet)
 return 
 if ($counterEntry < $maxStates) then 
  db:output(<rest:forward>{fn:concat('/enterContents/', string-join(($dbName,$collectionName,$mbaName,0, $counterEntry +1 , $transType), '/' ))}</rest:forward>)
 else 
 db:output(<rest:forward>{fn:concat('/controller/', string-join(($dbName,$collectionName,$mbaName, $transType), '/' ))}</rest:forward>) 


   


};






declare
  %rest:path("/controller/{$dbName}/{$collectionName}/{$mbaName}/{$transType}")
  %rest:GET
  updating function page:controller(
    $dbName as xs:string, $collectionName as xs:string , $mbaName as xs:string, $transType as xs:string)
{
 
 
(:maybe not necessary
-> :)


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
let $dataModels := sc:selectAllDataModels($mba)

return

if($transType != 'external') then

   ( kk:changeCurrentStatus($mba,(),$exitSet),db:output(<rest:forward>{fn:concat('/internalTransitions/', string-join(($dbName,$collectionName,$mbaName), '/' ))}</rest:forward>) )

   else


  if(fn:empty(sc:selectEventlessTransitions($configuration,$dataModels)) and fn:empty(mba:getInternalEventQueue($mba)/*) and fn:empty(mba:getExternalEventQueue($mba)/*)) then 
   
   (kk:changeCurrentStatus($mba,(),$exitSet), db:output(
     <response><trans> { $transType}</trans></response>
   ) )
   
   else
    ( kk:changeCurrentStatus($mba,(),$exitSet),db:output(<rest:forward>{fn:concat('/internalTransitions/', string-join(($dbName,$collectionName,$mbaName), '/' ))}</rest:forward>) )




 
    
    
};



declare
  %rest:path("/invokeStates/{$dbName}/{$collectionName}/{$mbaName}/{$transType}")
  %rest:GET
  updating function page:invoke(
    $dbName as xs:string, $collectionName as xs:string , $mbaName as xs:string, $transType as xs:string)
{
  
 let $mba   := mba:getMBA($dbName, $collectionName, $mbaName)
 
  let $states := mba:getStatesToInvokeQueue($mba)
  
  for $s in $states
  return ()
  
  
};
 
 
 




