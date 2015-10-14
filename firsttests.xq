declare default element namespace 'http://www.w3.org/2005/07/scxml';
declare namespace functx = "http://www.functx.com";


declare variable $statesToInvoke as node() := <states></states>;
declare variable $datamodel as node() := <datamodel></datamodel>;
declare variable $internalQueue as node() := <internalQueue></internalQueue>;
declare variable $externalQueue as node() := <externalQueue></externalQueue>;
declare variable $historyValue as node() := <historyValue></historyValue>;
declare variable $running as xs:boolean := false;
declare variable $binding as node() := <config></config>;

 
declare function local:findinitalTransition($input as node()) as item()*
{ 
  let $result :=
  if(fn:exists($input/initial)) then
     <transition target ="{string($input/initial/@id)}"></transition>
   else if(fn:exists($input/@initial)) then
   <transition target="{string($input/@initial)}"> </transition>
  else
      <transition target ="{string($input/state[1]/@id)}"></transition>
    return  $result
       
  };

(: Initialize interpreter:)
declare function local:interpret($scxml as node())
{
  let $running := true,
  $initalTransition := local:findinitalTransition($scxml),
  $configuration := local:enterStates($initalTransition,$scxml, ())
  return trace(local:mainEventLoop($configuration,$scxml), 'end of interpret')
};

declare function local:mainEventLoop($configuration as node(), $scxml as node())
{
  let $enabledTransition := local:selectEventlessTransitions($configuration)
  return $enabledTransition
  
  
  (:
  $configuration
  
  
  procedure mainEventLoop():
    while running:
        enabledTransitions = null
        macrostepDone = false
        # Here we handle eventless transitions and transitions 
        # triggered by internal events until macrostep is complete
        while running and not macrostepDone:
            enabledTransitions = selectEventlessTransitions()
            if enabledTransitions.isEmpty():
                if internalQueue.isEmpty(): 
                    macrostepDone = true
                else:
                    internalEvent = internalQueue.dequeue()
                    datamodel["_event"] = internalEvent
                    enabledTransitions = selectTransitions(internalEvent)
            if not enabledTransitions.isEmpty():
                microstep(enabledTransitions.toList())
        # either we're in a final state, and we break out of the loop 
        if not running:
            break
        # or we've completed a macrostep, so we start a new macrostep by waiting for an external event
        # Here we invoke whatever needs to be invoked. The implementation of 'invoke' is platform-specific
        for state in statesToInvoke.sort(entryOrder):
            for inv in state.invoke.sort(documentOrder):
                invoke(inv)
        statesToInvoke.clear()
        # Invoking may have raised internal error events and we iterate to handle them        
        if not internalQueue.isEmpty():
            continue
        # A blocking wait for an external event.  Alternatively, if we have been invoked
        # our parent session also might cancel us.  The mechanism for this is platform specific,
        # but here we assume it’s a special event we receive
        externalEvent = externalQueue.dequeue()
        if isCancelEvent(externalEvent):
            running = false
            continue
        datamodel["_event"] = externalEvent
        for state in configuration:
            for inv in state.invoke:
                if inv.invokeid == externalEvent.invokeid:
                    applyFinalize(inv, externalEvent)
                if inv.autoforward:
                    send(inv.id, externalEvent) 
        enabledTransitions = selectTransitions(externalEvent)
        if not enabledTransitions.isEmpty():
            microstep(enabledTransitions.toList()) 
    # End of outer while running loop.  If we get here, we have reached a top-level final state or have been cancelled          
    exitInterpreter()            
  :)
};

declare function local:selectEventlessTransitions($configuration as node())
{
 
(: let $enabledTrans := $input :)
 (: return local:removeConflictingTransitions($enabledTrans) :)
 $configuration
};


declare function local:isAtomicState($state as node())
{
  fn:not(fn:exists($state/parallel) or fn:exists($state/state))
};


