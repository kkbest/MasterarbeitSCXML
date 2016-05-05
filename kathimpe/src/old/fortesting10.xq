import module namespace mba = 'http://www.dke.jku.at/MBA';
import module namespace sc  = 'http://www.w3.org/2005/07/scxml';
import module namespace kk = 'http://www.w3.org/2005/07/kk';

for $db in db:list()[fn:matches(.,'invoke')]
return db:drop($db)