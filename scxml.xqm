(:~

 : --------------------------------
 : SCXML-XQ: An SCXML interpreter in XQuery
 : --------------------------------
  
 : Copyright (C) 2014, 2015 Christoph Schütz
   
 : This program is free software; you can redistribute it and/or modify
 : it under the terms of the GNU General Public License as published by
 : the Free Software Foundation; either version 2 of the License, or
 : (at your option) any later version.
 
 : This program is distributed in the hope that it will be useful,
 : but WITHOUT ANY WARRANTY; without even the implied warranty of
 : MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 : GNU General Public License for more details.
 
 : You should have received a copy of the GNU General Public License along
 : with this program; if not, write to the Free Software Foundation, Inc.,
 : 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 
 : This module provides the functionality for working with SCXML documents,
 : consisting of functions for the interpretation and manipulation 
 : of SCXML documents.
 
 : The SCXML interpreter depends on the external FunctX library, which is
 : distributed by the original developers under GNU LGPL. The FunctX library
 : is included in the repository.
 
 : @author Christoph Schütz
 :)
module namespace sc = 'http://www.w3.org/2005/07/scxml';
import module namespace scx='http://www.w3.org/2005/07/scxml/extension/';
import module namespace functx = 'http://www.functx.com';

(:~
 : 
 :)
declare function sc:matchesEventDescriptors($eventName        as xs:string,
                                            $eventDescriptors as xs:string*)
    as xs:boolean {
  some $descriptor in $eventDescriptors satisfies
  
   ( fn:matches($descriptor || '|' || $eventName ,'^((([a-zA-Z]+)\.\*\|\3\.[a-zA-Z]+)|(\*\|[a-zA-Z]+)|((([a-zA-Z]|\.)+)\|(\6))|(([a-zA-Z]+)\|\10\.[a-zA-Z]+))$')
     or $eventDescriptors = "*" or     fn:matches($eventName, '^' || $descriptor || '$')
 )
};


declare function sc:evaluateCond($cond, $dataModels) as xs:boolean
{
  
  

  let $dataBindings :=
    for $dataModel in $dataModels
      for $data in $dataModel/sc:data
        return map:entry($data/@id, $data)
  
  let $declare :=
    for $dataModel in $dataModels
      for $data in $dataModel/sc:data
        return 
          ' declare variable $' || $data/@id || ' external ;'
          
    let $evaluation := try
         {
            xquery:eval(scx:importModules() ||
                        fn:string-join($declare) || 
                        scx:builtInFunctionDeclarations() ||
                       'return ' || $cond, 
                       map:merge($dataBindings))
         } 
         catch *
         {
           fn:false()
         }
         
         return $evaluation
         
};

(:~
 : Selects the data models that are valid in the current configuration.
 : 
 : Note: The configuration must consist of the original nodes (not copies) from
 :       the SCXML document.
 : Note: All states in the configuration are assumed to have been taken from the
 :       same SCXML document.
 : 
 : @param $configuration the list of active nodes
 : 
 : @return a list of data models; original nodes, not copies.
 :)
declare function sc:selectDataModels($configuration as element()*) 
    as element()* {
  let $global := 
    $configuration[1]/ancestor::sc:scxml/sc:datamodel
  
  let $local := for $s in $configuration return $s/sc:datamodel
  
  return ($global, $local)
};


declare function sc:selectAllDataModels($mba as element()*) 
    as element()* {
  
 $mba/*/*/sc:scxml//sc:datamodel

};



(:~
 : 
 :)
