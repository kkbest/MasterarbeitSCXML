
module namespace page = 'http://basex.org/kk/web-page';


import module namespace kk = 'http://www.w3.org/2005/07/kk';
import module namespace scx='http://www.w3.org/2005/07/scxml/extension/';
import module namespace functx = 'http://www.functx.com';
import module namespace mba='http://www.dke.jku.at/MBA'; 
import module namespace sc = 'http://www.w3.org/2005/07/scxml';
import module namespace sync = 'http://www.dke.jku.at/MBA/Synchronization';


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

(:
this function returns a Result for an mba with an certain Id
:)
declare
  %rest:path("/getResult/{$dbName}/{$collectionName}/{$mbaName}/{$id}")
  %rest:GET
  function page:getResultId(
    $dbName as xs:string, $collectionName as xs:string , $mbaName as xs:string , $id as xs:string)
{


 kk:getResult($dbName, $collectionName, $mbaName, $id)

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
 Starts the Macrostep 
:)
declare
  %rest:path("/runMacroStep/{$dbName}/{$collectionName}/{$mbaName}")
  %rest:GET
  updating function page:removeFromInsertLog(
    $dbName as xs:string, $collectionName as xs:string , $mbaName as xs:string)
{

let $url := 'http://pagehost:8984/'
return

 kk:removeFromInsertLog($dbName, $collectionName, $mbaName),
 db:output(<rest:forward>{fn:concat('/getNextExternalEvent/', string-join(($dbName,$collectionName,$mbaName,'false'), '/' ))}</rest:forward>)

};

declare
  %rest:path("/runMacroStep/{$dbName}/{$collectionName}/{$mbaName}/{$return}")
  %rest:GET
  updating function page:removeFromInsertLog(
    $dbName as xs:string, $collectionName as xs:string , $mbaName as xs:string, $return as xs:boolean)
{

let $url := 'http://pagehost:8984/'
return

 kk:removeFromInsertLog($dbName, $collectionName, $mbaName),
 db:output(<rest:forward>{fn:concat('/getNextExternalEvent/', string-join(($dbName,$collectionName,$mbaName,$return), '/' ))}</rest:forward>)

};

declare
  %rest:path("/getNextExternalEvent/{$dbName}/{$collectionName}/{$mbaName}/{$return}")
  %rest:GET
  updating function page:getNextExternalEvent(
    $dbName as xs:string, $collectionName as xs:string , $mbaName as xs:string, $return as xs:boolean)
{


 kk:getNextExternalEvent($dbName, $collectionName, $mbaName),
  db:output(<rest:forward>{fn:concat('/tryptoupdate/', string-join(($dbName,$collectionName,$mbaName,'1', $return), '/' ))}</rest:forward>)
 

};

declare
  %rest:path("/tryptoupdate/{$dbName}/{$collectionName}/{$mbaName}/{$counter}/{$return}")
  %rest:GET
  updating function page:tryptoupdaterec(
    $dbName as xs:string, $collectionName as xs:string , $mbaName as xs:string, $counter as xs:integer, $return as xs:boolean)
{

let $max := fn:count(kk:getExecutableContents($dbName, $collectionName, $mbaName))
let $counterneu := $counter + 1
return

db:output(
 
  <response>
    <title>vor update and with dbName: { $dbName }!</title>
    <title>addEvent with collectionName: { $collectionName }!</title>
    <title>Hello to you with mbaName :{ $mbaName }!</title>
    <title>Yes with return:{ $return }!</title>
    <title>Yes with max:{ $max }!</title>
    <title>Yes with counterneu:{ $counterneu }!</title>
    <time>The current time is: { current-time() }</time>
  </response>)
  (:

if ($counter < $max) then
 (kk:getandExecuteExecutablecontent($dbName, $collectionName, $mbaName , $counter),
   db:output(<rest:forward>{fn:concat('/tryptoupdate/', string-join(($dbName,$collectionName,$mbaName,$counterneu,$return), '/' ))}</rest:forward>))
 else
  (kk:getandExecuteExecutablecontent($dbName, $collectionName, $mbaName , $counter),
   db:output(<rest:forward>{fn:concat('/changeCurrentStatus/', string-join(($dbName,$collectionName,$mbaName,$return), '/' ))}</rest:forward>)) :)

};


declare
  %rest:path("/changeCurrentStatus/{$dbName}/{$collectionName}/{$mbaName}/{$return}")
  %rest:GET
  updating function page:changeCurrentStatus(
    $dbName as xs:string, $collectionName as xs:string , $mbaName as xs:string, $return as xs:boolean)
{

 kk:changeCurrentStatus($dbName, $collectionName, $mbaName),
    db:output(<rest:forward>{fn:concat('/removeCurrentExternalEvent/', string-join(($dbName,$collectionName,$mbaName, $return), '/' ))}</rest:forward>)

};


