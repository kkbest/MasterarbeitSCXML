
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
      <form method="post" action="form1">
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
  %rest:path("/form1")
  %rest:POST
  %rest:form-param("message","{$message}", "(no message)")
    %rest:form-param("event","{$event}", "(no event)")
%rest:form-param("addText","{$addText}", "(no addText)")
%rest:form-param("dbName","{$dbName}", "(no dbName)")
%rest:form-param("collectionName","{$collectionName}", "(no collectionName)")
%rest:form-param("mbaName","{$mbaName}", "(no mbaName)")
  %rest:header-param("User-Agent", "{$agent}")
updating  function page:hello-postman(
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
            <id>{kk:getCounter($dbName, $collectionName, $mbaName)}</id>
      </event>

    case "addSchool" 

      return
       <event name="{$event}" xmlns="">
          <name xmlns="">{$addText}</name>
          <id>{kk:getCounter($dbName, $collectionName, $mbaName)}</id>
        </event>
        
       case "addDegree"
             return
              <event name="{$event}" xmlns="">
          <text xmlns="">{$addText}</text>
          <id>{kk:getCounter($dbName, $collectionName, $mbaName)}</id>
        </event>
        case "removeDegree"
              return
       <event name="{$event}" xmlns="">
          <text xmlns="">{$addText}</text>
          <id>{kk:getCounter($dbName, $collectionName, $mbaName)}</id>
        </event>
         case "addCourse"
               return
       <event name="{$event}" xmlns="">
         <name xmlns="">{$addText}</name>
          <id>{kk:getCounter($dbName, $collectionName, $mbaName)}</id>
        </event>
       
   default
   


return 
   copy $c := fn:parse-xml-fragment(fn:replace($addText, '"', "'"))/*
   modify
   insert node <id>{kk:getCounter($dbName, $collectionName, $mbaName)}</id>  into $c
   return $c
   
      
  return mba:enqueueExternalEvent($mba, $externalEvent),kk:updateCounter($dbName,$collectionName,$mbaName),
db:output(<response> 
  <result> added Eevent</result>
    <addText> {$addText}</addText>
  <parse> {fn:replace($addText, '"', "'") }</parse>
  <counter> {kk:getCounter($dbName, $collectionName, $mbaName)}</counter>
</response>)
   
   (: return  :)
  
};









declare
  %rest:path("/add/{$dbName}/{$collectionName}/{$mbaName}/{$value}")
  %rest:GET
  updating function page:addEventtoQueue(
    $dbName as xs:string, $collectionName as xs:string , $mbaName as xs:string, $value as xs:string)
{


let $externalEvent := <event name="setDegree" xmlns="">
<degree xmlns="">{$value}</degree>
<id>{kk:getCounter($dbName, $collectionName, $mbaName)}</id>
</event>
 
let $mba := mba:getMBA($dbName, $collectionName, $mbaName)

(: get Counter, update Counter and add Event to Eventqueue:)

return mba:enqueueExternalEvent($mba, $externalEvent),kk:updateCounter($dbName,$collectionName,$mbaName),
db:output(<response> 
  <result> added Eevent</result>
  <value> {$value}</value> 
  <counter> {kk:getCounter($dbName, $collectionName, $mbaName)}</counter>
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
 db:output(<rest:forward>{fn:concat('/initSCXML/', string-join(($dbName,$collectionName,$mbaName), '/' ))}</rest:forward>)

};


declare
  %rest:path("/initSCXML/{$dbName}/{$collectionName}/{$mbaName}")
  %rest:GET
  updating function page:initSCXML(
    $dbName as xs:string, $collectionName as xs:string , $mbaName as xs:string)
{


let $url := 'http://pagehost:8984/'
return

kk:initSCXMLRest($dbName,$collectionName,$mbaName)
,
 db:output(<rest:forward>{fn:concat('/enterStatesI/', string-join(($dbName,$collectionName,$mbaName), '/' ))}</rest:forward>)

};


declare
  %rest:path("/enterStatesI/{$dbName}/{$collectionName}/{$mbaName}")
  %rest:GET
  updating function page:enterStatesI(
    $dbName as xs:string, $collectionName as xs:string , $mbaName as xs:string)
{


let $url := 'http://pagehost:8984/'
return

kk:enterStatesI($dbName,$collectionName,$mbaName)
,
 db:output(<rest:forward>{fn:concat('/removeFromUpdateLog/', string-join(($dbName,$collectionName,$mbaName), '/' ))}</rest:forward>)

};


declare
  %rest:path("/removeFromUpdateLog/{$dbName}/{$collectionName}/{$mbaName}")
  %rest:GET
  updating function page:removeFromUpdateLog(
    $dbName as xs:string, $collectionName as xs:string , $mbaName as xs:string)
{


let $url := 'http://pagehost:8984/'
return

kk:removeFromUpdateLog($dbName,$collectionName,$mbaName)

(: enter First intial States .. vlt alreade in Init SCXML :)
};




declare
  %rest:path("/macroStep/{$dbName}/{$collectionName}/{$mbaName}")
  %rest:GET
  updating function page:macroStep(
    $dbName as xs:string, $collectionName as xs:string , $mbaName as xs:string)
{




 kk:removeFromInsertLog($dbName, $collectionName, $mbaName),
  db:output(<rest:forward>{fn:concat('/getNextExternalEvent/', string-join(($dbName,$collectionName,$mbaName,'false'), '/' ))}</rest:forward>)

};




declare
  %rest:path("/getNextExternalEvent/{$dbName}/{$collectionName}/{$mbaName}/{$return}")
  %rest:GET
  updating function page:getNextExternalEvent(
    $dbName as xs:string, $collectionName as xs:string , $mbaName as xs:string, $return as xs:string)
{


 kk:getNextExternalEvent($dbName, $collectionName, $mbaName),
 
  db:output(<rest:forward>{fn:concat('/microstep/', string-join(($dbName,$collectionName,$mbaName,'0', $return), '/' ))}</rest:forward>)

};


declare
  %rest:path("/trytoupdate/{$dbName}/{$collectionName}/{$mbaName}/{$counter}/{$return}")
  %rest:GET
  updating function page:tryptoupdaterec(
    $dbName as xs:string, $collectionName as xs:string , $mbaName as xs:string, $counter as xs:integer, $return as xs:string)
{

let $max := fn:count(kk:getExecutableContents($dbName, $collectionName, $mbaName))
let $counterneu := $counter + 1
return


if ($counter <= $max) then
 (kk:getandExecuteExecutablecontent($dbName, $collectionName, $mbaName , $counter),
   db:output(<rest:forward>{fn:concat('/trytoupdate/', string-join(($dbName,$collectionName,$mbaName,$counterneu, $return), '/' ))}</rest:forward>))
 else
  (kk:getandExecuteExecutablecontent($dbName, $collectionName, $mbaName , $counter),
   db:output(<rest:forward>{fn:concat('/changeCurrentStatus/', string-join(($dbName,$collectionName,$mbaName, $return), '/' ))}</rest:forward>)) 
   
};


declare
  %rest:path("/changeCurrentStatus/{$dbName}/{$collectionName}/{$mbaName}/{$return}")
  %rest:GET
  updating function page:changeCurrentStatus(
    $dbName as xs:string, $collectionName as xs:string , $mbaName as xs:string, $return as xs:string)
{



 kk:changeCurrentStatus($dbName, $collectionName, $mbaName),
    db:output(<rest:forward>{fn:concat('/removeCurrentExternalEvent/', string-join(($dbName,$collectionName,$mbaName, $return), '/' ))}</rest:forward>)

};


declare
  %rest:path("/removeCurrentExternalEvent/{$dbName}/{$collectionName}/{$mbaName}/{$return}")
  %rest:GET
  updating function page:removeCurrentExternalEvent(
    $dbName as xs:string, $collectionName as xs:string , $mbaName as xs:string, $return)
{



 kk:removeCurrentExternalEvent($dbName, $collectionName, $mbaName),
     db:output(<rest:forward>{fn:concat('/processEventlessTransitions/', string-join(($dbName,$collectionName,$mbaName, $return), '/' ))}</rest:forward>)

};




declare
  %rest:path("/processEventlessTransitions/{$dbName}/{$collectionName}/{$mbaName}/{$return}")
  %rest:GET
  updating function page:processEventlessTransitions(
    $dbName as xs:string, $collectionName as xs:string , $mbaName as xs:string, $return)
{

(: again ExitStates, run..  EnterSTates:)


  kk:processEventlessTransitions($dbName, $collectionName, $mbaName),
     db:output(<rest:forward>{fn:concat('/changecurrentStatusEventless/', string-join(($dbName,$collectionName,$mbaName, $return), '/' ))}</rest:forward>)

};

declare
  %rest:path("/changeCurrentStatusEventless/{$dbName}/{$collectionName}/{$mbaName}/{$return}")
  %rest:GET
  updating function page:changecurrentStatusEventless(
    $dbName as xs:string, $collectionName as xs:string , $mbaName as xs:string, $return)
{

(: again ExitStates, run..  EnterSTates:)

kk:changeCurrentStatusEventless($dbName, $collectionName, $mbaName),
     db:output(<rest:forward>{fn:concat('/changecurrentStatusEventless/', string-join(($dbName,$collectionName,$mbaName, $return), '/' ))}</rest:forward>)

};
  




declare
  %rest:path("/microstep/{$dbName}/{$collectionName}/{$mbaName}/{$counter}/{$return}")
  %rest:GET
  updating function page:microstep(
    $dbName as xs:string, $collectionName as xs:string , $mbaName as xs:string, $counter as xs:integer, $return as xs:string)
{

let $max := fn:count(kk:getExecutableContents($dbName, $collectionName, $mbaName))
let $counterneu := $counter + 1
return


if ($counter = 0) then 
(
kk:exitStates($dbName,$collectionName,$mbaName),
   db:output(<rest:forward>{fn:concat('/microstep/', string-join(($dbName,$collectionName,$mbaName,$counterneu, $return), '/' ))}</rest:forward>)
)
else if ($counter <= $max) then
 (kk:getandExecuteExecutablecontent($dbName, $collectionName, $mbaName , $counter),
   db:output(<rest:forward>{fn:concat('/microstep/', string-join(($dbName,$collectionName,$mbaName,$counterneu, $return), '/' ))}</rest:forward>))
 else
  (kk:getandExecuteExecutablecontent($dbName, $collectionName, $mbaName , $counter),
   db:output(<rest:forward>{fn:concat('/enterStates/', string-join(($dbName,$collectionName,$mbaName, $return), '/' ))}</rest:forward>)) 
   
};





declare
  %rest:path("/enterStates/{$dbName}/{$collectionName}/{$mbaName}/{$return}")
  %rest:GET
  updating function page:enterStates(
    $dbName as xs:string, $collectionName as xs:string , $mbaName as xs:string, $return as xs:string)
{
  
    kk:enterStates($dbName, $collectionName, $mbaName),
   db:output(<rest:forward>{fn:concat('/changeCurrentStatus/', string-join(($dbName,$collectionName,$mbaName,$return), '/' ))}</rest:forward>)
};
