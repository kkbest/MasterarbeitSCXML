import module namespace mba = 'http://www.dke.jku.at/MBA';
import module namespace sc  = 'http://www.w3.org/2005/07/scxml';
import module namespace kk = 'http://www.w3.org/2005/07/kk';

declare variable $dbName external;
declare variable $collectionName external;
declare variable $mbaName external;


 let $mba := mba:getMBA($dbName, $collectionName, $mbaName)
  return $mba

