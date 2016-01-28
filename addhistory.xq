import module namespace kk = 'http://www.w3.org/2005/07/kk';
import module namespace scx='http://www.w3.org/2005/07/scxml/extension/';
import module namespace functx = 'http://www.functx.com';
import module namespace mba='http://www.dke.jku.at/MBA'; 
import module namespace sc = 'http://www.w3.org/2005/07/scxml';
import module namespace sync = 'http://www.dke.jku.at/MBA/Synchronization';


declare function local:hasHistoryValue($state) as xs:boolean
{  
 fn:true() 
};

declare function local:addDescendantStatesToEnter($states                as element()*,
                                               $statesToEnter         as element()*,
                                               $statesForDefaultEntry as element()*,
                                               $cont) as item() {
  (: TODO: history states :)
  
 if (local:isHistoryState($states)) then
 (
    let $results := 
  if (local:hasHistoryValue($states)) then
    
    local:addDescendantStatesToEnter(s,statesToEnter,statesForDefaultEntry, defaultHistoryContent)
  else
  
  
  return $results
   
   
(:        if historyValue[state.id]:
            for s in historyValue[state.id]:
                addDescendantStatesToEnter(s,statesToEnter,statesForDefaultEntry, defaultHistoryContent)
            for s in historyValue[state.id]:
                addAncestorStatesToEnter(s, state.parent, statesToEnter, statesForDefaultEntry, defaultHistoryContent)
        else:
            defaultHistoryContent[state.parent.id] = state.transition.content
            for s in state.transition.target:
                addDescendantStatesToEnter(s,statesToEnter,statesForDefaultEntry, defaultHistoryContent)
            for s in state.transition.target:     
                addAncestorStatesToEnter(s, state.parent, statesToEnter, statesForDefaultEntry, defaultHistoryContent)
:) 

)
 else
 (
  
  
  
  
  let $results :=
    if (fn:empty($states)) then $cont($statesToEnter, $statesForDefaultEntry)
    else if (sc:isAtomicState($states[1])) then
      sc:addDescendantStatesToEnter(
        $states[position() > 1], ($statesToEnter, $states[1]), $statesForDefaultEntry, $cont
      )
    else if (sc:isCompoundState($states[1])) then
       let $initialStates := sc:getInitialStates($states[1])
       return sc:addDescendantStatesToEnter(
         $initialStates[1], 
         ($statesToEnter, $states[1]), 
         ($statesForDefaultEntry, $states[1]),
         function($statesToEnter1, $statesForDefaultEntry1) {
           sc:addAncestorStatesToEnter(
             $initialStates[1],
             $states[1],
             $statesToEnter1,
             $statesForDefaultEntry1,
             function($statesToEnter2, $statesForDefaultEntry2) {
               sc:addDescendantStatesToEnter(
                 $initialStates[position() > 1], 
                 $statesToEnter2,
                 $statesForDefaultEntry2,
                 $cont
               )
             }
           )
         }
       )
    else if (sc:isParallelState($states[1])) then
       let $childStates := sc:getChildStates($states[1])
       let $childStatesNotAdded := 
         $childStates[not (some $s in $statesToEnter satisfies sc:isDescendant($s, .))]
         
       return sc:addDescendantStatesToEnter(
         $childStatesNotAdded[1], 
         ($statesToEnter, $states[1]), 
         $statesForDefaultEntry,
         function($statesToEnter1, $statesForDefaultEntry1) {
           sc:addDescendantStatesToEnter(
             $childStatesNotAdded[position() > 1], 
             $statesToEnter1,
             $statesForDefaultEntry1,
             function($statesToEnter2, $statesForDefaultEntry2) {
               sc:addDescendantStatesToEnter($states[position() > 1],
                                             $statesToEnter2,
                                             $statesForDefaultEntry2,
                                             $cont)
             }
           )
         }
       )
    else ()
  
  return $results
)
};


declare function local:isHistoryState($state)
{
  if($state = null) then
   fn:true
   else
  
  fn:false
  
};

'asdf'