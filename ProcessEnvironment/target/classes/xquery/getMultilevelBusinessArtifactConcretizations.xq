import module namespace mba = 'http://www.dke.jku.at/MBA';
import module namespace sc  = 'http://www.w3.org/2005/07/scxml';

declare variable $mba external;

let $concretizations := $mba/mba:concretizations

for $concretization in $concretizations/mba:mba
  return fn:string($concretization/@name)
