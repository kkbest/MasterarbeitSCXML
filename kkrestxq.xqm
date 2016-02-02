
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

(:´



page:db:output(
<rest:response>
    <http:response status="404" message="I was not found.">
      <http:header name="Content-Language" value="en"/>
      <http:header name="Content-Type" value="text/html; charset=utf-8"/>
    </http:response>
  </rest:response>)
,<rest:forward>{'asdf' }</rest:forward> :)

};




(:
this function returns a Result for an mba with an certain Id
:)
declare
  %rest:path("/getResult/{$dbName}/{$collectionName}/{$mbaName}")
  %rest:GET
  function page:getResult(
    $dbName as xs:string, $collectionName as xs:string , $mbaName as xs:string)
{


 kk:getResult($dbName, $collectionName, $mbaName, '1')

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



(:~
 : This function returns an XML response message.
 : @param $world  string to be included in the response
 : @return response element 
 :)
declare
  %rest:path("/kktest/{$world}")
  %rest:GET
  function page:hello2(
    $world as xs:string)
    as element(response)
{
  <response>
    <title>Hello to you { $world }!</title>
    <time>The current time is: { current-time() }</time>
  </response>
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
};



declare
  %rest:path("/addandWait/{$dbName}/{$collectionName}/{$mbaName}/{$value}")
  %rest:GET
  updating function page:addWaitValue(
    $dbName as xs:string, $collectionName as xs:string , $mbaName as xs:string, $value as xs:string)
{

let $externalEvent := <event name="setDegree" xmlns="">
<degree xmlns="">{$value}</degree>
</event>
 
 
let $mba := mba:getMBA($dbName, $collectionName, $mbaName)

return mba:enqueueExternalEvent($mba, $externalEvent),
 db:output(<rest:forward>{fn:concat('/macroStep1/', string-join(($dbName,$collectionName,$mbaName,'1'), '/' ))}</rest:forward>)

};

declare
  %rest:path("/macroStep/{$dbName}/{$collectionName}/{$mbaName}")
  %rest:GET
  updating function page:macroStep(
    $dbName as xs:string, $collectionName as xs:string , $mbaName as xs:string)
{

let $string := string-join(($dbName,$collectionName,$mbaName), '/' )

let $url := 'http://pagehost:8984/'
return



 kk:removeFromInsertLog($dbName, $collectionName, $mbaName),
  db:output(<rest:forward>{fn:concat('/getNextExternalEvent/', string-join(($dbName,$collectionName,$mbaName,'false'), '/' ))}</rest:forward>)

};


declare
  %rest:path("/macroStep1/{$dbName}/{$collectionName}/{$mbaName}/{$id}")
  
  %rest:GET
  updating function page:macroStepId(
    $dbName as xs:string, $collectionName as xs:string , $mbaName as xs:string, $id as xs:string)
{

let $string := string-join(($dbName,$collectionName,$mbaName), '/' )

let $url := 'http://pagehost:8984/'
return



 kk:removeFromInsertLog($dbName, $collectionName, $mbaName),
  db:output(<rest:forward>{fn:concat('/getNextExternalEvent/', string-join(($dbName,$collectionName,$mbaName,'true'), '/' ))}</rest:forward>)

};






declare
  %rest:path("/getNextExternalEvent/{$dbName}/{$collectionName}/{$mbaName}/{$return}")
  %rest:GET
  updating function page:getNextExternalEvent(
    $dbName as xs:string, $collectionName as xs:string , $mbaName as xs:string, $return as xs:string)
{


 kk:getNextExternalEvent($dbName, $collectionName, $mbaName),
 
  db:output(<rest:forward>{fn:concat('/trytoupdate/', string-join(($dbName,$collectionName,$mbaName,'1', $return), '/' ))}</rest:forward>)

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


if ($counter < $max) then
 (kk:getandExecuteExecutablecontent($dbName, $collectionName, $mbaName , $counter),
   db:output(<rest:forward>{fn:concat('/trytoupdate/', string-join(($dbName,$collectionName,$mbaName,$counterneu, $return), '/' ))}</rest:forward>))
 else
  (kk:getandExecuteExecutablecontent($dbName, $collectionName, $mbaName , $counter),
   db:output(<rest:forward>{fn:concat('/changeCurrentStatus/', string-join(($dbName,$collectionName,$mbaName, $return), '/' ))}</rest:forward>),
 insert node mba:getConfiguration(mba:getMBA($dbName,$collectionName,$mbaName)) into mba:getMBA($dbName,$collectionName,$mbaName)/katharina/1 )
   
};


declare
  %rest:path("/changeCurrentStatus/{$dbName}/{$collectionName}/{$mbaName}/{$return}")
  %rest:GET
  updating function page:changeCurrentStatus(
    $dbName as xs:string, $collectionName as xs:string , $mbaName as xs:string, $return as xs:string)
{



 kk:changeCurrentStatus($dbName, $collectionName, $mbaName),
  insert node mba:getConfiguration(mba:getMBA($dbName,$collectionName,$mbaName)) into mba:getMBA($dbName,$collectionName,$mbaName)/katharina/2,
    db:output(<rest:forward>{fn:concat('/removeCurrentExternalEvent/', string-join(($dbName,$collectionName,$mbaName, $return), '/' ))}</rest:forward>)

};


declare
  %rest:path("/removeCurrentExternalEvent/{$dbName}/{$collectionName}/{$mbaName}/{$return}")
  %rest:GET
  updating function page:removeCurrentExternalEvent(
    $dbName as xs:string, $collectionName as xs:string , $mbaName as xs:string, $return)
{



 kk:removeCurrentExternalEvent($dbName, $collectionName, $mbaName),
  insert node mba:getConfiguration(mba:getMBA($dbName,$collectionName,$mbaName)) into mba:getMBA($dbName,$collectionName,$mbaName)/katharina/3,
     db:output(<rest:forward>{fn:concat('/processEventlessTransitions/', string-join(($dbName,$collectionName,$mbaName, $return), '/' ))}</rest:forward>)

};




declare
  %rest:path("/processEventlessTransitions/{$dbName}/{$collectionName}/{$mbaName}/{$return}")
  %rest:GET
  updating function page:processEventlessTransitions(
    $dbName as xs:string, $collectionName as xs:string , $mbaName as xs:string, $return)
{



  kk:processEventlessTransitions($dbName, $collectionName, $mbaName),
     db:output(<rest:forward>{fn:concat('/changecurrentStatusEventless/', string-join(($dbName,$collectionName,$mbaName, $return), '/' ))}</rest:forward>)

};



declare
  %rest:path("/changecurrentStatusEventless/{$dbName}/{$collectionName}/{$mbaName}/{$return}")
  %rest:GET
  updating function page:changeCurrentStatusEventless(
    $dbName as xs:string, $collectionName as xs:string , $mbaName as xs:string, $return)
{

if ($return) then
  ( kk:changeCurrentStatusEventless($dbName, $collectionName, $mbaName),     db:output(<rest:forward>{fn:concat('/getResult/', string-join(($dbName,$collectionName,$mbaName), '/' ))}</rest:forward>))

else
 kk:changeCurrentStatusEventless($dbName, $collectionName, $mbaName),
db:output(
  <response>
    <title>Positiv { $dbName }!</title>
    <title>processEventlessTransitions { $collectionName }!</title>
    <title>Hello to you { $mbaName }!</title>
    <asdfaf>return und so:{ $return}</asdfaf>
    <time>The current time is: { current-time() }</time>
  </response>)

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


if (fn:true()) then 
(
kk:exitStates($dbName,$collectionName,$mbaName), kk:getandExecuteExecutablecontent($dbName, $collectionName, $mbaName , $counter),
   db:output(<rest:forward>{fn:concat('/tryptoupdate/', string-join(($dbName,$collectionName,$mbaName,$counterneu, $return), '/' ))}</rest:forward>)
)
else if ($counter < $max) then
 (kk:getandExecuteExecutablecontent($dbName, $collectionName, $mbaName , $counter),
   db:output(<rest:forward>{fn:concat('/tryptoupdate/', string-join(($dbName,$collectionName,$mbaName,$counterneu, $return), '/' ))}</rest:forward>))
 else
  (kk:getandExecuteExecutablecontent($dbName, $collectionName, $mbaName , $counter),
   db:output(<rest:forward>{fn:concat('/enterStates/', string-join(($dbName,$collectionName,$mbaName, $return), '/' ))}</rest:forward>)) 
   
};

declare
  %rest:path("/enterStates/{$dbName}/{$collectionName}/{$mbaName}/{$counter}/{$return}")
  %rest:GET
  updating function page:enterStates(
    $dbName as xs:string, $collectionName as xs:string , $mbaName as xs:string, $counter as xs:integer, $return as xs:string)
{
  kk:enterStates($dbName, $collectionName, $mbaName),
   db:output(<rest:forward>{fn:concat('/changeCurrentStatus/', string-join(($dbName,$collectionName,$mbaName, $return), '/' ))}</rest:forward>)
};





declare
  %rest:path("/addEvent/{$dbName}/{$collectionName}/{$mbaName}")
  %rest:GET
  updating function page:addEvent(
    $dbName as xs:string, $collectionName as xs:string , $mbaName as xs:string)
{
  (:let $dbName := 'myMBAse'
let $collectionName := 'JohannesKeplerUniversity'
 let $mbaName := 'InformationSystems'
:) 

let $externalEvent := <event name="setDegree" xmlns="">
<degree xmlns="">KSV</degree>
</event>
 
 
let $mba := mba:getMBA($dbName, $collectionName, $mbaName)

return mba:enqueueExternalEvent($mba, $externalEvent),db:output(
 
  <response>
    <title>Positiv { $dbName }!</title>
    <title>addEvent { $collectionName }!</title>
    <title>Hello to you { $mbaName }!</title>
    <time>The current time is: { current-time() }</time>
  </response>)

};




declare
  %rest:path("/addEventt/{$dbName}/{$collectionName}/{$mbaName}")
  %rest:GET
  updating function page:addEventtest(
    $dbName as xs:string, $collectionName as xs:string , $mbaName as xs:string)
{


let $externalEvent := <event name="setDegree" xmlns="">
<degree xmlns="">Dr.</degree>
</event>
 
 (:direct call of local function possible ? careful with updating at the same time.. but.. maybe possible to call directly:)
let $mba := mba:getMBA($dbName, $collectionName, $mbaName)

let $counter := kk:getCounter($dbName, $collectionName, $mbaName)

return mba:enqueueExternalEvent($mba, $externalEvent), db:output("return something")
,
page:simplecallfunction($dbName, $collectionName, $mbaName,kk:getCounter($dbName, $collectionName, $mbaName))

(:´



page:db:output(
<rest:response>
    <http:response status="404" message="I was not found.">
      <http:header name="Content-Language" value="en"/>
      <http:header name="Content-Type" value="text/html; charset=utf-8"/>
    </http:response>
  </rest:response>)
,<rest:forward>{'asdf' }</rest:forward> :)

};


declare updating function page:simplecallfunction(    $dbName as xs:string, $collectionName as xs:string , $mbaName as xs:string, $id as xs:string)
{
  let $mba := mba:getMBA($dbName, $collectionName, $mbaName)
 return kk:updateCounter($dbName,$collectionName,$mbaName), 
      db:output(<rest:forward>{fn:concat('/macrostep/', string-join(($dbName,$collectionName,$mbaName), '/' ))}</rest:forward>)

  
};






declare
  %rest:path("/addEvent/{$dbName}/{$collectionName}/{$mbaName}/{$value}")
  %rest:GET
  updating function page:addEventValue(
    $dbName as xs:string, $collectionName as xs:string , $mbaName as xs:string, $value as xs:string)
{
 (: let $dbName := 'myMBAse'
let $collectionName := 'JohannesKeplerUniversity'
 let $mbaName := 'InformationSystems'
:)


let $externalEvent := <event name="setDegree" xmlns="">
<degree xmlns="">{$value}</degree>
</event>
 
 
let $mba := mba:getMBA($dbName, $collectionName, $mbaName)

return mba:enqueueExternalEvent($mba, $externalEvent),db:output(
 
  <response>
    <title>Positiv { $dbName }!</title>
    <title>addEvent { $collectionName }!</title>
    <title>Hello to you { $mbaName }!</title>
    <addEvent> {$value} </addEvent>
    <time>The current time is: { current-time() }</time>
  </response>)

};

(:
http://pagehost:8984/myMBAse/JohannesKeplerUniversity/InformationSystems/&lt;event name=\&quot;setDegree\&quot; xmlns=\&quot;\&quot;&gt;&quot; + &quot; &lt;degree xmlns=\&quot;\&quot;&gt;MSc&lt;/degree&gt;&quot; + &quot;&lt;/event&gt;


 %rest:GET updating function page:hello($dbName, $collectionName, $mbaName) {

};
:)