declare function local:enterStates($enabledTransitions as node()*,$scxml as node(), $configuration)
{
  let $states := local:computeEntrySet($enabledTransitions,$scxml)
  let $configuration := $states
  let $result :=   for $s in $states
    let $configuration :=$s,
    $statesToInvoke :=$s
    return local:executeContent($s/onentry/*)
   return $configuration 
  (: add to States to Invoke:)
  (: add to config:)
  (: executeContent of ONeEntry
   local:executeContent():)
 (:Check if is finalState:)

  
};

declare function local:executeContent($nodesToExecute as node()*)
{
  for $n in $nodesToExecute
  return
  switch ($n)
  case $n/self::assign return <assign></assign>
  case $n/self::log return <log></log>
  default return <ss> </ss>  
  
 
};

declare function local:computeEntrySet($transitions as node()*, $scxml as node())
{
(:  let $as := local:getTargetStates($transitions)
  let $max := $as/@target 
  return $as :)
  
  if (fn:empty($transitions)) then ()
  else
   let $states := local:getTargetStates($transitions, $scxml)
   for $s in $states 
   let $stateToEnter := local:addDescendantStatesToEnter($s, <test></test>, <test></test>, <test></test>, $scxml)
   return $stateToEnter
  
  
  (: 
      }
        :)
      
};

declare function local:addDescendantStatesToEnter($state as node(), $statesToEnter as node(), $statesForDefaultEntry as node(), $defaultHistoryContent as node(), $scxml as node()) as node()
{
  
  (:history nodes are missing:)
  
  (:insert node $state into $statesToEnter,:) 
  if (local:isCompoundState($state)) then
  return
  else 
   if(local:isParallelState($state)) then
   $state
   else
   $state
  

};

(: returns if the currentstate is a parallel state:)
declare function local:isParallelState($state as node()) as xs:boolean
{
  fn:exists(fn:exists($state/self::parallel))
};




declare function local:getTargetStates($transitions as node()* , $scxml as node())
{
  if(fn:exists($transitions/@target)) then
  $scxml/state[@id=$transitions/@target]
   else
     return

    
  
};

declare function local:isCompoundState($state as node()) as xs:boolean
{
  if(fn:exists($state/state)) then
   fn:true()
   else if (fn:exists( $state/prarallel)) then
   fn:true()
   else
   fn:false()
};



declare function local:removeConflictingTransitions($input as node())
{
  
  return
};


declare function local:computeEntrySet($transitions as node()*, $statesToEnter as node(), $statesForDefaultEntry as node(), $defaultHistoryContent as node())
{
  
  return
};




declare function local:addAncestorStatesToEnter($states as node(), $statesToEnter as node(), $statesForDefaultEntry as node(), $defaultHistoryContent as node())
{
  return
};


declare function local:isInFinalState($state as node())
{
  return
};

declare function local:selectTransitions($event as node(), $input as node())
{
  return
};




declare function local:getTransitionDomain($transition)
{
  return
};


declare function local:getEffectiveTargetStates($transition)
{
  return
};

declare function local:getProperAncestors($state1, $state2)
{
  return
};

declare function local:isDescendant($state1 as node(),
                                 $state2 as node()) as xs:boolean {
  some $n in $state2//descendant::* satisfies $n is $state1
};

declare function local:getChildStates($state1)
{
  return
};



declare function local:findLCCA($stateList)
{
	return
};

declare function local:exitStates($enabledTransitions)
{
	return
};


declare function local:exitStaes($enabledTransitions as node())
{
  return
};

declare function local:computeExitSet($enabledTransitions as node())
{
  return
};

declare function local:executeTransitionContent($enabledTransitions as node())
{
  return
};

declare function local:exitInterpreter()
{
  return
};

declare function local:interpret($scxml, $id)
{
	return
};

declare function local:microstep($enabledTransitions as node())
{
 let $v := local:exitStates($enabledTransitions),
  $x :=local:executeTransitionContent($enabledTransitions),
  $z := local:enterStates($enabledTransitions,$enabledTransitions, null)
 return $z
};




let $scxml := doc('file:///C:\Program Files (x86)\BaseX\masterarbeit\example.scxml')/scxml
let $test := <test> <a> <b> as</b> <b> bs </b></a><a> <b> cs</b></a></test>
let $result := local:interpret($scxml)

return fn:trace($result,'foo')

(:
fn:exists($state/self::sc:parallel)

$knoten := $input/*/datamodel
for $state in $knoten
return $input :)
(:
 $input/@datamodel
let $result := $knoten/state[@id = "on"]
 (: sc:findinit($input) :)
(:return sc:max("test"):)


(:






:)
:)