declare
  %rest:path("/removeCurrentExternalEvent/{$dbName}/{$collectionName}/{$mbaName}/{$return}")
  %rest:GET
  updating function page:removeCurrentExternalEvent(
    $dbName as xs:string, $collectionName as xs:string , $mbaName as xs:string, $return as xs:boolean)
{
(:  let $dbName := 'myMBAse'
let $collectionName := 'JohannesKeplerUniversity'
 let $mbaName := 'InformationSystems'
:)


 kk:removeCurrentExternalEvent($dbName, $collectionName, $mbaName),
     db:output(<rest:forward>{fn:concat('/processEventlessTransitions/', string-join(($dbName,$collectionName,$mbaName,$return), '/' ))}</rest:forward>)

};




declare
  %rest:path("/processEventlessTransitions/{$dbName}/{$collectionName}/{$mbaName}/{$return}")
  %rest:GET
  updating function page:processEventlessTransitions(
    $dbName as xs:string, $collectionName as xs:string , $mbaName as xs:string, $return as xs:boolean)
{

 kk:processEventlessTransitions($dbName, $collectionName, $mbaName),
 if ($return) then 
      db:output(<rest:forward>{fn:concat('/getResult/', string-join(($dbName,$collectionName,$mbaName), '/' ))}</rest:forward>)

  else
  db:output(
  (: hier dann die Rückgabe der Form:)

  <response>
    <title>Positiv { $dbName }!</title>
    <title>Macrostep finished processEventless { $collectionName }!</title>
    <title>Hello to you { $mbaName }!</title>
    <time>The current time is: { current-time() }</time>
    <isvalue> {$return}</isvalue>
  </response>)
  
};




declare
  %rest:path("/addEvent/{$dbName}/{$collectionName}/{$mbaName}")
  %rest:GET
  updating function page:addEvent(
    $dbName as xs:string, $collectionName as xs:string , $mbaName as xs:string)
{
  let $dbName := 'myMBAse'
let $collectionName := 'JohannesKeplerUniversity'
 let $mbaName := 'InformationSystems'

return 

try
{

let $externalEvent := <event name="setDegree" xmlns="">
<degree xmlns="">MSc</degree>
</event>
 
 
let $mba := mba:getMBA($dbName, $collectionName, $mbaName)

return mba:enqueueExternalEvent($mba, $externalEvent),db:output(
 
  <response>
    <title>Positiv { $dbName }!</title>
    <title>addEvent { $collectionName }!</title>
    <title>Hello to you { $mbaName }!</title>
    <time>The current time is: { current-time() }</time>
  </response>)
}
catch *
 {
   (),db:output(
 
  <response>
    <title>Negativ { $dbName }!</title>
    <title>addEvent { $collectionName }!</title>
    <title>Hello to you { $mbaName }!</title>
    <time>The current time is: { current-time() }</time>
  </response>)
}
};



declare
  %rest:path("/addEvent/{$dbName}/{$collectionName}/{$mbaName}/{$value}")
  %rest:GET
  updating function page:addEventValue(
    $dbName as xs:string, $collectionName as xs:string , $mbaName as xs:string, $value as xs:string)
{
  

let $externalEvent := <event name="setDegree" xmlns="">
<degree xmlns="">{$value}</degree>
</event>
 
 
let $mba := mba:getMBA($dbName, $collectionName, $mbaName)

return mba:enqueueExternalEvent($mba, $externalEvent),db:output( 

  <response>
    <title>Negativ { $dbName }!</title>
    <title>addEvent { $collectionName }!</title>
    <title>Hello to you { $mbaName }!</title>
    <time>The current time is: { current-time() }</time>
  </response>
  
)

};


declare
  %rest:path("/addandwait/{$dbName}/{$collectionName}/{$mbaName}/{$value}")
  %rest:GET
  updating function page:addandWait(
    $dbName as xs:string, $collectionName as xs:string , $mbaName as xs:string, $value as xs:string)
{


let $externalEvent := <event name="setDegree" xmlns="">
<degree xmlns="">{$value}</degree>
</event>
 
 
let $mba := mba:getMBA($dbName, $collectionName, $mbaName)

return mba:enqueueExternalEvent($mba, $externalEvent), 
    db:output(<rest:forward>{fn:concat('/runMacroStep/', string-join(($dbName,$collectionName,$mbaName,'true'), '/' ))}</rest:forward>)

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

kk:initSCXMLRest($dbName,$collectionName,$mbaName),
 db:output(<rest:forward>{fn:concat('/removeFromInsertLog/', string-join(($dbName,$collectionName,$mbaName), '/' ))}</rest:forward>)

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






