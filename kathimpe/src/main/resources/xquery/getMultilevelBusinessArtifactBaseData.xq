import module namespace mba = 'http://www.dke.jku.at/MBA';
import module namespace sc  = 'http://www.w3.org/2005/07/scxml';

declare variable $mba external;

let $scxml := mba:getSCXML($mba)

let $dbName := $scxml/sc:datamodel/sc:data[@id='_x']/db/text()
let $collectionName := $scxml/sc:datamodel/sc:data[@id='_x']/collection/text()
let $mbaName := fn:string($mba/@name)

return ($mbaName, $dbName, $collectionName)
