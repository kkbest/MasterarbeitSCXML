module namespace page = 'http://basex.org/kk/web-page';

import module namespace functx = 'http://www.functx.com';
import module namespace mba='http://www.dke.jku.at/MBA'; 
import module namespace sc = 'http://www.w3.org/2005/07/scxml';



(:~
:
 :)
declare
  %rest:path("/enterMBA")
  %output:method("xhtml")
  %output:omit-xml-declaration("no")
  %output:doctype-public("-//W3C//DTD XHTML 1.0 Transitional//EN")
  %output:doctype-system("http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd")
  function page:modify()
  as element(Q{http://www.w3.org/1999/xhtml}html)
{
  <html xmlns="http://www.w3.org/1999/xhtml">
    <head>
      <title>Event Adding Service</title>
      <link rel="stylesheet" href="static/bootstrap/css/bootstrap.min.css" /> 

      <script src="static/bootstrap/js/bootstrap.min.js"></script>  
    </head>
    <body>
    <div class="navbar navbar-inverse">
  <div class="navbar-header">
    <button type="button" class="navbar-toggle" data-toggle="collapse" data-target=".navbar-inverse-collapse">
      <span class="icon-bar"></span>
      <span class="icon-bar"></span>
      <span class="icon-bar"></span>
    </button>
    <a class="navbar-brand" href="#">SCXML-Interpreter</a>
  </div>
  </div>

 <div class="container">
<div class="page-header" id="banner">
        <div class="row">
          <div class="col-lg-6">
            <h1> SCXML - Interpreter</h1>
            <p class="lead">Add an event to a MBA</p>
          </div>
        </div>
      </div>


<form action="getEvents" method="GET" role="form" class="form-horizontal">
  <div class="form-group">
  <label for="dbName">dbName</label>
  <input type="text" class="form-control" id="dbName" name="dbName" />
</div>

<div class="form-group">
  <label for="collectionName">collectionName</label>
  <input type="text" class="form-control" id="collectionName" name="collectionName"  />
</div>

<div class="form-group">
  <label for="mbaName">mbaName</label>
  <input type="text" class="form-control" id="mbaName" name="mbaName"/>
</div>
  <div class="form-group">
    <div class="col-sm-offset-2 col-sm-10">
      <button type="submit" class="btn btn-default">Search</button>
    </div>
  </div>
</form>

     </div>
    </body>
  </html>
};


(:~
  Returns the possible Events for the given MBA
  : @param $dbName  The name of the database
 : @param $collectionName  The name of the collection
  : @param $mbaName The name of the MBA
 :@return list of Events
 :)
declare
  %rest:path("/getEvents")
    %rest:GET
  %rest:query-param("dbName","{$dbName}", "(no dbName)")
%rest:query-param("collectionName","{$collectionName}", "(no collectionName)")
%rest:query-param("mbaName","{$mbaName}", "(no mbaName)")
 function page:hello-index(
    $dbName, $collectionName, $mbaName)
    as node()*
{

 try
 { 
let $mba   := mba:getMBA($dbName, $collectionName, $mbaName)
let $scxml := mba:getSCXML($mba)
let $configuration := mba:getConfiguration($mba)
let $dataModels := mba:selectDataModels($configuration)
let $events :=

<auswahl>
{
  
 for $event in $configuration/sc:transition/@event
return 
<event>{$event/data()}</event>
}
</auswahl>


let $target := 'xml-stylesheet',
$content := 'href="../static/start.xsl" type="text/xsl" '

return document {
   processing-instruction {$target} {$content},

  <output>
  {($events,
 <hidden>
<dbName>{$dbName}</dbName>
<collectionName>{$collectionName}</collectionName>
<mbaName>{$mbaName}</mbaName>
</hidden>)}
</output> 
}
}
catch *
{
  <test>
  <msg>MBA nicht vorhanden </msg>
  <info>{$mbaName}</info>
  </test>
}


};

(:~
  Returns the possible Dataelement for Events
  : @param $dbName  The name of the database
 : @param $collectionName  The name of the collection
  : @param $mbaName The name of the MBA
  : @param $event The name of the event
 :@return list of dataelements
 :)
declare %rest:path("getDataElements")
%rest:query-param("dbName","{$dbName}", "(no dbName)")
%rest:query-param("collectionName","{$collectionName}", "no collectionName")
%rest:query-param("mbaName","{$mbaName}", "no mbaName")
%rest:query-param("event","{$event}", "no event")
%rest:GET
  function page:change(
    $event as xs:string, $dbName as xs:untypedAtomic*, $collectionName as xs:untypedAtomic*, $mbaName as xs:untypedAtomic*)
    as item()*
{

let $target := 'xml-stylesheet',
$content := 'href="../static/event.xsl" type="text/xsl" '



let $mba   := mba:getMBA($dbName, $collectionName, $mbaName)
let $scxml := mba:getSCXML($mba)

let $configuration := mba:getConfiguration($mba)
let $dataModels := mba:selectAllDataModels($mba)


return 

for $eventName in $event

let $transitions := 
  sc:selectTransitionsoC($configuration, $dataModels, $eventName)
let $exitSet := sc:computeExitSet2($configuration,$transitions)
let $entrymap :=sc:computeEntryOc($transitions)
let $historycontent :=  if (not (fn:empty($entrymap))) then 
 map:get($entrymap[1],'historyContent')
 else
 ()
let $entrySet := if (not (fn:empty($entrymap))) then 
 map:get($entrymap[1],'statesToEnter')
 else
 ()
 
 let $contentEntry := 
  for $state in $entrySet
  return  sc:getExecutableContentsEnter($dbName, $collectionName, $mbaName,$state,$historycontent)
 let $contentExit :=
  for $state in $exitSet
return sc:getExecutableContentsExit($dbName, $collectionName, $mbaName,$state)
 
let $value :=
(
$transitions/@cond, $transitions/*/@expr, $contentEntry/@expr, $contentExit/@expr)

let $dataToCheck :=  ($value[contains(.,'$_event')])
let $values := 
for $d in $dataToCheck
let $after :=(substring-after($d,'$_event/data/'))
let $before := <text>{functx:substring-before-match($after,('/|\s'))} </text>
return $before


let $data := 
for $d in fn:distinct-values($values)
return 
<data> {$d}</data>
return document {
   processing-instruction {$target} {$content},
 element
 {$event }
 {
   <input>
   {$data}
 <hidden>
<dbName>{$dbName}</dbName>
<collectionName>{$collectionName}</collectionName>
<mbaName>{$mbaName}</mbaName>
</hidden>
<event>{$event}</event>
  </input>
 }
 
}


};



(:~
: Inserts the event to the list of external Events. 
  : @param $data 
 :)
declare %rest:path("insertEvent")
  %rest:POST("{$data}")
updating function page:change($data)
   
{
 

let $target := 'xml-stylesheet',
$content := 'href="../static/update.xsl" type="text/xsl" '

  let $input :=
  <input>  
 { let $row :=  fn:tokenize($data,'&amp;')
 for $r in $row
 let $data := fn:tokenize( $r, '=')
 return element{$data[1]}{$data[2]}
}
 </input>
 
 
 let $dbName := $input/dbName/text()
 let $collectionName := $input/collectionName/text()
 let $mbaName := $input/mbaName/text()
  let $mba := mba:getMBA($dbName, $collectionName, $mbaName)
  let $eventName := $input/event/text()

 let $eventData :=
   $input/*[not(functx:is-value-in-sequence(name(.),("mbaName","dbName","collectionName","event","ownDataName","ownDataData")))]
     
  let $extraData := 
  let $name :=  $input/ownDataName/text()
  let $data := $input/ownDataData/text()
  return
  if (not($name/data()='' or $data/data() = '' or fn:empty($name/data()) or fn:empty($data/data()))) then
  element{$name/data()}{$data/data()}
  else
  ()



return 

(mba:enqueueExternalEvent($mba, <event name='{$eventName}' >{ $eventData , $extraData,  <id>{mba:getCounter( $mba )}</id> }</event>),sc:updateCounter($dbName,$collectionName,$mbaName),
db:output(
  document {
 processing-instruction {$target} {$content},
<response> 
  <result> added Eevent</result>
    <addText> {$eventName}</addText>
    <addText> {$extraData}</addText>
    <name> {$input/*[position()=last()-1]}</name>
    <input> {$input}</input>
  <counter> {mba:getCounter( mba:getMBA($dbName, $collectionName, $mbaName) )}</counter>
</response>})
)

};





(:~
: 
 :)
declare
  %rest:path("/queryMBA")
  %output:method("xhtml")
  %output:omit-xml-declaration("no")
  %output:doctype-public("-//W3C//DTD XHTML 1.0 Transitional//EN")
  %output:doctype-system("http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd")
  function page:getData()
  as element(Q{http://www.w3.org/1999/xhtml}html)
{
  <html xmlns="http://www.w3.org/1999/xhtml">
    <head>
      <title>Event Adding Service</title>
      <link rel="stylesheet" href="static/bootstrap/css/bootstrap.min.css" /> 

      <script src="static/bootstrap/js/bootstrap.min.js"></script>  
    </head>
    <body>
    <div class="navbar navbar-inverse">
  <div class="navbar-header">
    <button type="button" class="navbar-toggle" data-toggle="collapse" data-target=".navbar-inverse-collapse">
      <span class="icon-bar"></span>
      <span class="icon-bar"></span>
      <span class="icon-bar"></span>
    </button>
    <a class="navbar-brand" href="#">SCXML-Interpreter</a>
  </div>
  </div>

 <div class="container">
<div class="page-header" id="banner">
        <div class="row">
          <div class="col-lg-6">
            <h1> SCXML - Interpreter</h1>
            <p class="lead">Hinzufügen von Events</p>
          </div>
        </div>
      </div>


<form action="getResult" method="POST" role="form" class="form-horizontal">
  <div class="form-group">
  <label for="dbName">dbName</label>
  <input type="text" class="form-control" id="dbName" name="dbName" />
</div>

<div class="form-group">
  <label for="collectionName">collectionName</label>
  <input type="text" class="form-control" id="collectionName" name="collectionName"  />
</div>

<div class="form-group">
  <label for="mbaName">mbaName</label>
  <input type="text" class="form-control" id="mbaName" name="mbaName"/>
</div>

<div class="form-group">
  <label for="mbaName">Counter</label>
  <input type="text" class="form-control" id="counter" name="counter"/>
</div>

  <div class="form-group">
    <div class="col-sm-offset-2 col-sm-10">
      <button type="submit" class="btn btn-default">Search</button>
    </div>
  </div>
</form>

     </div>
    </body>
  </html>
};



(:~
  Returns the Result for a given Counter-Element
  : @param $dbName  The name of the database
 : @param $collectionName  The name of the collection
  : @param $mbaName The name of the MBA
  : @param $counter The user counter 
 :@return list of dataelement 
 :)
declare
  %rest:path("/getResult")
    %rest:GET
  %rest:query-param("dbName","{$dbName}", "(no dbName)")
%rest:query-param("collectionName","{$collectionName}", "(no collectionName)")
%rest:query-param("mbaName","{$mbaName}", "(no mbaName)")
%rest:query-param("counter","{$counter}", "(no counter)")
 function page:hello-result(
    $dbName, $collectionName, $mbaName, $counter)
    as node()*
{
  
  
let $mba   := mba:getMBA($dbName, $collectionName, $mbaName)
let $scxml := mba:getSCXML($mba)
let $configuration := mba:getConfiguration($mba)
let $dataModels := mba:selectDataModels($configuration)
let $events :=

sc:getResult($dbName, $collectionName, $mbaName, $counter)


let $target := 'xml-stylesheet',
$content := 'href="../static/getResult.xsl" type="text/xsl" '

return document {
   processing-instruction {$target} {$content},

  <output>
  {($events,
 <hidden>
<dbName>{$dbName}</dbName>
<collectionName>{$collectionName}</collectionName>
<mbaName>{$mbaName}</mbaName>
<counter>{$counter}</counter>
</hidden>)}
</output> 
}

};


(:~
   initializes the MBA 
  : @param $dbName  The name of the database
 : @param $collectionName  The name of the collection
  : @param $mbaName The name of the MBA 
 :)
declare
  %rest:path("/initMBA/{$dbName}/{$collectionName}/{$mbaName}")
  %rest:GET
  updating function page:initMba(
    $dbName as xs:string, $collectionName as xs:string , $mbaName as xs:string)
{

 sc:initMBARest($dbName,$collectionName,$mbaName), sc:removeFromInsertLog($dbName, $collectionName, $mbaName),
 sc:markAsUpdated($dbName, $collectionName, $mbaName)
};


(:~
   initializes the SCXML 
  : @param $dbName  The name of the database
 : @param $collectionName  The name of the collection
  : @param $mbaName The name of the MBA
  : @param $counter The counter of the function
 :)
declare
  %rest:path("/initSCXML/{$dbName}/{$collectionName}/{$mbaName}/{$counter}")
  %rest:GET
  updating function page:initSCXML(
    $dbName as xs:string, $collectionName as xs:string , $mbaName as xs:string, $counter as xs:integer)
{

 let $mba   := mba:getMBA($dbName, $collectionName, $mbaName)
 return
   if($counter = 0) then 
     (sc:createDatamodel($mba), sc:removeFromUpdateLog($dbName, $collectionName, $mbaName),
     db:output(<rest:forward>{fn:concat('/initSCXML/', string-join(($dbName,$collectionName,$mbaName,1), '/' ))}</rest:forward>))
   else
   (
     (sc:initSCXMLRest($dbName,$collectionName,$mbaName),
     let $configuration := mba:getConfiguration($mba)
     return
        if (not ($configuration)) then 
           db:output(<rest:forward>{fn:concat('/doLogging/', string-join(($dbName,$collectionName,$mbaName, 'init'), '/' ))}</rest:forward>)  

        else
        ( db:output(<rest:forward>{fn:concat('/controller/', string-join(($dbName,$collectionName,$mbaName,'external'), '/' ))}</rest:forward>)))) 
};



(:~
   loads the next Event and calls the correct function
  : @param $dbName  The name of the database
  : @param $collectionName  The name of the collection
  : @param $mbaName The name of the MBA
 :)
declare
  %rest:path("/processPendingTransitions/{$dbName}/{$collectionName}/{$mbaName}")
  %rest:GET
  updating function page:processPendingTransitions($dbName as xs:string, $collectionName as xs:string , $mbaName as xs:string)
{
  let $mba   := mba:getMBA($dbName, $collectionName, $mbaName)
  let $scxml := mba:getSCXML($mba)
  
  let $configuration := mba:getConfiguration($mba)
  let $dataModels := mba:selectAllDataModels($mba)
  
  let $enabledTransitions := sc:selectEventlessTransitions($configuration,$dataModels)
  
  return 
  if (fn:empty($enabledTransitions)) then 
    let $internalEvent := mba:getInternalEventQueue($mba)/*
      return
        if(fn:empty($internalEvent)) then
          (sc:getNextExternalEvent($dbName, $collectionName, $mbaName),
          db:output(<rest:forward>{fn:concat('/doFinalizeandAutoforward/', string-join(($dbName,$collectionName,$mbaName,0), '/' ))}</rest:forward>)) 
        else
            (sc:getNextInternalEvent($dbName, $collectionName, $mbaName),
            db:output(<rest:forward>{fn:concat('/calculateTransitions/', string-join(($dbName,$collectionName,$mbaName,'internal'), '/' ))}</rest:forward>))
  else
    (db:output(<rest:forward>{fn:concat('/calculateTransitions/', string-join(($dbName,$collectionName,$mbaName, 'eventless'), '/' ))}</rest:forward>))
};


(:~
   call finalizeEvents and send autoforward events to the invoked mbas. 
  : @param $dbName  The name of the database
 : @param $collectionName  The name of the collection
  : @param $mbaName The name of the MBA
  : @param $finalizeCounter The counter of the function
 :)
declare
  %rest:path("/doFinalizeandAutoforward/{$dbName}/{$collectionName}/{$mbaName}/{$finalizeCounter}")
  %rest:GET
  updating function page:doFinalizeandAutoforward(
    $dbName as xs:string, $collectionName as xs:string , $mbaName as xs:string, $finalizeCounter as xs:integer)
{
  

let $mba   := mba:getMBA($dbName, $collectionName, $mbaName)
  let $configuration := mba:getConfiguration($mba)
  let $currentEvent := mba:getCurrentEvent($mba)
  let $dataModel :=  mba:selectAllDataModels($mba)

return

  if($finalizeCounter = 0) then 
  
 (
    sc:updateRunning($dbName,$collectionName,$mbaName)
   ,
   for $s in $configuration
      for $inv in $s/sc:invoke
       return
       (
         let $match := $s/@id || '.*'
           return
           (
             if (fn:matches($currentEvent/invokeid,$match)) then
             (
               let $content := $inv/sc:finalize/*
                 return sc:runExecutableContent($dbName, $collectionName,$mbaName, $content[1]))
              else()
            ),
            (
              if($inv/@autoforward = 'true') then(
                sc:autoForward($dbName, $collectionName,$mbaName, $s))
               else()
             )
        ),
     db:output(<rest:forward>{fn:concat('/doFinalizeandAutoforward/', string-join(($dbName,$collectionName,$mbaName,2), '/' ))}</rest:forward>) 
 )
 else
 (
   let $content := 

      for $s in $configuration
      for $inv in $s/sc:invoke
       return
         let $match := $s/@id || '.*'
           return
           (
             if (fn:matches($currentEvent/invokeid,$match)) then
             (
               $inv/sc:finalize/*
             )
             else
             () )
             
             
  let $max := fn:count($content)
  return if ($finalizeCounter > $max) then
      db:output(<rest:forward>{fn:concat('/calculateTransitions/', string-join(($dbName,$collectionName,$mbaName,'external'), '/' ))}</rest:forward>)
       else
           (sc:runExecutableContent($dbName, $collectionName,$mbaName, $content[$finalizeCounter])),
           db:output(<rest:forward>{fn:concat('/doFinalizeandAutoforward/', string-join(($dbName,$collectionName,$mbaName,$finalizeCounter+1), '/' ))}</rest:forward>)
           
         

       
       
           
         
       
 )
        
        
 

};


(:~
   calculate the current active Transitions 
  : @param $dbName  The name of the database
 : @param $collectionName  The name of the collection
  : @param $mbaName The name of the MBA
  : @param $transType The transtype of the transition
 :)
declare
  %rest:path("/calculateTransitions/{$dbName}/{$collectionName}/{$mbaName}/{$transType}")
  %rest:GET
  updating function page:calculateTransitions(
    $dbName as xs:string, $collectionName as xs:string , $mbaName as xs:string, $transType as xs:string)
{

  let $mba   := mba:getMBA($dbName, $collectionName, $mbaName)
  let $scxml := mba:getSCXML($mba)
  let $configuration := mba:getConfiguration($mba)
  let $dataModels := mba:selectAllDataModels($mba)
  let $currentEvent := mba:getCurrentEvent($mba)
  let $eventName    :=  $currentEvent/name
  
  let $transitions := (
    switch($transType)
      case('external')
       return sc:selectTransitions($configuration, $dataModels, $eventName)
      case('internal')
      return sc:selectTransitions($configuration, $dataModels, $eventName)
      case('eventless')
        return sc:selectEventlessTransitions($configuration, $dataModels)
      default
        return ()
  )
    
  let $insert :=   
    for $t in $transitions
      let $s :=  sc:getSourceState($t)
      return <transitions ref="{$s/@id}">{$t}</transitions>
             
  let $exitSet :=  sc:computeExitSet2($configuration,$transitions)

  return 
  (mba:updateCurrentExitSet($mba,$exitSet),mba:updatecurrentTransitions($mba,$insert),
     db:output(<rest:forward>{fn:concat('/exitStates/', string-join(($dbName,$collectionName,$mbaName, 0, 1, $transType), '/' ))}</rest:forward>))

};



(:~
   exit the active States
  : @param $dbName  The name of the database
 : @param $collectionName  The name of the collection
  : @param $mbaName The name of the MBA
  : @param $counterContent The  counter for the Content in an state
    : @param $counterExit The counter for the to be exited state 
      : @param $transType The transtype of the transition
 :)
declare
  %rest:path("/exitStates/{$dbName}/{$collectionName}/{$mbaName}/{$counterContent}/{$counterExit}/{$transType}")
  %rest:GET
  updating function page:exitStates(
    $dbName as xs:string, $collectionName as xs:string , $mbaName as xs:string, $counterContent as xs:integer, $counterExit as xs:integer,  $transType as xs:string)
{
  
 
  let $mba   := mba:getMBA($dbName, $collectionName, $mbaName)
  let $scxml := mba:getSCXML($mba)
  let $transitions := mba:getCurrentTransitionsQueue($mba)/transitions/*
  let $exitSet :=  reverse(mba:getCurrentExitSet($mba))
  let $state := $exitSet[$counterExit]
  let $content :=  sc:getExecutableContentsExit($dbName, $collectionName, $mbaName,$state)
  let $max := fn:count($content)
  return
    if (fn:empty($state)) then 
  
 db:output(<rest:forward>{fn:concat('/runTransitionContent/', string-join(($dbName,$collectionName,$mbaName,0, $transType), '/' ))}</rest:forward>) 

else

  
   if ($counterContent = 0 ) then 
   
(   mba:removeCurrentStates($mba, $state),mba:removestatesToInvoke($mba,$state), sc:exitStatesSingle($dbName,$collectionName,$mbaName,$state,$transType),
   db:output(<rest:forward>{fn:concat('/exitStates/', string-join(($dbName,$collectionName,$mbaName, $counterContent+1, $counterExit, $transType), '/' ))}</rest:forward>))
  
else if ($counterContent <= $max) then
  
  ( sc:runExecutableContent($dbName, $collectionName, $mbaName, $content[$counterContent]),  db:output(<rest:forward>{fn:concat('/exitStates/', string-join(($dbName,$collectionName,$mbaName, $counterContent+1, $counterExit, $transType), '/' ))}</rest:forward>))
 
 
 else
 
 let $maxStates := fn:count($exitSet)
 return 
 if ($counterExit <= $maxStates) then 
  db:output(<rest:forward>{fn:concat('/exitStates/', string-join(($dbName,$collectionName,$mbaName,0, $counterExit +1 , $transType), '/' ))}</rest:forward>)
 else 
 db:output(<rest:forward>{fn:concat('/runTransitionContent/', string-join(($dbName,$collectionName,$mbaName,0, $transType), '/' ))}</rest:forward>) 

 


};



(:~
   run the transitionContent
  : @param $dbName  The name of the database
 : @param $collectionName  The name of the collection
  : @param $mbaName The name of the MBA
  : @param $counter The  counter for the Content in an state
    : @param $transType The transtype of the transition
   
 :)
declare
  %rest:path("/runTransitionContent/{$dbName}/{$collectionName}/{$mbaName}/{$counter}/{$transType}")
  %rest:GET
  updating function page:runTransitionContent(
    $dbName as xs:string, $collectionName as xs:string , $mbaName as xs:string, $counter as xs:integer, $transType as xs:string)
{
  
 if (not($transType = 'exit')) then 
 (
    let $mba   := mba:getMBA($dbName, $collectionName, $mbaName)
    let $scxml := mba:getSCXML($mba)
    let $content := sc:getExecutableContentsTransitions($dbName, $collectionName, $mbaName)
    let $max := fn:count($content)
    let $counterneu := $counter + 1
    
    return 
    if ($counter = 0) then 
      db:output(<rest:forward>{fn:concat('/runTransitionContent/', string-join(($dbName,$collectionName,$mbaName,$counterneu,$transType), '/' ))}</rest:forward>)
    else if ($counter <= $max) then
       (sc:runExecutableContent($dbName, $collectionName, $mbaName, $content[$counter]),
       db:output(<rest:forward>{fn:concat('/runTransitionContent/', string-join(($dbName,$collectionName,$mbaName,$counterneu, $transType), '/' ))}</rest:forward>))
    else
      let $transitions :=  mba:getCurrentTransitionsQueue($mba)/transitions/*
      let $entrySet := 
        if (not (fn:empty(sc:computeEntry($transitions)))) then 
          map:get(sc:computeEntry($transitions)[1],'statesToEnter')
        else ()
      return
        ( mba:updatecurrentEntrySet($mba,$entrySet),  
    db:output(<rest:forward>{fn:concat('/doLogging/', string-join(($dbName,$collectionName,$mbaName, $transType), '/' ))}</rest:forward>)  
)
)
else
 (db:output(<rest:forward>{fn:concat('/exitInterpreter/', string-join(($dbName,$collectionName,$mbaName,1), '/' ))}</rest:forward>))
   
};


(:~
   does the logging 
  : @param $dbName  The name of the database
  : @param $collectionName  The name of the collection
  : @param $mbaName The name of the MBA
    : @param $transType The current TransitionsType
 :)
declare 
  %rest:path("/doLogging/{$dbName}/{$collectionName}/{$mbaName}/{$transType}")
    %rest:GET
  updating function page:exitStates(
    $dbName as xs:string, $collectionName as xs:string , $mbaName as xs:string,   $transType as xs:string)
{
     let $mba   := mba:getMBA($dbName, $collectionName, $mbaName)
  let $scxml := mba:getSCXML($mba)
  let $transitions := mba:getCurrentTransitionsQueue($mba)/transitions/*

  return
   ( for $t in $transitions
  return sc:doLogging($mba,$t,$transType)),
 ( if ($transType = 'init') then 
  sc:doLogging(mba:getMBA($dbName, $collectionName, $mbaName),(),$transType) 
  else
  ()),
        db:output(<rest:forward>{fn:concat('/enterStates/', string-join(($dbName,$collectionName,$mbaName, 0, 1, $transType), '/' ))}</rest:forward>)

};


(:~
   entering the next acitve States 
  : @param $dbName  The name of the database
  : @param $collectionName  The name of the collection
  : @param $mbaName The name of the MBA
    : @param $counterContent The counter of the currently run content
      : @param $counterEntry the state in the list that is currently entered
    : @param $transType The current TransitionsType
 :)
declare
  %rest:path("/enterStates/{$dbName}/{$collectionName}/{$mbaName}/{$counterContent}/{$counterEntry}/{$transType}")
  %rest:GET
  updating function page:enterStates(
    $dbName as xs:string, $collectionName as xs:string , $mbaName as xs:string, $counterContent as xs:integer, $counterEntry as xs:integer,  $transType as xs:string)
{


let $mba   := mba:getMBA($dbName, $collectionName, $mbaName)
let $scxml := mba:getSCXML($mba)

 
   let $transitions := 
 mba:getCurrentTransitionsQueue($mba)/transitions/*
 
  
let $entrySet := mba:getCurrentEntrySet($mba)
let $historyContent :=  
if ($transType = 'init') then 
(
  try
  {
  map:get(sc:computeEntryInit($scxml)[$counterEntry],'historyContent')
  }
  
  catch *
  {
    ()
  }
  
)
else
(
  if (not (fn:empty(sc:computeEntry($transitions)))) then 
 map:get(sc:computeEntry($transitions)[1],'historyContent')
 else
 ()
)
  let $state := $entrySet[$counterEntry]
  
 let $content :=  sc:getExecutableContentsEnter($dbName, $collectionName, $mbaName,$state,$historyContent)
 let $max := fn:count($content)

 return
 if (fn:empty($state)) then 
  
  let $maxStates := fn:count($entrySet)
 return 
 if ($counterEntry < $maxStates) then 
 
  db:output(<rest:forward>{fn:concat('/enterStates/', string-join(($dbName,$collectionName,$mbaName,0, $counterEntry +1 , $transType), '/' ))}</rest:forward>)
 else 
 db:output(<rest:forward>{fn:concat('/controller/', string-join(($dbName,$collectionName,$mbaName, $transType), '/' ))}</rest:forward>) 

else

  
   if ($counterContent = 0 ) then 
   
(  sc:enterStatesSingle($dbName,$collectionName,$mbaName,$state),
   db:output(<rest:forward>{fn:concat('/enterStates/', string-join(($dbName,$collectionName,$mbaName, $counterContent+1, $counterEntry, $transType), '/' ))}</rest:forward>))
  
else if ($counterContent <= $max) then
  
  ( sc:runExecutableContent($dbName, $collectionName, $mbaName, $content[$counterContent]),  db:output(<rest:forward>{fn:concat('/enterStates/', string-join(($dbName,$collectionName,$mbaName, $counterContent+1, $counterEntry, $transType), '/' ))}</rest:forward>))
 
 
 else
 
 let $maxStates := fn:count($entrySet)
 return 
 if ($counterEntry <= $maxStates) then 
  db:output(<rest:forward>{fn:concat('/enterStates/', string-join(($dbName,$collectionName,$mbaName,0, $counterEntry +1 , $transType), '/' ))}</rest:forward>)
 else 
 db:output(<rest:forward>{fn:concat('/controller/', string-join(($dbName,$collectionName,$mbaName, $transType), '/' ))}</rest:forward>) 

};

(:~
   controlls the to be called functions 
  : @param $dbName  The name of the database
  : @param $collectionName  The name of the collection
  : @param $mbaName The name of the MBA
  : @param $transType The current TransitionsType
 :)
declare
  %rest:path("/controller/{$dbName}/{$collectionName}/{$mbaName}/{$transType}")
  %rest:GET
updating function page:controller(
    $dbName as xs:string, $collectionName as xs:string , $mbaName as xs:string, $transType as xs:string)
{
 
 let $mba   := mba:getMBA($dbName, $collectionName, $mbaName)
 let $configuration := mba:getConfiguration($mba)
 let $dataModels := mba:selectAllDataModels($mba)

return
  if($transType != 'external' and $transType !='init') then
     ( db:output(<rest:forward>{fn:concat('/processPendingTransitions/', string-join(($dbName,$collectionName,$mbaName), '/' ))}</rest:forward>) )
  else
    if (mba:getRunning($mba)) then 
    ( 
     if( not(fn:empty(mba:getStatesToInvokeQueue($mba)/*))) then
       (db:output(<rest:forward>{fn:concat('/invokeStates/', string-join(($dbName,$collectionName,$mbaName), '/' ))}</rest:forward>) )
     else
        if(fn:empty(sc:selectEventlessTransitions($configuration,$dataModels)) and 
            fn:empty(mba:getInternalEventQueue($mba)/*) and fn:empty(mba:getExternalEventQueue($mba)/*))  then 
            ()
        else
          db:output(<rest:forward>{fn:concat('/processPendingTransitions/', string-join(($dbName,$collectionName,$mbaName), '/' ))}</rest:forward>) 
     )
    else 
      db:output(<rest:forward>{fn:concat('/exitInterpreter/', string-join(($dbName,$collectionName,$mbaName,0), '/' ))}</rest:forward>)
};





(:~
   create The States to be invoked
  : @param $dbName  The name of the database
  : @param $collectionName  The name of the collection
  : @param $mbaName The name of the MBA
 :)
declare
  %rest:path("/invokeStates/{$dbName}/{$collectionName}/{$mbaName}")
  %rest:GET
  updating function page:invoke(
    $dbName as xs:string, $collectionName as xs:string , $mbaName as xs:string)
{
  
  let $mba   := mba:getMBA($dbName, $collectionName, $mbaName)
  return 
  
  (sc:invokeStates($mba)
 ,mba:deleteStatesToInvokeQueue($mba), 
  db:output(<rest:forward>{fn:concat('/processPendingTransitions/', string-join(($dbName,$collectionName,$mbaName), '/' ))}</rest:forward>) )  
  


};


(:~
   exiting the interpreter (leaving all states)
  : @param $dbName  The name of the database
  : @param $collectionName  The name of the collection
  : @param $mbaName The name of the MBA
  : @param $mbaName The name of the MBA
 :)
declare
  %rest:path("/exitInterpreter/{$dbName}/{$collectionName}/{$mbaName}/{$counter}")
  %rest:GET
  updating function page:exitInterpreter(
    $dbName as xs:string, $collectionName as xs:string , $mbaName as xs:string, $counter as xs:integer)
{
  
  let $mba   := mba:getMBA($dbName, $collectionName, $mbaName)
  let $states := mba:getStatesToInvokeQueue($mba)
  let $configuration := mba:getConfiguration($mba)
  return
  if ($counter = 0) then 
  (
    if(not($dbName = 'myMBAse')) then
    (
     for $s in $configuration
    
    return  if (sc:isFinalState($s)and not (fn:empty($s/parent::*[self::sc:scxml])) )  then    
    (
    let $exitSet := $configuration
    return 
    (mba:updateCurrentExitSet($mba,$exitSet),
    db:output(<rest:forward>{fn:concat('/exitStates/', string-join(($dbName,$collectionName,$mbaName, 0, 1, 'exit'), '/' ))}</rest:forward>)))
else()
)
else
()
 
)
else
(
 
     for $s in mba:getCurrentExitSet($mba)
    
  return (: runExitcontent , cancelInvoke, :)
  if (sc:isFinalState($s)and not (fn:empty($s/parent::*[self::sc:scxml])))  then
  let $invokeid := mba:getParentInvoke($mba)/id
  let $name := 'done.invoke' || '.' ||$invokeid
  let $event := <event invokeid="{$invokeid}"  name="{$name}"></event>
  
  let $src := mba:getParentInvoke($mba)/parent

  let $insertMba := sc:getMBAFromText($src)

  return (mba:enqueueExternalEvent($insertMba, $event)
 ,
  db:drop($dbName))


  else
  ())
};
 
 
 
 




