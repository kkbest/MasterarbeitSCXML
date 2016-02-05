import module namespace kk = 'http://www.w3.org/2005/07/kk';
import module namespace scx='http://www.w3.org/2005/07/scxml/extension/';
import module namespace functx = 'http://www.functx.com';
import module namespace mba='http://www.dke.jku.at/MBA'; 
import module namespace sc = 'http://www.w3.org/2005/07/scxml';
import module namespace sync = 'http://www.dke.jku.at/MBA/Synchronization';



declare variable $dbName := 'myMBAse';
declare variable $collectionName := 'JohannesKeplerUniversity';
declare variable $mbaName := 'JohannesKeplerUniversity';

let $string := string-join(($dbName,$collectionName,$mbaName), '/' )

let $url := 'http://localhost:8984/'


let $event := <a> <b>12123</b><b> asd</b></a>

return  mba:getMBA($dbName, $collectionName, $mbaName)

(:let $f1  := doc(fn:concat($url, 'removeFromInsertLog/', $string ))
return doc('http://localhost:8984/removeFromInsertLog/myMBAse/JohannesKeplerUniversity/InformationSystems'),
 mba:getMBA($dbName, $collectionName, $mbaName)
return kk:dowithRest($dbName,$collectionName, $mbaName)
:)

(:let $f1  := doc(fn:concat($url, 'removeFromInsertLog/', $string ))

let $addEvent :=  doc(fn:concat($url, 'addEvent/', $string ))
    let $string := string-join(($dbName,$collectionName,$mbaName), '/' )
  let $url := 'http://localhost:8984/'
  
  let $f1  := doc(fn:concat($url, 'removeFromInsertLog/', $string ))
  let $f2  := doc(fn:concat($url, 'getNextExternalEvent/', $string ))

  let $f3  := doc(fn:concat($url, 'tryptoupdate/', $string ))
  let $f4  := doc(fn:concat($url, 'changeCurrentStatus/', $string ))
  let $f5  := doc(fn:concat($url, 'removeCurrentExternalEvent/', $string ))

  let $f7  := doc(fn:concat($url, 'processEventlessTransitions/', $string ))
  
 
  :)
  
  
  
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
 
  db:output(<rest:forward>{fn:concat('/microstep1/', string-join(($dbName,$collectionName,$mbaName,'0', $return), '/' ))}</rest:forward>)

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
     db:output(<rest:forward>{fn:concat('/processEventlessTransitions/', string-join(($dbName,$collectionName,$mbaName, $return, '0'), '/' ))}</rest:forward>)

};




declare
  %rest:path("/processEventlessTransitions/{$dbName}/{$collectionName}/{$mbaName}/{$return}/{$counter}")
  %rest:GET
  updating function page:processEventlessTransitions(
    $dbName as xs:string, $collectionName as xs:string , $mbaName as xs:string, $return, $counter as xs:string)
{

(: again ExitStates, run..  EnterSTates:)


     

let $max := fn:count(kk:getExecutableContentsEventless($dbName, $collectionName, $mbaName))
let $counterneu := fn:number($counter) + 1
return


if (fn:number($counter) = fn:number('0')) then 
(
kk:exitStates($dbName,$collectionName,$mbaName),
   db:output(<rest:forward>{fn:concat('/processEventlessTransitions/', string-join(($dbName,$collectionName,$mbaName,$counterneu, $return), '/' ))}</rest:forward>)
)
else if (fn:number($counter) <= fn:number($max)) then
 (kk:getAndExecuteEventlessTransitions($dbName, $collectionName, $mbaName , $counter),
   db:output(<rest:forward>{fn:concat('/processEventlessTransitions/', string-join(($dbName,$collectionName,$mbaName,$counterneu, $return), '/' ))}</rest:forward>))
 else
  (kk:getAndExecuteEventlessTransitions($dbName, $collectionName, $mbaName , $counter),
  db:output(<rest:forward>{fn:concat('/changeCurrentStatusEventless/', string-join(($dbName,$collectionName,$mbaName, $return), '/' ))}</rest:forward>))
};



declare
  %rest:path("/changeCurrentStatusEventless/{$dbName}/{$collectionName}/{$mbaName}/{$return}")
  %rest:GET
  updating function page:changecurrentStatusEventless(
    $dbName as xs:string, $collectionName as xs:string , $mbaName as xs:string, $return)
{

(: again ExitStates, run..  EnterSTates:)

kk:changeCurrentStatusEventless($dbName, $collectionName, $mbaName),
     db:output(<rest:forward>{fn:concat('/checkforFinal/', string-join(($dbName,$collectionName,$mbaName, $return), '/' ))}</rest:forward>)

};



declare
  %rest:path("/checkforFinal/{$dbName}/{$collectionName}/{$mbaName}/{$return}")
  %rest:GET
  updating function page:finalCheck(
    $dbName as xs:string, $collectionName as xs:string , $mbaName as xs:string, $return)
{

(: again ExitStates, run..  EnterSTates:)


if(fn:count(kk:getExecutableContentsEventless($dbName, $collectionName, $mbaName) )> 0 ) then 
     db:output(<rest:forward>{fn:concat('/processEventlessTransitions/', string-join(($dbName,$collectionName,$mbaName, $return), '/' ))}</rest:forward>)
     
     else 
      db:output(
        <response>
        </response>)

};
  
  




declare
  %rest:path("/microstep1/{$dbName}/{$collectionName}/{$mbaName}/{$counter}/{$return}")
  %rest:GET
  updating function page:microstep1(
    $dbName as xs:string, $collectionName as xs:string , $mbaName as xs:string, $counter as xs:integer, $return as xs:string)
{

let $max := fn:count(kk:getExecutableContents($dbName, $collectionName, $mbaName))
let $counterneu := $counter + 1
return


if ($counter = 0) then 
(
kk:exitStates($dbName,$collectionName,$mbaName),
   db:output(<rest:forward>{fn:concat('/microstep1/', string-join(($dbName,$collectionName,$mbaName,$counterneu, $return), '/' ))}</rest:forward>)
)
else if ($counter <= $max) then
 (kk:getandExecuteExecutablecontent($dbName, $collectionName, $mbaName , $counter),
   db:output(<rest:forward>{fn:concat('/microstep1/', string-join(($dbName,$collectionName,$mbaName,$counterneu, $return), '/' ))}</rest:forward>))
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
