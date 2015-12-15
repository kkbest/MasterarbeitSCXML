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
http://localhost:8984/myMBAse/JohannesKeplerUniversity/InformationSystems/&lt;event name=\&quot;setDegree\&quot; xmlns=\&quot;\&quot;&gt;&quot; + &quot; &lt;degree xmlns=\&quot;\&quot;&gt;MSc&lt;/degree&gt;&quot; + &quot;&lt;/event&gt;




declare variable $dbName := 'myMBAse';
declare variable $collectionName := 'JohannesKeplerUniversity';
declare variable $mbaName := 'InformationSystems';

:)

declare %rest:path("enqueueexternalEvent/{$dbName}/{$collectionName}/{mbaName}")

 %rest:GET updating function page:hello($dbName, $collectionName, $mbaName) {
try
{

let $externalEvent := <event name="setDegree" xmlns="">
<degree xmlns="">MSc</degree>
</event>
 
 
let $mba := mba:getMBA($dbName, $collectionName, $mbaName)

return mba:enqueueExternalEvent($mba, $externalEvent),db:output(" ja da passiert was")
}
catch *
 {
   (),db:output(" ja da passiert böses ")
 }
};

