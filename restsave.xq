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
  function local:hello2(
    $world as xs:string)
    as element(response)
{
  <response>
    <title>Hello to you { $world }!</title>
    <time>The current time is: { current-time() }</time>
  </response>
};



(:
let $request :=
  <http:request href='http://localhost:8984/rest'
    method='post' username='admin' password='admin' send-authorization='true'>
    <http:body media-type='application/xml'>
      <query xmlns="http://basex.org/rest">
        <text><![CDATA[
          <html>{
            for $i in 1 to 3
            return <div>Section {$i }</div>
          }</html>
        ]]></text>
      </query>
    </http:body>
  </http:request>
return http:send-request($request)

:)

declare
  %rest:path("/removeFromInsertLog/{$dbName}/{$collectionName}/{$mbaName}")
  %rest:GET
  updating function local:removeFromInsertLog(
    $dbName as xs:string, $collectionName as xs:string , $mbaName as xs:string)
{
(:  let $dbName := 'myMBAse'
let $collectionName := 'JohannesKeplerUniversity'
 let $mbaName := 'InformationSystems'
:)
let $string := string-join(($dbName,$collectionName,$mbaName), '/' )

let $url := 'http://localhost:8984/'
return



 kk:removeFromInsertLog($dbName, $collectionName, $mbaName),
 db:output(<rest:forward>/getNextExternalEvent/myMBAse/JohannesKeplerUniversity/InformationSystems</rest:forward>)

};


declare
  %rest:path("/getNextExternalEvent/{$dbName}/{$collectionName}/{$mbaName}")
  %rest:GET
  updating function local:getNextExternalEvent(
    $dbName as xs:string, $collectionName as xs:string , $mbaName as xs:string)
{
(:  let $dbName := 'myMBAse'
let $collectionName := 'JohannesKeplerUniversity'
 let $mbaName := 'InformationSystems'
:)



 kk:getNextExternalEvent($dbName, $collectionName, $mbaName),
  db:output(<rest:forward>/tryptoupdate/myMBAse/JohannesKeplerUniversity/InformationSystems</rest:forward>)

};

declare
  %rest:path("/tryptoupdate/{$dbName}/{$collectionName}/{$mbaName}")
  %rest:GET
  updating function local:tryptoupdate(
    $dbName as xs:string, $collectionName as xs:string , $mbaName as xs:string)
{
(:  let $dbName := 'myMBAse'
let $collectionName := 'JohannesKeplerUniversity'
 let $mbaName := 'InformationSystems'
:)

 kk:tryptoupdate($dbName, $collectionName, $mbaName),
  db:output(<rest:forward>/changeCurrentStatus/myMBAse/JohannesKeplerUniversity/InformationSystems</rest:forward>)


};

declare
  %rest:path("/changeCurrentStatus/{$dbName}/{$collectionName}/{$mbaName}")
  %rest:GET
  updating function local:changeCurrentStatus(
    $dbName as xs:string, $collectionName as xs:string , $mbaName as xs:string)
{
(:  let $dbName := 'myMBAse'
let $collectionName := 'JohannesKeplerUniversity'
 let $mbaName := 'InformationSystems'
:)


 kk:changeCurrentStatus($dbName, $collectionName, $mbaName),
  db:output(<rest:forward>/removeCurrentExternalEvent/myMBAse/JohannesKeplerUniversity/InformationSystems</rest:forward>)

};


declare
  %rest:path("/removeCurrentExternalEvent/{$dbName}/{$collectionName}/{$mbaName}")
  %rest:GET
  updating function local:removeCurrentExternalEvent(
    $dbName as xs:string, $collectionName as xs:string , $mbaName as xs:string)
{
(:  let $dbName := 'myMBAse'
let $collectionName := 'JohannesKeplerUniversity'
 let $mbaName := 'InformationSystems'
:)


 kk:removeCurrentExternalEvent($dbName, $collectionName, $mbaName),
 db:output(<rest:forward>/processEventlessTransitions/myMBAse/JohannesKeplerUniversity/InformationSystems</rest:forward>)


};




declare
  %rest:path("/processEventlessTransitions/{$dbName}/{$collectionName}/{$mbaName}")
  %rest:GET
  updating function local:processEventlessTransitions(
    $dbName as xs:string, $collectionName as xs:string , $mbaName as xs:string)
{
(:  let $dbName := 'myMBAse'
let $collectionName := 'JohannesKeplerUniversity'
 let $mbaName := 'InformationSystems'
:)
try
{


 kk:processEventlessTransitions($dbName, $collectionName, $mbaName),
db:output(
  <response>
    <title>Positiv { $dbName }!</title>
    <title>processEventlessTransitions { $collectionName }!</title>
    <title>Hello to you { $mbaName }!</title>
    <time>The current time is: { current-time() }</time>
  </response>)
}
catch *
 {
   (),db:output(
 
  <response>
    <title>Negativ { $dbName }!</title>
    <title>processEventlessTransitions { $collectionName }!</title>
    <title>Hello to you { $mbaName }!</title>
    <time>The current time is: { current-time() }</time>
  </response>)
}
};




declare
  %rest:path("/addEvent/{$dbName}/{$collectionName}/{$mbaName}")
  %rest:GET
  updating function local:addEvent(
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
(:
http://localhost:8984/myMBAse/JohannesKeplerUniversity/InformationSystems/&lt;event name=\&quot;setDegree\&quot; xmlns=\&quot;\&quot;&gt;&quot; + &quot; &lt;degree xmlns=\&quot;\&quot;&gt;MSc&lt;/degree&gt;&quot; + &quot;&lt;/event&gt;


 %rest:GET updating function local:hello($dbName, $collectionName, $mbaName) {

};
:)
declare variable $dbName := 'myMBAse';
declare variable $collectionName := 'JohannesKeplerUniversity';
declare variable $mbaName := 'InformationSystems';

let $string := string-join(($dbName,$collectionName,$mbaName), '/' )

let $url := 'http://localhost:8984/'



(:
let $f1  := doc(fn:concat($url, 'removeFromInsertLog/', $string )):)


return mba:getMBA($dbName, $collectionName, $mbaName)