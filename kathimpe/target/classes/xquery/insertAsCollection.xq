import module namespace mba = 'http://www.dke.jku.at/MBA';

declare variable $dbName external;
declare variable $mba external;

mba:insertAsCollection($dbName, $mba)