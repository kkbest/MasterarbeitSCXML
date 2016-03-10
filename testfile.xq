import module namespace kk = 'http://www.w3.org/2005/07/kk';
import module namespace scx='http://www.w3.org/2005/07/scxml/extension/';
import module namespace functx = 'http://www.functx.com';
import module namespace mba='http://www.dke.jku.at/MBA'; 
import module namespace sc = 'http://www.w3.org/2005/07/scxml';
import module namespace sync = 'http://www.dke.jku.at/MBA/Synchronization';


declare variable $dbName := 'myMBAse';
declare variable $collectionName := 'JohannesKeplerUniversity';
declare variable $mbaName1 := 'JohannesKeplerUniversity';
declare variable $mbaName := 'InformationSystems';
declare variable $transType := 'internal';

let $mba   := mba:getMBA($dbName, $collectionName, $mbaName)
let $mba1   := mba:getMBA($dbName, $collectionName, $mbaName1)
let $scxml := mba:getSCXML($mba)
let $scxml1 := mba:getSCXML($mba1)
let $configuration := mba:getConfiguration($mba)
let $dataModels := sc:selectDataModels($configuration)

return $mba