declare updating function sc:assign($dataModels as element()*,
                                    $location   as xs:string,
                                    $expression as xs:string?,
                                    $type       as xs:string?,
                                    $attribute  as xs:string?,
                                    $nodelist   as node()*, 
                                  $dbName  as xs:string,
                                   $collectionName as xs:string,
                                    $mbaName as xs:string
                                ) {  
           
  
   
  try
  {        
      let $test := fn:trace("try")

  let $dataBindings :=
    for $dataModel in $dataModels
      for $data in $dataModel/sc:data
        return map:entry($data/@id, $data)
  
  let $declare :=
    for $dataModel in $dataModels
      for $data in $dataModel/sc:data[not (@id = '_sessionid' or @id = '_name' or  @id = '_sessionid' or @id = '_ioprocessors')]
        return 'declare variable $' || $data/@id || ' external; '
  
  let $declareNodeList :=
    'declare variable $nodelist external; '
  
  let $expression :=
    if (not($expression) or $expression = '') 
    then '() '
    else $expression
  
  return

  
           
           
    xquery:update(
      scx:importModules() ||
      fn:string-join($declare) ||
      $declareNodeList ||
      scx:builtInFunctionDeclarations() ||
      'let $locations := ' || $location || ' ' || (
      if ($expression) then
        'let $newValues := ' || $expression || ' '
      else 
        'let $newValues := $nodelist ' 
      ) ||
      'return ' || (
        if ($type = 'firstchild') then (
          'for $l in $locations ' ||
            'return insert node $newValues as first into $l '
        ) else if ($type = 'lastchild') then (
          'for $l in $locations ' ||
            'return insert node $newValues as last into $l '
        ) else if ($type = 'previoussibling') then (
          'for $l in $locations ' ||
            'return insert node $newValues before $l '
        ) else if ($type = 'nextsibling') then (
          'for $l in $locations ' ||
            'return insert node $newValues after $l '
        ) else if ($type = 'replace') then (
          'for $l in $locations ' ||
            'return replace node $l with $newValues '
        ) else if ($type = 'delete') then (
          'for $l in $locations ' ||
            'return delete node $l '
        ) else if ($type = 'addattribute') then (
          'for $l in $locations ' ||
            'return insert node attribute ' || $attribute || ' {$newValues} into $l '
        ) else ( 
          'for $l in $locations ' ||
            'let $empty   := copy $c := $l modify(delete nodes $c/*) return $c ' ||
            'let $emptier := copy $c := $empty modify(replace value of node $c with "") return $c ' ||
            'let $newNode := copy $c := $emptier modify(insert nodes $newValues into $c) return $c ' ||
            'return replace node $l with $newNode '
        )
      ), map:merge(($dataBindings, map:entry('nodelist', $nodelist)))
    )
  }
  catch *
  
  {
    
         let $test := fn:trace("catchassign")

    let $test := fn:trace($err:code,$err:description)
    let $mbtest   := 'mba:getMBA( "' || $dbName || '" ,"' || $collectionName || '","' || $mbaName || '") '
   return 
    xquery:update(
      scx:importModules() ||
      ' let $event := <event name="error.execution"  type="platform" xmlns=""></event> '  ||
      'let $mba := '|| $mbtest || '
      return mba:enqueueInternalEvent($mba,$event)')
      
  }
  
};




declare updating function sc:getValue($dataModels as element()*,
                                    $location   as xs:string,
                                    $expression as xs:string?,
                                    $type       as xs:string?,
                                    $attribute  as xs:string?,
                                    $nodelist   as node()*,
                                    $id ) {  
  let $dataBindings :=
    for $dataModel in $dataModels
      for $data in $dataModel/sc:data
        return map:entry($data/@id, $data)
  
  let $declare :=
    for $dataModel in $dataModels
      for $data in $dataModel/sc:data
        return 'declare variable $' || $data/@id || ' external; '
  
  let $declareNodeList :=
    'declare variable $nodelist external; '
  
  let $expression :=
    if (not($location) or $location = '') 
    then '() '
    else $location
   
  
  let $location := '$_x/' ||'response'
  return
    xquery:update(
      scx:importModules() ||
      fn:string-join($declare) ||
      $declareNodeList ||
      scx:builtInFunctionDeclarations() ||
      'let $locations := ' || $location || ' ' || (
      if ($expression) then
        'let $newValues := ' || $expression || ' '
      else 
        'let $newValues := $nodelist ' 
      ) ||
            'let $id := ' || $id || ' ' ||
            
            'let $exists := fn:exists($mba/mba:topLevel/mba:elements/sc:scxml/sc:datamodel/sc:data[@id="_x"]/response/response[@ref=$id]) ' ||

      'let $newNode := if ($exists) then 
              (  $newValues)
                else
      (  <response ref = "{  $id }">{  $newValues} </response>)'
      
            ||
      
      
      'return ' || (
        
         
         
       ' if ($exists) then 
 ( for $l in $locations ' ||
 
 (:return insert node $newNode into $l/response/response[@ref=$id]:) '
 return insert node $newNode into $l/response[@ref=$id]
  )
 else
(  for $l in $locations
 return insert node $newNode into $l) '
        ), map:merge(($dataBindings, map:entry('nodelist', $nodelist)))
      
    ) 
    
    
       
};




declare updating function sc:log($dataModels as element()*,
                                    $expression as xs:string?,
                                    $label as xs:string?,
                                    $nodelist   as node()*,
                                    $id,
                                     $dbName, $collectionName, $mbaName ) {  
  
  
   try
  { 
  
  let $dataBindings :=
    for $dataModel in $dataModels
      for $data in $dataModel/sc:data
        return map:entry($data/@id, $data)
  
  let $declare :=
    for $dataModel in $dataModels
      for $data in $dataModel/sc:data
        return 'declare variable $' || $data/@id || ' external; '
  
  let $declareNodeList :=
    'declare variable $nodelist external; '
  
  let $expression :=
    if (not($expression) or $expression = '') 
    then '() '
    else sc:eval($expression,$dataModels)
   
  
  let $location := '$_x/' ||'response'
  return
    xquery:update(
      scx:importModules() ||
      fn:string-join($declare) ||
      $declareNodeList ||
      scx:builtInFunctionDeclarations() ||
      'let $locations := ' || $location || ' ' || (
      if ($expression) then
        'let $newValues :=  <log>' ||$label || $expression || ' </log> '
      else 
        'let $newValues := $nodelist ' 
      ) ||
            'let $id := ' || $id || ' ' ||
            
            'let $exists := fn:exists($mba/mba:topLevel/mba:elements/sc:scxml/sc:datamodel/sc:data[@id="_x"]/response/response[@ref=$id]) ' ||

      'let $newNode := if ($exists) then 
              (  $newValues)
                else
      (  <response ref = "{  $id }">{  $newValues} </response>)'
      
            ||
      
      
      'return ' || (
        
         
         
       ' if ($exists) then 
 ( for $l in $locations ' ||
 
 (:return insert node $newNode into $l/response/response[@ref=$id]:) '
 return insert node $newNode into $l/response[@ref=$id]
  )
 else
(  for $l in $locations
 return insert node $newNode into $l) '
        ), map:merge(($dataBindings, map:entry('nodelist', $nodelist)))
      
    )
   }
   catch *
  
  {
    
     
    let $test := fn:trace($err:code,$err:description)
    let $mbtest   := 'mba:getMBA( "' || $dbName || '" ,"' || $collectionName || '","' || $mbaName || '") '
   return 
    xquery:update(
      scx:importModules() ||
      ' let $event := <event name="error.execution" type="platform" xmlns=""></event> '  ||
      'let $mba := '|| $mbtest || '
      return mba:enqueueInternalEvent($mba,$event)')
      
  }
};



declare function sc:selectEventlessTransitions($configuration as element()*,
                                               $dataModels    as element()*) 
    as element()* {
      
  let $atomicStates :=
    $configuration[sc:isAtomicState(.)]
    
       
  let $enabledTransitions :=
    for $state in $atomicStates 
      let $transitions :=  
        for $s in ($state, sc:getProperAncestors($state))
   
     let $transitions :=
        
        
         for $t in $s/sc:transition
         
         
         let $evaluation := 
         
         sc:evaluateCond($t/@cond, $dataModels)
       
         return
         
         if(((not($t/@event) or $t/@event = '')  and (not($t/@cond) or $t/@cond = '' or
                                 $evaluation )) )then 
                           $t
                       
                           
                           else
                           ()
                            
      return $transitions[1]
      
        return $transitions
  
  return sc:removeConflictingTransitions($configuration, ($enabledTransitions))
};

declare function sc:selectTransitions($configuration as element()*,
                                      $dataModels as element()*,
                                      $event
                                    ) as element()* {
  
 if (fn:empty($event)) then 
  ()
 else
  let $atomicStates :=
    $configuration[sc:isAtomicState(.)]
  
  let $dataBindings :=
    for $dataModel in $dataModels
      for $data in $dataModel/sc:data
        return map:entry($data/@id, $data)
  
  let $declare :=
    for $dataModel in $dataModels
      for $data in $dataModel/sc:data
        return 
          'declare variable $' || $data/@id || ' external; '
        
  let $enabledTransitions :=
    for $state in $atomicStates 
      for $s in ($state, sc:getProperAncestors($state))
       let $transitions :=
        
        
         for $t in $s/sc:transition
         let $evaluation := try
         {
            xquery:eval(scx:importModules() ||
                        fn:string-join($declare) || 
                        scx:builtInFunctionDeclarations() ||
                       'return ' || $t/@cond, 
                       map:merge($dataBindings))
         } 
         catch *
         {
           fn:false()
         }
         return
         
         if((sc:matchesEventDescriptors(
                             $event,
                             fn:tokenize($t/@event, '\s')
                           ) and (not($t/@cond) or
                                 $evaluation )) )then 
                           $t
                       
                           
                           else
                           ()
                            
      return $transitions[1]
  
  return sc:removeConflictingTransitions($configuration, ($enabledTransitions))
};

declare function sc:removeConflictingTransitions($configuration as element()*,
                                                 $transitions as element()*)
    as element()*{
  let $enabledTransitions := functx:distinct-nodes($transitions)
  
  let $filteredTransitions := fn:fold-left(?, (),
    function($filteredTransitions, $t1) {
      let $exitSetT1 := sc:computeExitSet($configuration, ($t1))
      let $t2 := ($filteredTransitions[
        some $s in $exitSetT1 satisfies 
        functx:index-of-node(sc:computeExitSet($configuration, .), $s)
      ])[1]
      let $filteredTransitions :=
        if ($t2) then (
          if (sc:isDescendant(sc:getSourceState($t1), 
                              sc:getSourceState($t2))) then (
            (fn:remove($filteredTransitions, 
                       functx:index-of-node($filteredTransitions, $t2)), $t1)
          ) 
          else $filteredTransitions
        )        
        else ($filteredTransitions, $t1)
      
      return $filteredTransitions
    }
  )
  
  return $filteredTransitions($enabledTransitions)
};

declare function sc:computeExitSet($configuration as element()*,
                                   $transitions as element()*) as element()*{
  let $statesToExit := 
    for $t in $transitions 
      let $domain := sc:getTransitionDomain($t)
      for $s in $configuration
        return if (sc:isDescendant($s, $domain)) then $s else ()
  
  return $statesToExit
};

declare function sc:computeExitSet2($configuration as element()*,
                                   $transitions as element()*) {
  let $statesToExit := 
    for $t in $transitions 
      let $domain := sc:getTransitionDomainExit($t)
      return if (not (fn:empty($domain))) then 
      for $s in $configuration
        return if (sc:isDescendant($s, $domain)) then $s else ()
       
       else
       ()
  return $statesToExit
};


declare function sc:computeExitSetTrans($configuration as element()*,
                                   $transitions as element()*) as element()*{
  let $statesToExit := 
    for $t in $transitions 
      let $domain := sc:getTransitionDomainTrans($t)
      for $s in $configuration
        return if (sc:isDescendant($s, $domain)) then $s else ()
  
  return $statesToExit
};

declare function sc:computeExitSetTrans2($configuration as element()*,
                                   $transitions as element()*){
  let $statesToExit := 
    for $t in $transitions 
      let $domain := sc:getTransitionDomainTransExit($t)
       return if (not (fn:empty($domain))) then 
      for $s in $configuration
        return if (sc:isDescendant($s, $domain)) then $s else ()
  else
  ()
  return $statesToExit
};



declare function sc:computeEntry($transitions as element()*) {
  if (fn:empty($transitions)) then ()
  else
    let $statesToEnterStart := 
      for $t in $transitions
        return sc:getTargetStates($t)
    
    let $stateLists :=
      map:merge((
        map:entry('statesToEnter', ()),
        map:entry('statesForDefaultEntry', ()),
         map:entry('historyContent',())  
      ))
      
    let $addDescendants := fn:fold-left(?, $stateLists,
      function($stateListsResult, $s) {
        let $statesToEnter := 
          map:get($stateListsResult, 'statesToEnter')
        let $statesForDefaultEntry := 
          map:get($stateListsResult, 'statesForDefaultEntry')
           let $historyContent := 
          map:get($stateListsResult, 'historyContent')  
          
        let $f := function($statesToEnter, $statesForDefaultEntry,$historyContent) { 
          map:merge((
            map:entry('statesToEnter', $statesToEnter),
            map:entry('statesForDefaultEntry', $statesForDefaultEntry),
         map:entry('historyContent',$historyContent)  
          ))
        }
        
        return
          sc:addDescendantStatesToEnter($s, $statesToEnter, $statesForDefaultEntry, $f, $historyContent)
      }
    )
    
    let $stateLists := $addDescendants($statesToEnterStart)
   
    let $stateLists := 
      (
       for $t in $transitions
         let $ancestor := sc:getTransitionDomainTrans($t)
         let $addAncestors := fn:fold-left(?, $stateLists,
           function($stateListsResult, $s) {
             let $statesToEnter := 
               map:get($stateListsResult, 'statesToEnter')
             let $statesForDefaultEntry := 
               map:get($stateListsResult, 'statesForDefaultEntry')
                let $historyContent := 
          map:get($stateListsResult, 'historyContent')  
              
             let $f := function($statesToEnter, $statesForDefaultEntry,$historyContent) { 
               map:merge((
                 map:entry('statesToEnter', $statesToEnter),
                 map:entry('statesForDefaultEntry', $statesForDefaultEntry),
                 map:entry('historyContent', $historyContent)
               ))
             }
             
             return
               sc:addAncestorStatesToEnter($s, $ancestor, $statesToEnter, $statesForDefaultEntry, $f, $historyContent)
           }
         )
         
         for $s in sc:getTargetStates($t)
           return $addAncestors($s)
      )
    
    let $statesToEnter := 
      if (not (fn:empty($stateLists))) then $stateLists
      else ()
    
    return $statesToEnter
};



declare function sc:computeEntryInit($scxml) {

  let $statesToEnterStart :=   if(fn:empty(sc:getInitialStates($scxml))) then 
   
    $scxml//sc:state[1]
    else
    sc:getInitialStates($scxml)
    
    
    let $stateLists :=
      map:merge((
        map:entry('statesToEnter', ()),
        map:entry('statesForDefaultEntry', ()),
         map:entry('historyContent',())  
      ))
      
    let $addDescendants := fn:fold-left(?, $stateLists,
      function($stateListsResult, $s) {
        let $statesToEnter := 
          map:get($stateListsResult, 'statesToEnter')
        let $statesForDefaultEntry := 
          map:get($stateListsResult, 'statesForDefaultEntry')
         let $historyContent := 
          map:get($stateListsResult, 'historyContent')  
        let $f := function($statesToEnter, $statesForDefaultEntry, $historyContent) { 
          map:merge((
            map:entry('statesToEnter', $statesToEnter),
            map:entry('statesForDefaultEntry', $statesForDefaultEntry),
            map:entry('historyContent', $historyContent)
          ))
        }
        
        return
          sc:addDescendantStatesToEnter($s, $statesToEnter, $statesForDefaultEntry, $f,())
      }
    )
    
    let $stateLists := $addDescendants($statesToEnterStart)
   
    let $stateLists := 
      (
       for $s in $statesToEnterStart
         let $ancestor := $scxml
         let $addAncestors := fn:fold-left(?, $stateLists,
           function($stateListsResult, $s) {
             let $statesToEnter := 
               map:get($stateListsResult, 'statesToEnter')
             let $statesForDefaultEntry := 
               map:get($stateListsResult, 'statesForDefaultEntry')
               let $historyContent := 
          map:get($stateListsResult, 'historyContent')  
             let $f := function($statesToEnter, $statesForDefaultEntry, $historyContent) { 
               map:merge((
                 map:entry('statesToEnter', $statesToEnter),
                 map:entry('statesForDefaultEntry', $statesForDefaultEntry),
                 map:entry('historyContent', $historyContent)
               ))
             }
             
             return
               sc:addAncestorStatesToEnter($s, $ancestor, $statesToEnter, $statesForDefaultEntry, $f,$historyContent)
           }
         )
         
           return $addAncestors($s)
      )
    
    let $statesToEnter := 
      if (not (fn:empty($stateLists))) then $stateLists
      else ()
    
    return $statesToEnter
};


declare function sc:addDescendantStatesToEnter($state as element()) as item() {
  (: TODO: history states :)
  
  let $f := function($statesToEnter, $statesForDefaultEntry, $historyContent) { 
    map:merge((
      map:entry('statesToEnter', $statesToEnter),
      map:entry('statesForDefaultEntry', $statesForDefaultEntry),
       map:entry('historyContent', $historyContent)
    ))
  }
  
  return sc:addDescendantStatesToEnter($state, (), (), $f,())
};





declare function sc:addDescendantStatesToEnter($states                as element()*,
                                               $statesToEnter         as element()*,
                                               $statesForDefaultEntry as element()*,
                                               
                                               $cont,
                                             $historyContent) as item() {
  (: I need SCXML:)
  
  
  (: TODO: history states 
  
  1. Check if history State
  2. Check if state already got someStuff 
  3. addDescendantState to Enter
  4. add AncestorSTatetoEnter
  :)
  
  let $test := fn:trace($states[1],"stateToCheck")
  let $results :=
    if (fn:empty($states)) then
   $cont($statesToEnter, $statesForDefaultEntry, $historyContent)
   else if (sc:isHistoryState($states[1])) then
    (
 
      (:TODO anschauen:)
      
      let $test := fn:trace($states[1],"responseisHistoryState")
      let $history := sc:getHistoryStates($states[1])
      return if (fn:empty($history))
      then
      let $test := fn:trace($states[1],"responseno history exists")
      (:default history
      HistoryContent will be done in ExcecuteContent:)
      
      let $historyContent := ($historyContent,$states[1]/sc:transition/*)
       let $defaultTransitionsStates := 
       for $t in $states[1]/sc:transition
     return sc:getEffectiveTargetStates($t) (: TODO check if effective or normal:)
      
      
      
       return sc:addDescendantStatesToEnter(
         $defaultTransitionsStates[1], 
         ($statesToEnter), 
         ($statesForDefaultEntry, $states[1]),
         
         function($statesToEnter1, $statesForDefaultEntry1, $historyContent1) {
           sc:addAncestorStatesToEnter(
             $defaultTransitionsStates[1],
             $states[1],
             $statesToEnter1,
             $statesForDefaultEntry1,
           
             function($statesToEnter2, $statesForDefaultEntry2, $historyContent2) {
               sc:addDescendantStatesToEnter(
                 $defaultTransitionsStates[position() > 1], 
                 $statesToEnter2,
                 $statesForDefaultEntry2,
                 
                 $cont,$historyContent2
               )
             },  $historyContent1
           )
         },$historyContent
       )
       
       
      
      else
      
      let $test := fn:trace($states[1],"responsethereisaHistory")
      let $test := fn:trace($history,"responsehistoryValue")
      return
      
       
     
      sc:addDescendantStatesToEnter(
         $history[1], 
         ($statesToEnter), 
         ($statesForDefaultEntry, $states[1]),
          
         function($statesToEnter1, $statesForDefaultEntry1,$historyContent1) {
           sc:addAncestorStatesToEnter(
             $history[1],
             $states[1]/parent::*,
             $statesToEnter1,
             $statesForDefaultEntry1,
             function($statesToEnter2, $statesForDefaultEntry2,$historyContent2) {
               sc:addDescendantStatesToEnter(
                 $history[position() > 1], 
                 $statesToEnter2,
                 $statesForDefaultEntry2,
                 
                 $cont,$historyContent2
               )
             },$historyContent1
           )
         },$historyContent
       ) 
 )
    else if (sc:isAtomicState($states[1])) then
           sc:addDescendantStatesToEnter(
        $states[position() > 1], ($statesToEnter, $states[1]), $statesForDefaultEntry, $cont,$historyContent
      )
    else if (sc:isCompoundState($states[1])) then
        let $test := fn:trace($states[1],"compound")
       let $initialStates := sc:getInitialStates($states[1])
       return sc:addDescendantStatesToEnter(
         $initialStates[1], 
         ($statesToEnter, $states[1]), 
         ($statesForDefaultEntry, $states[1]),
       
         function($statesToEnter1, $statesForDefaultEntry1,$historyContent1) {
           sc:addAncestorStatesToEnter(
             $initialStates[1],
             $states[1],
             $statesToEnter1,
             $statesForDefaultEntry1,
             function($statesToEnter2, $statesForDefaultEntry2,$historyContent2) {
               sc:addDescendantStatesToEnter(
                 $initialStates[position() > 1], 
                 $statesToEnter2,
                 $statesForDefaultEntry2,
                  
                 $cont, $historyContent2
               )
             },$historyContent1
           )
         }, $historyContent
       )
    else if (sc:isParallelState($states[1])) then
     
       let $childStates := sc:getChildStates($states[1])
       let $childStatesNotAdded := 
         $childStates[not (some $s in $statesToEnter satisfies sc:isDescendant($s, .))]
         
       return sc:addDescendantStatesToEnter(
         $childStatesNotAdded[1], 
         ($statesToEnter, $states[1]), 
         $statesForDefaultEntry,
         
         function($statesToEnter1, $statesForDefaultEntry1,$historyContent1) {
           sc:addDescendantStatesToEnter(
             $childStatesNotAdded[position() > 1], 
             $statesToEnter1,
             $statesForDefaultEntry1,
             
             function($statesToEnter2, $statesForDefaultEntry2,$historyContent2) {
               sc:addDescendantStatesToEnter($states[position() > 1],
                                             $statesToEnter2,
                                             $statesForDefaultEntry2,
                                              
                                             $cont, $historyContent)
             }    , $historyContent       )
         }, $historyContent
       )
    else ()
  
  return $results
};
 
declare function sc:addAncestorStatesToEnter($state as element(),
                                             $ancestor as element()) as item() {
  let $f := function($statesToEnter, $statesForDefaultEntry,$historyContent) { 
    map:merge((
      map:entry('statesToEnter', $statesToEnter),
      map:entry('statesForDefaultEntry', $statesForDefaultEntry),
        map:entry('historyContent', $historyContent)
    ))
  }
  
  return sc:addAncestorStatesToEnter($state, $ancestor, (), (), $f,())
};

declare function sc:addAncestorStatesToEnter($states as element()*,
                                             $ancestor as element(),
                                             $statesToEnter as element()*,
                                             $statesForDefaultEntry as element()*,
                                             $cont, $historyContent) as item() {
  let $properAncestors :=
    for $s in $states return sc:getProperAncestors($s, $ancestor)
  
  let $results :=
    if (fn:empty($properAncestors)) then $cont($statesToEnter, $statesForDefaultEntry,$historyContent)
    else sc:foldAncestorStatesToEnter ($properAncestors,
                                       $statesToEnter,
                                       $statesForDefaultEntry,
                                       $cont,$historyContent)
  
  return $results
};

declare function sc:foldAncestorStatesToEnter($states as element()*,
                                              $statesToEnter as element()*,
                                              $statesForDefaultEntry as element()*,
                                              $cont, $historyContent) as item() {
  let $results := 
    if (fn:empty($states)) then  $cont($statesToEnter, $statesForDefaultEntry,$historyContent)
    else if (sc:isParallelState($states[1])) then
      let $childStates := sc:getChildStates($states[1])
      let $childStatesNotAdded := 
        $childStates[not (some $s in $statesToEnter satisfies sc:isDescendant($s, .))]
         
      return sc:addDescendantStatesToEnter(
        $childStatesNotAdded[1], 
        ($statesToEnter, $states[1]), 
        $statesForDefaultEntry,
      
        function($statesToEnter1, $statesForDefaultEntry1, $historyContent1) {
          sc:addDescendantStatesToEnter(
            $childStatesNotAdded[position() > 1], 
            $statesToEnter1,
            $statesForDefaultEntry1,
          
            function($statesToEnter2, $statesForDefaultEntry2, $historyContent2) {
              sc:foldAncestorStatesToEnter($states[position() > 1],
                                           $statesToEnter2,
                                           $statesForDefaultEntry2,
                                           $cont,$historyContent2)
            },$historyContent1
           )
        }, $historyContent
      )
    else sc:foldAncestorStatesToEnter(
      $states[position() > 1],
      ($statesToEnter, $states[1]), 
      $statesForDefaultEntry, 
      $cont,$historyContent
    )
  
  return $results
};


declare function sc:isInFinalState($state,$configuration,$enterState)
{
  
 
   
    
 if (sc:isCompoundState($state)) then 
 
 let $test := fn:trace($state,'state')
 return
     if(fn:empty(sc:getChildStates($state)[functx:is-node-in-sequence(.,($configuration,$enterState)) and sc:isFinalState(.)])) then
      let $test := fn:trace($state,'compound')
      return
      fn:false()
    else
     fn:true()
  else if (sc:isParallelState($state)) then
  let $test := fn:trace($state,'parallel')
  let $allinFinalState := sc:getChildStates($state)
           where every $childState in sc:getChildStates($state)
           satisfies sc:isFinalState($childState)
  return if(fn:empty($allinFinalState)) then 
     fn:false()
   else   fn:true()    
             
  else
  fn:false()
  
                   
 
  
};

declare function sc:getInitialStates($state) as element()* {
  
  let $states :=
  if ($state/@initial) then 
    for $s in fn:tokenize($state/@initial, '\s')
      return $state//*[@id = $s]
  else (
    for $transition in $state/sc:initial/sc:transition
      return  sc:getTargetStates($transition)
  )
  let $test := fn:trace($states,"initial")
  return if (fn:empty($states)) then 
  let $test := fn:trace($state/sc:state[1],"otherinitial")
  return
  $state/sc:state[1]
  else 
  $states
  
};

declare function sc:getHistoryStates($state) as element()*
{
    
for $s in $state/ancestor::sc:scxml//historyStates/history[@ref=$state/@id]/state
return $state/ancestor::sc:scxml//*[@id=$s/@ref]

  
};

declare function sc:isCompoundState($state as element()) as xs:boolean {
  ( fn:exists($state/sc:state) or
    fn:exists($state/sc:parallel) or
    fn:exists($state/sc:final )) and
  fn:exists($state/self::sc:state)
};

declare function sc:isAtomicState($state as element()) as xs:boolean {
  empty($state/sc:state) and
  empty($state/sc:parallel) and
  empty($state/sc:final)
};

declare function sc:isParallelState($state as element()) as xs:boolean {  
  fn:exists($state/self::sc:parallel)
};

declare function sc:isHistoryState($state) as xs:boolean {  
  fn:exists($state/self::sc:history)
};

declare function sc:isFinalState($state as element()) as xs:boolean {  
  fn:exists($state/self::sc:final)
};


declare function sc:getChildStates($state as element()) as element()* {
  $state/*[self::sc:state or self::sc:parallel or self::sc:final]
};

declare function sc:getDescendantStates($state as element()) as element()* {
  $state//*[self::sc:state or self::sc:parallel or self::sc:final]
};

declare function sc:getTargetStates($transition as element()) as element()* {
  if (not($transition/@target)) then () 
  else 
    for $state in fn:tokenize($transition/@target, '\s')
      return $transition/ancestor::sc:scxml//*[@id = $state]
};

declare function sc:getEffectiveTargetStates($transition as element()) as element()* {


 
   if (not($transition/@target)) then () 
  else 
   for $stateid in fn:tokenize($transition/@target, '\s')
   let $state := $transition/ancestor::sc:scxml//*[@id = $stateid]
   return 
   if( sc:isHistoryState($state) ) then 
   
   if(fn:empty(sc:getHistoryStates($state))) then 
   
     for $t in $state/sc:transition
     return (sc:getEffectiveTargetStates($t))
     else
      sc:getHistoryStates($state)
   else 
    
   $state
   
   
   
};

declare function sc:getSourceState($transition) {  
  $transition/..
};


declare function sc:getSourceStateTrans($transition) {  
  
  $transition/ancestor::sc:scxml//*[@id = $transition/parent::*/@ref]
  
  
  
};


declare function sc:isInternalTransition($transition as element()) as xs:boolean {  
  fn:exists($transition/@type='internal')
};

declare function sc:getTransitionDomain($transition as element()) as element() {
  let $targetStates := sc:getEffectiveTargetStates($transition)
  let $sourceState :=  sc:getSourceState($transition) 
  
  return
    if (empty($targetStates)) then ($sourceState) 
    else if (sc:isInternalTransition($transition) and
             sc:isCompoundState($sourceState) and 
             (every $s in $targetStates satisfies sc:isDescendant($s, $sourceState)))
      then $sourceState
    else sc:findLCCA(($sourceState, $targetStates))
};


declare function sc:getTransitionDomainExit($transition as element()) as element()? {
  let $targetStates := sc:getEffectiveTargetStates($transition)
  let $sourceState :=  sc:getSourceState($transition) 
  
  return
    if (empty($targetStates)) then () 
    else if (sc:isInternalTransition($transition) and
             sc:isCompoundState($sourceState) and 
             (every $s in $targetStates satisfies sc:isDescendant($s, $sourceState)))
      then $sourceState
    else sc:findLCCA(($sourceState, $targetStates))
};


declare function sc:getTransitionDomainTrans($transition as element()) as element() {
  let $targetStates := sc:getEffectiveTargetStates($transition)
  let $sourceState :=  sc:getSourceStateTrans($transition) 
  
  return
    if (empty($targetStates)) then ($sourceState) 
    else if (sc:isInternalTransition($transition) and
             sc:isCompoundState($sourceState) and 
             (every $s in $targetStates satisfies sc:isDescendant($s, $sourceState)))
      then $sourceState
    else sc:findLCCA(($sourceState, $targetStates))
};

declare function sc:getTransitionDomainTransExit($transition as element()) as element()? {
  let $targetStates := sc:getEffectiveTargetStates($transition)
  let $sourceState :=  sc:getSourceStateTrans($transition) 
  
  return
    if (empty($targetStates)) then ()
    else if (sc:isInternalTransition($transition) and
             sc:isCompoundState($sourceState) and 
             (every $s in $targetStates satisfies sc:isDescendant($s, $sourceState)))
      then $sourceState
    else sc:findLCCA(($sourceState, $targetStates))
};


declare function sc:findLCCA($states as element()*) as element() {
  let $ancestorsOfHead := 
    sc:getProperAncestors(fn:head($states))[self::sc:scxml or sc:isCompoundState(.)]
  
  let $tail := fn:tail($states)
  
  let $lcca := 
    (for $anc in $ancestorsOfHead 
       return
         if (every $s in $tail satisfies sc:isDescendant($s, $anc)) then 
           $anc else ( (: do nothing :) )
    )[1]
  
  return $lcca
};

declare function sc:isDescendant($state1 as element(),
                                 $state2 as element()) as xs:boolean {
  some $n in $state2//descendant::* satisfies $n is $state1
};

declare function sc:getProperAncestors($state as element()) as element()* {
  fn:reverse($state/ancestor::*)
};

declare function sc:getProperAncestors($state as element(),
                                       $upTo  as element()) as element()* {
  fn:reverse($state/ancestor::*[$upTo << .])
};

declare function sc:eval($expr       as xs:string,
                         $dataModels as element()*) {
  let $dataBindings :=
    for $dataModel in $dataModels
      for $data in $dataModel/sc:data
        return map:entry($data/@id, $data)
  
  let $declare :=
    for $dataModel in $dataModels
      for $data in $dataModel/sc:data
        return 'declare variable $' || $data/@id || ' external; '
      
  return xquery:eval(fn:string-join($declare) || 
                     $expr, 
                     map:merge($dataBindings))
};

declare function sc:isSubDescriptorOrEqual($subDescriptor   as xs:string,
                                           $superDescriptor as xs:string) 
    as xs:boolean {
  fn:matches($subDescriptor, '^' || $superDescriptor)
};

(:~
 : 
 :)
declare function sc:getSpecializedTransitions($transition as element(),
                                              $scxml      as element())
    as element()* {
  let $originalState := $transition/..
  
  let $scxmlState := 
    typeswitch($originalState)
      case element(sc:scxml) return $scxml
      case element(sc:state) return $scxml//sc:state[@id = $originalState/@id]
      case element(sc:parallel) 
        return $scxml//sc:parallel[@id = $originalState/@id]
      default return ()
  
  let $originalTargetStates :=
    sc:getTargetStates($transition)
    
  let $scxmlOriginalTargetStates :=
    for $s in $originalTargetStates return
      typeswitch($s)
        case element(sc:state) return $scxml//sc:state[@id = $s/@id]
        case element(sc:parallel) 
          return $scxml//sc:parallel[@id = $s/@id]
        default return ()
  
      
      
  let $scxmlTransitions :=
    $scxmlState//sc:transition[
      ( (not(@event) and not($transition/@event)) or 
        (@event = '' and $transition/@event = '') or 
        sc:isSubDescriptorOrEqual(@event, $transition/@event) ) and
        
      ( (not(@cond) and not($transition/@cond)) or 
        (@cond = '' and $transition/@cond = '') or 
        
        
        not($transition/@cond) or $transition/@cond = '' or
        @cond = $transition/@cond or
        fn:matches(@cond, '^' || 
                   functx:escape-for-regex($transition/@cond || ' and')) or
        fn:matches(@cond, 
                   functx:escape-for-regex(' and ' || $transition/@cond) || '$') 
      ) and
      
      ( (not(@target) and not($transition/@target)) or 
        (@target = '' and $transition/@target = '') or 
        (
          let $newTargets := fn:tokenize(@target, '\s')
          return
          every $target in $scxmlOriginalTargetStates satisfies (
            some $newTarget in $newTargets satisfies 
              $target/@id = $newTarget or
              $target//*/@id = $newTarget
          )
        ) 
      ) and
        
      ( (not(@type) and not($transition/@type)) or 
        (@type = '' and $transition/@type = '') or 
        @type = $transition/@type )
    ]
  
  return $scxmlTransitions
};