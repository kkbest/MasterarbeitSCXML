import module namespace mba = 'http://www.dke.jku.at/MBA';
import module namespace sc  = 'http://www.w3.org/2005/07/scxml';

declare variable $dbName external;
declare variable $collectionName external;
declare variable $mbaName external;

let $mba := mba:getMBA($dbName, $collectionName, $mbaName)
return if(fn:empty($mba)) then
()
else
mba:removeFromInsertLog($mba)
