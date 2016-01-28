import module namespace kk = 'http://www.w3.org/2005/07/kk';
import module namespace scx='http://www.w3.org/2005/07/scxml/extension/';
import module namespace functx = 'http://www.functx.com';
import module namespace mba='http://www.dke.jku.at/MBA'; 
import module namespace sc = 'http://www.w3.org/2005/07/scxml';
import module namespace sync = 'http://www.dke.jku.at/MBA/Synchronization';


declare function local:hasHistoryValue($state,$scxml) as xs:boolean
{  
 fn:true() 
};

declare function local:addDescendantStatesToEnter($scxml, $states                as element()*,
                                               $statesToEnter         as element()*,
                                               $statesForDefaultEntry as element()*,
                                               $cont) as item() {
                                                '1' 
                                               };
                                               
                                               
declare function local:test($scxml, $states, $statesToEnter, $statesForDefaultEntry,$cont)   
{                                            
  (: TODO: history states :)
  
 if (local:isHistoryState($states, $scxml)) then
 (
    let $results := 
  if (local:hasHistoryValue($states, $scxml)) then
    
    local:addDescendantStatesToEnter($scxml,$states,$statesToEnter,$statesForDefaultEntry, $cont)
  else
  
  '123'
   
   
(:
procedure addDescendantStatesToEnter(state,statesToEnter,statesForDefaultEntry, defaultHistoryContent):
    if isHistoryState(state):
        if historyValue[state.id]:
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
    else:
        statesToEnter.add(state)
        if isCompoundState(state):
            statesForDefaultEntry.add(state)
            for s in state.initial.transition.target:
                addDescendantStatesToEnter(s,statesToEnter,statesForDefaultEntry, defaultHistoryContent)
            for s in state.initial.transition.target:    
                addAncestorStatesToEnter(s, state, statesToEnter, statesForDefaultEntry, defaultHistoryContent)
        else:
            if isParallelState(state):
                for child in getChildStates(state):
                    if not statesToEnter.some(lambda s: isDescendant(s,child)):
                        addDescendantStatesToEnter(child,statesToEnter,statesForDefaultEntry, defaultHistoryContent) 
:) 

return '123')
 else
 (
  
  
  (:
  
    statesToEnter.add(state)
        if isCompoundState(state):
            statesForDefaultEntry.add(state)
            for s in state.initial.transition.target:
                addDescendantStatesToEnter(s,statesToEnter,statesForDefaultEntry, defaultHistoryContent)
            for s in state.initial.transition.target:    
                addAncestorStatesToEnter(s, state, statesToEnter, statesForDefaultEntry, defaultHistoryContent)
        else:
            if isParallelState(state):
                for child in getChildStates(state):
                    if not statesToEnter.some(lambda s: isDescendant(s,child)):
                        addDescendantStatesToEnter(child,statesToEnter,statesForDefaultEntry, defaultHistoryContent) 
                        :)
  
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


declare function local:isHistoryState($state,$scxml)
{
  if($state = null) then
   fn:true
   else
  
  fn:false
  
};

'asdf'