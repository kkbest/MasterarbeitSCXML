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
import module namespace scx = 'http://www.w3.org/2005/07/scxml/extension/';
import module namespace functx = 'http://www.functx.com';
import module namespace mba = 'http://www.dke.jku.at/MBA';
import module namespace sync='http://www.dke.jku.at/MBA/Synchronization';
declare namespace xes = 'www.xes-standard.org/';
declare namespace concept = 'www.xes-standard.org/concept';

(:import module namespace sync = 'http://www.dke.jku.at/MBA/Synchronization';
:)
(:~
 : 
 :)
declare function sc:matchesEventDescriptors($eventName as xs:string,
        $eventDescriptors as xs:string*)
as xs:boolean {
    some $descriptor in $eventDescriptors satisfies

    ( fn:matches($descriptor || '|' || $eventName, '^((([a-zA-Z0-9\.]+)\.\*\|\3\.[a-zA-Z0-9\.]+)|(\*\|[a-zA-Z0-9\.]+)|((([a-zA-Z0-9\.]|\.)+)\|(\6))|(([a-zA-Z0-9\.]+)\|\10\.[a-zA-Z0-9\.]+))$')
            or $eventDescriptors = "*" or $eventName = $descriptor or fn:matches($eventName, '^' || $descriptor || '$')
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
 : 
 :)
declare updating function sc:assign($dataModels as element()*,
        $location as xs:string,
        $expression as xs:string?,
        $type as xs:string?,
        $attribute as xs:string?,
        $nodelist as node()*,
        $dbName as xs:string,
        $collectionName as xs:string,
        $mbaName as xs:string
) {


    try
    {
        let $test := fn:trace($expression, 'expression')
        let $test := fn:trace($nodelist, 'nodelist')
        let $test := fn:trace($location, 'location')

        let $test := fn:trace("try")

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
            then ()
            else $expression

        let $test := fn:trace($expression, 'expression')

        return


            xquery:update(
                    fn:trace(
                            scx:importModules() ||
                            fn:string-join($declare) ||
                            $declareNodeList ||
                            scx:builtInFunctionDeclarations() ||
                            'let $locations := ' || $location || ' ' || (
                                if (not(fn:empty($expression))) then
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
                            )), map:merge(($dataBindings, map:entry('nodelist', $nodelist)))
            )
    }
    catch *

    {

        let $test := fn:trace("catchassign")

        let $test := fn:trace($err:code, $err:description)
        let $mbtest := 'mba:getMBA( "' || $dbName || '" ,"' || $collectionName || '","' || $mbaName || '") '
        return
            xquery:update(
                    scx:importModules() ||
                    ' let $event := <event name="error.execution"  type="platform" xmlns=""></event> ' ||
                    'let $mba := ' || $mbtest || '
      return mba:enqueueInternalEvent($mba,$event)')

    }

};


declare updating function sc:getValue($dataModels as element()*,
        $location as xs:string,
        $expression as xs:string?,
        $type as xs:string?,
        $attribute as xs:string?,
        $nodelist as node()*,
        $id) {
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


    let $location := '$_x/' || 'response'
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
        $nodelist as node()*,
        $id,
        $dbName, $collectionName, $mbaName) {


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
            if (fn:empty($expression) or $expression = '')
            then '() '
            else sc:evalWithError($expression, $dataModels)


        let $expression :=
            if (fn:empty($expression) or (fn:matches(fn:string($expression), '^err:'))) then
                ' '
            else
                $expression
        let $location := '$_x/' || 'response'
        return
            xquery:update(
                    scx:importModules() ||
                    fn:string-join($declare) ||
                    $declareNodeList ||
                    scx:builtInFunctionDeclarations() ||
                    'let $locations := ' || $location || ' ' || (
                        if ($expression) then
                            'let $newValues :=  <log>' || $label || $expression || ' </log> '
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


        let $test := fn:trace($err:code, $err:description)
        let $mbtest := 'mba:getMBA( "' || $dbName || '" ,"' || $collectionName || '","' || $mbaName || '") '
        return
            xquery:update(
                    scx:importModules() ||
                    ' let $event := <event name="error.execution" type="platform" xmlns=""></event> ' ||
                    'let $mba := ' || $mbtest || '
      return mba:enqueueInternalEvent($mba,$event)')

    }
};


declare function sc:selectEventlessTransitions($configuration as element()*,
        $dataModels as element()*)
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

                    if (((not($t/@event) or $t/@event = '') and (not($t/@cond) or $t/@cond = '' or
                            $evaluation))) then
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
                    sc:evaluateCond($t/@cond, $dataModels)
                }
                catch *
                {
                    fn:false()
                }
                return

                    if ((sc:matchesEventDescriptors(
                            functx:trim($event),
                            fn:tokenize($t/@event, '\s')
                    ) and (not($t/@cond) or
                            $evaluation))) then
                        $t


                    else
                        ()

            return $transitions[1]

        return sc:removeConflictingTransitions($configuration, ($enabledTransitions))
};


declare function sc:selectTransitionsoC($configuration as element()*,
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

                return

                    if ((sc:matchesEventDescriptors(
                            functx:trim($event),
                            fn:tokenize($t/@event, '\s')
                    ))) then
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
        return if (not(fn:empty($domain))) then
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
        return if (not(fn:empty($domain))) then
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
                map:entry('historyContent', ())
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

                            let $f := function($statesToEnter, $statesForDefaultEntry, $historyContent) {
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
            if (not(fn:empty($stateLists))) then $stateLists
            else ()

        return $statesToEnter
};


declare function sc:computeEntryOc($transitions as element()*) {
    if (fn:empty($transitions)) then ()
    else
        let $statesToEnterStart :=
            for $t in $transitions
            return sc:getTargetStates($t)

        let $stateLists :=
            map:merge((
                map:entry('statesToEnter', ()),
                map:entry('statesForDefaultEntry', ()),
                map:entry('historyContent', ())
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
                        sc:addDescendantStatesToEnter($s, $statesToEnter, $statesForDefaultEntry, $f, $historyContent)
                }
        )

        let $stateLists := $addDescendants($statesToEnterStart)

        let $stateLists :=
            (
                for $t in $transitions
                let $ancestor := sc:getTransitionDomain($t)
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
                                sc:addAncestorStatesToEnter($s, $ancestor, $statesToEnter, $statesForDefaultEntry, $f, $historyContent)
                        }
                )

                for $s in sc:getTargetStates($t)
                return $addAncestors($s)
            )

        let $statesToEnter :=
            if (not(fn:empty($stateLists))) then $stateLists
            else ()

        return $statesToEnter
};


declare function sc:computeEntryInit($scxml) {

    let $statesToEnterStart := if (fn:empty(sc:getInitialStates($scxml))) then

        $scxml//*[self::sc:state or self::sc:final][1]
    else
        sc:getInitialStates($scxml)


    let $stateLists :=
        map:merge((
            map:entry('statesToEnter', ()),
            map:entry('statesForDefaultEntry', ()),
            map:entry('historyContent', ())
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
                    sc:addDescendantStatesToEnter($s, $statesToEnter, $statesForDefaultEntry, $f, ())
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
                            sc:addAncestorStatesToEnter($s, $ancestor, $statesToEnter, $statesForDefaultEntry, $f, $historyContent)
                    }
            )

            return $addAncestors($s)
        )

    let $statesToEnter :=
        if (not(fn:empty($stateLists))) then $stateLists
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

    return sc:addDescendantStatesToEnter($state, (), (), $f, ())
};


declare function sc:addDescendantStatesToEnter($states as element()*,
        $statesToEnter as element()*,
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

    let $test := fn:trace($states[1], "stateToCheck")
    let $results :=
        if (fn:empty($states)) then
            $cont($statesToEnter, $statesForDefaultEntry, $historyContent)
        else if (sc:isHistoryState($states[1])) then
            (

            (:TODO anschauen:)

            let $test := fn:trace($states[1], "responseisHistoryState")
            let $history := sc:getHistoryStates($states[1])
            return if (fn:empty($history))
            then
                let $test := fn:trace($states[1], "responseno history exists")
                (:default history
      HistoryContent will be done in ExcecuteContent:)

                let $historyContent := ($historyContent, $states[1]/sc:transition/*)
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

                                                $cont, $historyContent2
                                        )
                                    }, $historyContent1
                            )
                        }, $historyContent
                )


            else

                let $test := fn:trace($states[1], "responsethereisaHistory")
                let $test := fn:trace($history, "responsehistoryValue")
                return


                    sc:addDescendantStatesToEnter(
                            $history[1],
                            ($statesToEnter),
                            ($statesForDefaultEntry, $states[1]),

                            function($statesToEnter1, $statesForDefaultEntry1, $historyContent1) {
                                sc:addAncestorStatesToEnter(
                                        $history[1],
                                        $states[1]/parent::*,
                                        $statesToEnter1,
                                        $statesForDefaultEntry1,
                                        function($statesToEnter2, $statesForDefaultEntry2, $historyContent2) {
                                            sc:addDescendantStatesToEnter(
                                                    $history[position() > 1],
                                                    $statesToEnter2,
                                                    $statesForDefaultEntry2,

                                                    $cont, $historyContent2
                                            )
                                        }, $historyContent1
                                )
                            }, $historyContent
                    )
            )
        else if (sc:isAtomicState($states[1])) then
                sc:addDescendantStatesToEnter(
                        $states[position() > 1], ($statesToEnter, $states[1]), $statesForDefaultEntry, $cont, $historyContent
                )
            else if (sc:isCompoundState($states[1])) then
                    let $test := fn:trace($states[1], "compound")
                    let $initialStates := sc:getInitialStates($states[1])
                    return sc:addDescendantStatesToEnter(
                            $initialStates[1],
                            ($statesToEnter, $states[1]),
                            ($statesForDefaultEntry, $states[1]),

                            function($statesToEnter1, $statesForDefaultEntry1, $historyContent1) {
                                sc:addAncestorStatesToEnter(
                                        $initialStates[1],
                                        $states[1],
                                        $statesToEnter1,
                                        $statesForDefaultEntry1,
                                        function($statesToEnter2, $statesForDefaultEntry2, $historyContent2) {
                                            sc:addDescendantStatesToEnter(
                                                    $initialStates[position() > 1],
                                                    $statesToEnter2,
                                                    $statesForDefaultEntry2,

                                                    $cont, $historyContent2
                                            )
                                        }, $historyContent1
                                )
                            }, $historyContent
                    )
                else if (sc:isParallelState($states[1])) then

                        let $childStates := sc:getChildStates($states[1])
                        let $childStatesNotAdded :=
                            $childStates[not(some $s in $statesToEnter satisfies sc:isDescendant($s, .))]

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
                                                sc:addDescendantStatesToEnter($states[position() > 1],
                                                        $statesToEnter2,
                                                        $statesForDefaultEntry2,

                                                        $cont, $historyContent)
                                            }, $historyContent)
                                }, $historyContent
                        )
                    else ()

    return $results
};

declare function sc:addAncestorStatesToEnter($state as element(),
        $ancestor as element()) as item() {
    let $f := function($statesToEnter, $statesForDefaultEntry, $historyContent) {
        map:merge((
            map:entry('statesToEnter', $statesToEnter),
            map:entry('statesForDefaultEntry', $statesForDefaultEntry),
            map:entry('historyContent', $historyContent)
        ))
    }

    return sc:addAncestorStatesToEnter($state, $ancestor, (), (), $f, ())
};

declare function sc:addAncestorStatesToEnter($states as element()*,
        $ancestor as element(),
        $statesToEnter as element()*,
        $statesForDefaultEntry as element()*,
        $cont, $historyContent) as item() {
    let $properAncestors :=
        for $s in $states return sc:getProperAncestors($s, $ancestor)

    let $results :=
        if (fn:empty($properAncestors)) then $cont($statesToEnter, $statesForDefaultEntry, $historyContent)
        else sc:foldAncestorStatesToEnter($properAncestors,
                $statesToEnter,
                $statesForDefaultEntry,
                $cont, $historyContent)

    return $results
};

declare function sc:foldAncestorStatesToEnter($states as element()*,
        $statesToEnter as element()*,
        $statesForDefaultEntry as element()*,
        $cont, $historyContent) as item() {
    let $results :=
        if (fn:empty($states)) then $cont($statesToEnter, $statesForDefaultEntry, $historyContent)
        else if (sc:isParallelState($states[1])) then
            let $childStates := sc:getChildStates($states[1])
            let $childStatesNotAdded :=
                $childStates[not(some $s in $statesToEnter satisfies sc:isDescendant($s, .))]

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
                                            $cont, $historyContent2)
                                }, $historyContent1
                        )
                    }, $historyContent
            )
        else sc:foldAncestorStatesToEnter(
                    $states[position() > 1],
                    ($statesToEnter, $states[1]),
                    $statesForDefaultEntry,
                    $cont, $historyContent
            )

    return $results
};


declare function sc:isInFinalState($state, $configuration, $enterState)
{


    if (sc:isCompoundState($state)) then

        let $test := fn:trace($state, 'state')
        return
            if (fn:empty(sc:getChildStates($state)[functx:is-node-in-sequence(., ($configuration, $enterState)) and sc:isFinalState(.)])) then
                let $test := fn:trace($state, 'compound')
                return
                    fn:false()
            else
                fn:true()
    else if (sc:isParallelState($state)) then
        let $test := fn:trace($state, 'parallel')
        let $allinFinalState := sc:getChildStates($state)
        where every $childState in sc:getChildStates($state)
        satisfies sc:isFinalState($childState)
        return if (fn:empty($allinFinalState)) then
            fn:false()
        else fn:true()

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
            return sc:getTargetStates($transition)
        )
    let $test := fn:trace($states, "initial")
    return if (fn:empty($states)) then
        let $test := fn:trace($state/sc:state[1], "otherinitial")
        return
            $state//*[self::sc:state or self::sc:final][1]
    else
        $states

};

declare function sc:getHistoryStates($state) as element()*
{

    for $s in $state/ancestor::sc:scxml//historyStates/history[@ref = $state/@id]/state
    return $state/ancestor::sc:scxml//*[@id = $s/@ref]


};

declare function sc:isCompoundState($state as element()) as xs:boolean {
    ( fn:exists($state/sc:state) or
            fn:exists($state/sc:parallel) or
            fn:exists($state/sc:final)) and
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

(:declare function sc:getDescendantStates($state as element()) as element()* {
    $state//*[self::sc:state or self::sc:parallel or self::sc:final]
};:)

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
            if ( sc:isHistoryState($state)) then

                if (fn:empty(sc:getHistoryStates($state))) then

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
    fn:exists($transition/@type = 'internal')
};

declare function sc:getTransitionDomain($transition as element()) as element() {
    let $targetStates := sc:getEffectiveTargetStates($transition)
    let $sourceState := sc:getSourceState($transition)

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
    let $sourceState := sc:getSourceState($transition)

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
    let $sourceState := sc:getSourceStateTrans($transition)

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
    let $sourceState := sc:getSourceStateTrans($transition)

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
        $upTo as element()) as element()* {
    fn:reverse($state/ancestor::*[$upTo << .])
};

declare function sc:eval($expr as xs:string,
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


(:
declare function sc:evalWithError($expr       as xs:string,
                         $dataModels as element()*) {
 :)

declare function sc:evalWithError($expr,
        $dataModels) {
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

        return xquery:eval(fn:string-join($declare) ||
        $expr,
                map:merge($dataBindings))
    }
    catch *
    {


        $err:code
    }

};


declare function sc:isSubDescriptorOrEqual($subDescriptor as xs:string,
        $superDescriptor as xs:string)
as xs:boolean {
    fn:matches($subDescriptor, '^' || $superDescriptor)
};

(:~
 : 
 :)
declare function sc:getSpecializedTransitions($transition as element(),
        $scxml as element())
as element()* {
    let $originalState := $transition/..

    let $scxmlState :=
        typeswitch ($originalState)
            case element(sc:scxml) return $scxml
            case element(sc:state) return $scxml//sc:state[@id = $originalState/@id]
            case element(sc:parallel)
                return $scxml//sc:parallel[@id = $originalState/@id]
            default return ()

    let $originalTargetStates :=
        sc:getTargetStates($transition)

    let $scxmlOriginalTargetStates :=
        for $s in $originalTargetStates return
            typeswitch ($s)
                case element(sc:state) return $scxml//sc:state[@id = $s/@id]
                case element(sc:parallel)
                    return $scxml//sc:parallel[@id = $s/@id]
                default return ()


    let $scxmlTransitions :=
        $scxmlState//sc:transition[
        ( (not(@event) and not($transition/@event)) or
                (@event = '' and $transition/@event = '') or
                sc:isSubDescriptorOrEqual(@event, $transition/@event)) and

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
                        @type = $transition/@type)
        ]

    return $scxmlTransitions
};



declare updating function sc:createDatamodel($mba)
{

    let $scxml := mba:getSCXML($mba)
    let $configuration := mba:getConfiguration($mba)

    let $dataModels :=

        if (fn:empty($configuration)) then
            mba:selectAllDataModels($mba)[not(./ancestor::sc:invoke)]
        else
            mba:selectDataModels($configuration)[not(./ancestor::sc:invoke)]

    let $data :=
        if ($scxml/@binding = 'late') then
            $scxml/sc:datamodel/sc:data[not(fn:matches(@id, '^_'))]
        else
            $scxml//sc:datamodel/sc:data[not(fn:matches(@id, '^_')) and not(./ancestor::sc:invoke)]

    for $d in $data

    return

        if ($d/@expr) then
            (try
            {
                let $value := sc:eval($d/@expr, $dataModels)
                let $test := fn:trace("hallo")
                return insert node <data id="{$d/@id}">{$value} </data> into $scxml/sc:datamodel, delete node $d

            }
            catch *
            {
                let $test := fn:trace("hallo2")
                let $test := fn:trace($err:description, "errdesc")
                let $event := <event name="error.execution" xmlns="">
                    <data>{$err:code, $err:description}</data></event>
                return mba:enqueueInternalEvent($mba, $event), insert node <data id="{$d/@id}"></data> into $scxml/sc:datamodel, delete node $d

            })

        else if ($d/@src) then
            (try
            {
                let $value :=
                    if (fn:substring-before($d/@src, ':') = 'file') then

                        let $test := fn:trace("hallofile")
                        return fn:unparsed-text(fn:substring-after($d/@src, ':'))
                    else
                        ()

                let $test := fn:trace("hallo")
                return insert node <data id="{$d/@id}">{$value} </data> into $scxml/sc:datamodel, delete node $d

            }
            catch *
            {
                let $test := fn:trace("hallo2")
                let $event := <event name="error.execution" xmlns=""></event>
                return mba:enqueueInternalEvent($mba, $event), insert node <data id="{$d/@id}">{$err:code}</data> into $d/parent::*, delete node $d

            })

        else if ($d/@systemsrc) then
                (try
                {
                    let $value :=
                        if (fn:matches($d/@systemsrc, '\$_ioprocessors')) then sc:evalWithError($d/@systemsrc, $dataModels)
                        else
                            sc:evalWithError($d/@systemsrc, $dataModels)/text()


                    let $test := fn:trace("hallo")
                    return insert node <data id="{$d/@id}">{$value} </data> into $d/parent::*, delete node $d

                }
                catch *
                {
                    let $test := fn:trace("hallo2")
                    let $event := <event name="error.execution" xmlns=""></event>
                    return mba:enqueueInternalEvent($mba, $event), insert node <data id="{$d/@id}">{$err:code}</data> into $d/parent::*, delete node $d

                })

            else
                ()

};




declare updating function sc:initMBARest($dbName as xs:string, $collectionName as xs:string, $mbaName as xs:string)
{

    let $mba := mba:getMBA($dbName, $collectionName, $mbaName)
    let $scxml := mba:getSCXML($mba)
    return
        mba:init($mba), sc:removeFromUpdateLog($dbName, $collectionName, $mbaName)
};


declare updating function sc:initSCXMLRest($dbName as xs:string, $collectionName as xs:string, $mbaName as xs:string)
{
    let $mba := mba:getMBA($dbName, $collectionName, $mbaName)
    let $scxml := mba:getSCXML($mba)
    let $configuration := mba:getConfiguration($mba)
    return
        if (not($configuration)) then
            let $entrySet := sc:computeEntryInit($scxml)[1]
            return
                if (not(fn:empty($entrySet))) then
                    mba:updatecurrentEntrySet($mba, map:get($entrySet, 'statesToEnter'))
                else ()
        else ()
};


declare updating function sc:updateRunning($dbName as xs:string, $collectionName as xs:string, $mbaName as xs:string)
{
    let $mba := mba:getMBA($dbName, $collectionName, $mbaName)
    let $currentEvent := mba:getCurrentEvent($mba)

(:TODO Check Cancel ID !!!:)
    return
        (
            if (
                $currentEvent/type = 'cancel') then
                mba:updateRunning($mba, fn:false())
            else
                ())

};


declare updating function sc:autoForward($dbName as xs:string, $collectionName as xs:string, $mbaName as xs:string, $s)
{

    let $mba := mba:getMBA($dbName, $collectionName, $mbaName)
    let $configuration := mba:getConfiguration($mba)
    let $currentEvent := mba:getCurrentEvent($mba)
    let $dataModel := mba:selectAllDataModels($mba)
    let $event :=
        if (fn:empty(sc:evalWithError('$_event/name/text()', $dataModel))
                or fn:matches(fn:string(sc:evalWithError('$_event/name/text()', $dataModel)), '^err:')) then
            ()
        else
            (
                let $name := sc:evalWithError('$_event/name/text()', $dataModel)
                let $type := sc:evalWithError('$_event/type/text()', $dataModel)
                let $sendid := sc:evalWithError("$_event/sendid/text()'", $dataModel)
                let $origin := sc:evalWithError('$_event/origin/text()', $dataModel)
                let $origintype := sc:evalWithError('$_event/origintype/text()', $dataModel)
                let $invokeid := sc:evalWithError('$_event/invokeid/text()', $dataModel)
                let $data := sc:evalWithError('$_event/data', $dataModel)
                return
                    <event name="{$name}" type="{$type}" sendid="{$sendid}" origin="{$origin}"
                    origintype="{$origintype}" invokeid="{$invokeid}">{$data}</event>)
    return
        if (fn:empty($event)) then
            ()
        else
            (

                let $insertMba := sc:getMBAFromText(mba:getChildInvokeQueue($mba)/*[@ref = $s/@id]/text())
                return
                    try
                    {
                        mba:enqueueExternalEvent($insertMba, $event)
                    }
                    catch *
                    {
                        ()
                    }
            )
};


declare updating function sc:removeFromInsertLog($dbName as xs:string, $collectionName as xs:string, $mbaName as xs:string)
{
    let $mba := mba:getMBA($dbName, $collectionName, $mbaName)
    return mba:removeFromInsertLog($mba)
};


declare updating function sc:markAsUpdated($dbName as xs:string, $collectionName as xs:string, $mbaName as xs:string)
{
    let $mba := mba:getMBA($dbName, $collectionName, $mbaName)
    return mba:markAsUpdated($mba)
};


declare updating function sc:getNextExternalEvent($dbName as xs:string, $collectionName as xs:string, $mbaName as xs:string)
{
    let $mba := mba:getMBA($dbName, $collectionName, $mbaName)
    return mba:loadNextExternalEvent($mba)
};


declare updating function sc:getNextInternalEvent($dbName as xs:string, $collectionName as xs:string, $mbaName as xs:string)
{
    let $mba := mba:getMBA($dbName, $collectionName, $mbaName)
    return mba:loadNextInternalEvent($mba)
};


declare function sc:getExecutableContentsExit($dbName as xs:string, $collectionName as xs:string, $mbaName as xs:string, $state as element()*)
{
    for $s in $state
    return $s/sc:onexit/reverse(*)
};


declare function sc:getExecutableContentsTransitions($dbName as xs:string, $collectionName as xs:string, $mbaName as xs:string)
{
    let $mba := mba:getMBA($dbName, $collectionName, $mbaName)
    let $transitions := mba:getCurrentTransitionsQueue($mba)/transitions/*
    let $contents :=
        for $t in $transitions
        return $t/*
    return ($contents)
};



declare function sc:getExecutableContentsEnter($dbName as xs:string, $collectionName as xs:string, $mbaName as xs:string, $state, $historyContent)
{
    let $mba := mba:getMBA($dbName, $collectionName, $mbaName)
    let $scxml := mba:getSCXML($mba)

    let $configuration := mba:getConfiguration($mba)
    let $dataModels := mba:selectDataModels($configuration)


    let $transitions :=
        mba:getCurrentTransitionsQueue($mba)/transitions/*


    let $content1 :=

        ($state/sc:onentry/*, $state/sc:initial/sc:transition/*)


    let $content2 :=

        $historyContent


    return ($content1, $content2)
};


(:declare updating function sc:executeExecutablecontent($dbName as xs:string, $collectionName as xs:string, $mbaName as xs:string, $content, $counter)
{
    sc:runExecutableContent($dbName, $collectionName, $mbaName, $content[$counter])
};
:)

declare updating function sc:removeFromUpdateLog($dbName as xs:string, $collectionName as xs:string, $mbaName)
{

    let $mba := mba:getMBA($dbName, $collectionName, $mbaName)
    return mba:removeFromUpdateLog($mba)
};


(:declare function sc:getcurrentExternalEvent($mba)
{
    let $queue := mba:getExternalEventQueue($mba)
    let $nextEvent := ($queue/event)[1]
    let $nextEventName := <name xmlns="">{fn:string($nextEvent/@name)}</name>
    let $nextEventData := <data xmlns="">{$nextEvent/*}</data>
    let $currentEvent := mba:getCurrentEvent($mba)
    return $currentEvent
};:)




declare function sc:getResult($dbName as xs:string, $collectionName as xs:string, $mbaName as xs:string, $id as xs:integer)
{


    let $mba := mba:getMBA($dbName, $collectionName, $mbaName)
    return
    $mba/mba:topLevel/mba:elements/sc:scxml/sc:datamodel/sc:data[@id = '_x']/response/response[@ref = $id]

};


declare function sc:getCounter($dbName as xs:string, $collectionName as xs:string, $mbaName as xs:string)
{
    let $mba := mba:getMBA($dbName, $collectionName, $mbaName)
    return $mba/*/*/sc:scxml/sc:datamodel/sc:data[@id = '_x']/response/counter/text()
};


declare updating function sc:updateCounter($dbName as xs:string, $collectionName as xs:string, $mbaName)
{

    let $mba := mba:getMBA($dbName, $collectionName, $mbaName)
    let $oldValue := $mba/*/*/sc:scxml/sc:datamodel/sc:data[@id = '_x']/response/counter/text()
    let $newCounter := <counter>{$oldValue + 1}</counter>
    return replace value of node $mba/*/*/sc:scxml/sc:datamodel/sc:data[@id = '_x']/response/counter with $newCounter
};


declare updating function sc:exitStatesSingle($dbName, $collectionName, $mbaName, $stateToExit, $type)
{


    let $mba := mba:getMBA($dbName, $collectionName, $mbaName)
    let $scxml := mba:getSCXML($mba)


    let $configuration := mba:getConfiguration($mba)
    let $dataModels := mba:selectDataModels($configuration)


    (: remove from States to Invoke:)
    (:TODO Anschauen exitOrder -> reverted Documentorder:)
    (: configuration will be done after enterStates:)


    for $state in $stateToExit

    return
        (
            for $h in $state/sc:history

            let $insert :=
                fn:fold-left((functx:distinct-deep(($configuration, mba:getCurrentExitSet($mba)))), (), function($result, $curr)
                {
                    let $result :=
                        ($result,

                        (:for $h in sc:getStateHistoryNodes($state):)
                        if ($h/@type = 'deep') then
                            if (sc:isDescendant($curr, $state) and sc:isAtomicState($curr) and not(fn:deep-equal($curr, $state))) then
                                <state ref="{$curr/@id}">
                                </state>
                            else ()
                        else
                            if (fn:deep-equal($h/parent::*, $curr/parent::*)) then
                                <state ref="{$curr/@id}"/>
                            else ()
                        )
                    return $result
                })

            return
                if (fn:empty(sc:getHistoryStates($h))) then
                    (insert node <history ref="{$h/@id}">{$insert}</history> into mba:getHistory($mba))

                else
                    (replace node mba:getHistory($mba)/history[@ref = $h/@id]  with <history ref="{$h/@id}">{$insert}</history>)
            ,

            (


                try
                {
                    let $srcChild := mba:getChildInvokeQueue($mba)/invoke[@ref = $state/@id
                    ]


                    for $src in $srcChild


                    let $insertMba := sc:getMBAFromText($src)
                    return
                        if (fn:matches(fn:string($insertMba), '^err:')) then
                            ()
                        else

                            let $sendid := 'mba:' || $dbName || ',' || $collectionName || ',' || $mbaName
                            let $cancelEvent := <event type="cancel" name="cancel" sendid="{$sendid}"> </event>

                            return


                                mba:enqueueExternalEvent($insertMba, $cancelEvent)
                }

                catch *
                {
                    ()
                }

            )
            , mba:removestatesToInvoke($mba, $state)
        )

};


declare updating function sc:enterStatesSingle($dbName, $collectionName, $mbaName, $state as element())
{


    let $mba := mba:getMBA($dbName, $collectionName, $mbaName)
    let $scxml := mba:getSCXML($mba)

    let $currentEvent := mba:getCurrentEvent($mba)
    let $eventName := $currentEvent/name

    let $configuration := mba:getConfiguration($mba)
    let $dataModels := mba:selectDataModels($configuration)


    return
        if (sc:isFinalState($state)) then

            if (fn:empty($state/parent::sc:scxml)) then


                let $parent := $state/parent::*
                let $grandparent := $parent/parent::*
                let $eventname := "done.state." || $parent/@id


                let $params :=

                    try
                    {

                        for $p in $state/sc:donedata/sc:param
                        return
                            element {$p/@name} {sc:eval($p/@expr, $dataModels)}

                    }
                    catch *
                    {
                        let $test := fn:trace("errorinContent")
                        return $err:code

                    }


                let $content :=

                    try
                    {
                        for $c in $state/sc:donedata/sc:content
                        return
                            if ($c/@expr) then
                                <data> {sc:eval($c/@expr, $dataModels)}</data>

                            else
                                <data>{$c/text()}</data>

                    }
                    catch *
                    {
                        let $test := fn:trace("errorinContent")
                        return $err:code

                    }


                let $error
                    :=
                    if (fn:matches(fn:string($content), '^err:')) then
                        fn:true()
                    else
                        fn:false()


                let $errorParams
                    :=
                    if (fn:matches(fn:string($params), '^err:')) then
                        fn:true()
                    else
                        fn:false()


                let $content :=
                    if ($error) then
                        ()
                    else
                        $content

                let $eventError := <event name="error.execution" type="platform" xmlns=""></event>


                let $params :=
                    if ($errorParams) then
                        ()
                    else
                        $params

                let $eventError := <event name="error.execution" type="platform" xmlns=""></event>

                let $eventbody :=
                    ($params,
                    $state/sc:donedata/sc:content/text())


                (: let $doneData := for $data in $state/sc:donedata/*
                     return <data> {fn:string( $data/@expr)}</data>:)


                let $test := ($params, $content)
                let $event := <event name="{$eventname}" type="platform">{$test} </event> (:TODO donedata:)


                return
                    if (sc:isParallelState($grandparent)) then

                        if (every $s in sc:getChildStates($grandparent) satisfies sc:isInFinalState($s, $configuration, $state)) then

                            let $parallelEventName := "done.state." || $grandparent/@id
                            let $parallelEvent := <event name="{$parallelEventName}" type="platform">  </event>
                            return
                                if ($error or $errorParams) then
                                    (mba:enqueueInternalEvent($mba, $eventError), mba:enqueueInternalEvent($mba, $event), mba:enqueueInternalEvent($mba, $parallelEvent), mba:addstatesToInvoke($mba, $state), sc:initDatamodel($state, $mba), mba:addCurrentStates($mba, $state))

                                else

                                    (mba:enqueueInternalEvent($mba, $event), mba:enqueueInternalEvent($mba, $parallelEvent), mba:addstatesToInvoke($mba, $state), sc:initDatamodel($state, $mba), mba:addCurrentStates($mba, $state))


                        else
                            if ($error or $errorParams) then
                                (mba:enqueueInternalEvent($mba, $eventError), mba:enqueueInternalEvent($mba, $event), mba:addstatesToInvoke($mba, $state), sc:initDatamodel($state, $mba), mba:addCurrentStates($mba, $state))
                            else
                                (mba:enqueueInternalEvent($mba, $event), mba:addstatesToInvoke($mba, $state), sc:initDatamodel($state, $mba), mba:addCurrentStates($mba, $state))

                    else
                        if ($error or $errorParams) then

                            (mba:enqueueInternalEvent($mba, $eventError), mba:enqueueInternalEvent($mba, $event), mba:addstatesToInvoke($mba, $state), sc:initDatamodel($state, $mba), mba:addCurrentStates($mba, $state))
                        else
                            (   mba:enqueueInternalEvent($mba, $event), mba:addstatesToInvoke($mba, $state), sc:initDatamodel($state, $mba), mba:addCurrentStates($mba, $state))

            else

                ( (:TODO set running to false:)

                mba:updateRunning($mba, fn:false()), mba:addstatesToInvoke($mba, $state), sc:initDatamodel($state, $mba), mba:addCurrentStates($mba, $state))
        else
            ( mba:addstatesToInvoke($mba, $state), sc:initDatamodel($state, $mba), mba:addCurrentStates($mba, $state))

};


declare updating function sc:exitInterpreter($dbName, $collectionName, $mbaName)

{let $mba := mba:getMBA($dbName, $collectionName, $mbaName)



let $configuration := mba:getConfiguration($mba)

for $s in $configuration

return (: runExitcontent , cancelInvoke, :)
    if (sc:isFinalState($s) and not(fn:empty($s/parent::*[self::sc:scxml]))) then
        let $invokeid := mba:getParentInvoke($mba)/id
        let $name := 'done.invoke' || $invokeid

        let $event := <event invokeid="{$invokeid}"  name="{$name}"></event>

        let $src := mba:getParentInvoke($mba)/parent

        let $insertMba := sc:getMBAFromText($src)


        return (mba:enqueueExternalEvent($insertMba, $event))

    else
        ()

};


declare updating function sc:initDatamodel($states, $mba)
{

    let $scxml := mba:getSCXML($mba)
    let $configuration := mba:getConfiguration($mba)
    let $dataModels := mba:selectDataModels($configuration)

    let $test := fn:trace('isinInit')
    return
        if ($scxml/@binding = 'late') then

            for $s in $states
            let $data := $s/sc:datamodel/*
            let $test := fn:trace($data, 'dataisinInit')
            for $d in $data
            return


                if ($d/@expr) then
                    (try
                    {
                        let $value := sc:eval($d/@expr, $dataModels)
                        let $test := fn:trace("hallo")
                        return insert node <data id="{$d/@id}">{$value} </data> into $s/sc:datamodel, delete node $d

                    }
                    catch *
                    {
                        let $test := fn:trace("hallo2")
                        let $event := <event name="error.execution.initDb" type="platform" xmlns=""></event>
                        return mba:enqueueInternalEvent($mba, $event), insert node <data id="{$d/@id}"></data> into $s/sc:datamodel, delete node $d

                    })

                else if ($d/@src) then
                    (try
                    {
                        let $value :=
                            if (fn:substring-before($d/@src, ':') = 'file') then

                                let $test := fn:trace("hallofile")
                                return fn:unparsed-text(fn:substring-after($d/@src, ':'))
                            else
                                ()

                        let $test := fn:trace("hallo")
                        return insert node <data id="{$d/@id}">{$value} </data> into $scxml/sc:datamodel, delete node $d

                    }
                    catch *
                    {
                        let $test := fn:trace("hallo2")
                        let $event := <event name="error.execution.initDbsrc" type="platform" xmlns=""></event>
                        return mba:enqueueInternalEvent($mba, $event), insert node <data id="{$d/@id}"></data> into $scxml/sc:datamodel, delete node $d

                    })

                else
                    let $test := fn:trace('no expr')
                    return ()

        else
            let $test := fn:trace('no latebinding')
            return ()

};

declare function sc:getMBAFromText($src as xs:string)
{

    let $mbaData :=
        if (fn:substring-before($src, ':') = 'mba') then


            fn:substring-after($src, ':')
        else if (fn:substring-before($src, ':') = '#_scxml_mba') then
            fn:substring-after($src, ':')
        else ()

    let $mbadata := fn:tokenize($mbaData, ',')
    return if (fn:empty($mbadata)) then

    (:else if ($location  matches ) :)
        ()
    else
        let $parentmba :=
            try
            {
                mba:getMBA($mbadata[1], $mbadata[2], $mbadata[3])

            }
            catch *
            {
                $err:code
            }
        return $parentmba
};


declare updating function sc:doLogging($mba as element(),$transition as element()*,$transType as xs:string)
{
 let $log :=  mba:getLog($mba)
 let $time := fn:current-dateTime()
 
 let $insert := 
 
 if($transType != 'init') then 
 
 
 let $von :=  sc:getSourceStateTrans($transition)

 let $to := sc:getTargetStates($transition)

 let $cond := $transition/@cond
 let $event := $transition/@event
 let $currentEvent := mba:getCurrentEvent($mba)
 
 let $insert :=  <xes:event>
 <xes:date key="time:timestamp"
value="{$time}"/>

{
  <xes:string key="sc:state" value="{$von/@id}"/>
  ,
 if( $transType = 'external' or 'internal' ) then
   <xes:string key="concept:name" value="{$currentEvent/name}"/>
 else
 (), 
  if( $transType = 'external' or 'internal' ) then
    <xes:string key="sc:event" value="{$event}"/>
 else
 (), 
 if(not(fn:empty($to))) then 
 <xes:string key="sc:target" value="{$to/@id}"/>
 else
 (),
   if(not(fn:empty($cond))) then 
 <xes:string key="sc:cond" value="{$cond}"/>
 else
 ()
}

 </xes:event>

return $insert
else

let $scxml := mba:getSCXML($mba)
let $states := 
sc:getInitialStates($scxml)


let $insert :=

for $s in $states
return 
  <xes:event>
 <xes:date key="time:timestamp"
value="{$time}"/>

{
  if($transType = 'init') then 
  <xes:string key="sc:inital" value="{$scxml/@name}"/>
  else
  ()
  ,
 <xes:string key="sc:target" value="{$s/@id}"/>

}

 </xes:event>

return $insert


 return
 insert node $insert
  into $log
 
};



declare updating function sc:runExecutableContent($dbName as xs:string, $collectionName as xs:string, $mbaName as xs:string, $content)
{
    let $mba := mba:getMBA($dbName, $collectionName, $mbaName)
    let $scxml := mba:getSCXML($mba)

    let $configuration := mba:getConfiguration($mba)
    let $dataModels := mba:selectAllDataModels($mba)
    let $counter :=
        if (fn:empty(mba:getCurrentEvent($mba)/data/id/text())) then
            mba:getCounter($mba) - 1
        else
            mba:getCurrentEvent($mba)/data/id/text()
    return
        typeswitch ($content)
            case element(sc:assign) return
                if ((not(fn:empty($dataModels/sc:data[@id = substring(functx:substring-before-if-contains($content/@location, '/'), 2)])) and
                        not($content/@location = '$_sessionid' or $content/@location = '$_name' or
                                $content/@location = '$_sessionid' or $content/@location = '$_ioprocessors' or $content/@location = '$_event'))) then
                    sc:assign($dataModels, $content/@location, $content/@expr, $content/@type, $content/@attr, $content/*, $dbName, $collectionName, $mbaName)
                else
                    let $event := <event name="error.execution" type="platform" xmlns=""></event>
                    return mba:enqueueInternalEvent($mba, $event)
            case element(sync:assignAncestor) return
                sync:assignAncestor($mba, $content/@location, $content/@expr, $content/@type, $content/@attr, $content/*, $content/@level)
            case element(sync:sendAncestor) return
                sync:sendAncestor($mba, $content/@event, $content/@level, $content/sc:param, $content/sc:content)
            case element(sync:assignDescendants) return
                sync:assignDescendants($mba, $content/@location, $content/@expr, $content/@type, $content/@attr, $content/*, $content/@level, $content/@inState, $content/@satisfying)
            case element(sync:sendDescendants) return
                sync:sendDescendants($mba, $content/@event, $content/@level, $content/@inState, $content/@satisfying, $content/sc:param, $content/sc:content)
            case element(sync:newDescendant) return
                sync:newDescendant($mba, $content/@name, $content/@level, $content/@parents, $content/*) 
            case element(sc:getValue) return
                sc:getValue($dataModels, $content/@location, $content/@expr, $content/@type, $content/@attr, $content/*, $counter)
            case element(sc:log) return
                sc:log($dataModels, $content/@expr, $content/@label, $content/*, $counter, $dbName, $collectionName, $mbaName)
            case element(sc:raise) return
                let $event := <event name="{$content/@event}" type="internal" xmlns=""></event>
                return mba:enqueueInternalEvent($mba, $event)
            case element(sc:script) return
                () (:not implemented:)
            case element(sc:send) return
                let $eventtext :=
                    if (fn:empty($content/@event)) then
                        if (fn:empty($content/@eventexpr)) then
                            ()
                        else
                            sc:evalWithError($content/@eventexpr, $dataModels)
                    else
                        $content/@event
                let $location :=
                    if (fn:empty($content/@target)) then
                        if (fn:empty($content/@targetexpr)) then
                            ()
                        else
                            sc:evalWithError($content/@targetexpr, $dataModels)
                    else
                        $content/@target

                let $origintype := if (fn:empty($content/@type)) then
                    if (fn:empty($content/@typexpr)) then
                        ('http://www.w3.org/TR/scxml/#SCXMLEventProcessor')
                    else
                        sc:evalWithError($content/@targetexpr, $dataModels)
                else
                    $content/@type

                let $supportsType :=
                    if (   functx:is-value-in-sequence($content/@type, sc:evalWithError('$_ioprocessors/processor/@name', $dataModels)) or fn:empty($content/@type)) then
                        fn:true()
                    else
                        'err:Special'

                let $params :=
                    for $p in $content/sc:param
                    return
                        <data id="{$p/@name}">{sc:evalWithError($p/@expr, $dataModels)}</data>

                let $namelist := $content/@namelist
                let $namelistData :=
                    for $n in fn:tokenize($namelist, '\s')
                    return
                        (<data id="{functx:substring-after-if-contains($n, '$')}">{sc:evalWithError($n, $dataModels)}</data>)

                let $idlocation := (
                    if (fn:empty($content/@idlocation)) then
                        if (fn:empty($content/@id)) then
                            ()
                        else ($content/@id)
                    else
                        fn:generate-id($content))


                let $idContent :=
                    <sc:assign location="{$content/@idlocation}"  expr="'{$idlocation}'"> </sc:assign>

                let $error :=

                    if (fn:matches(fn:string($location), '^err:')
                            or fn:matches(fn:string($origintype), '^err:')
                            or
                            (some $p in $params
                            satisfies fn:matches(fn:string($p), '^err:'))
                            or fn:matches(fn:string($supportsType), '^err:')) then
                        fn:true()
                    else
                        fn:false()


                let $origin := 'mba:' || $dbName || ',' || $collectionName || ',' || $mbaName
                let $eventbody := ($params, $content/sc:content/text(), $namelistData)

                return

                    (
                        if (fn:empty($content/@idlocation)) then ()
                        else
                            (
                                sc:runExecutableContent(mba:getDatabaseName($mba), mba:getCollectionName($mba), $mba/@name, $idContent)
                            )
                        ,

                        if ($error) then
                            (
                                let $event := <event name="error.execution.send" sendid="{$idlocation}" type="platform" xmlns=""></event>
                                return mba:enqueueInternalEvent($mba, $event)
                            )
                        else
                            (
                                if (not($location)) then

                                    let $event := <event name="{$eventtext}" type="external" sendid="{$idlocation}" origintype="{$origintype}" origin="{$origin}" xmlns=""> {$eventbody}</event>
                                    return mba:enqueueExternalEvent($mba, $event)

                                else if ($location = '#_internal') then

                                    (    let $event := <event name="{$eventtext}" type="external" sendid="{$idlocation}" origintype="{$origintype}"  origin="{$origin}"  xmlns=""> {$eventbody}</event>
                                    return
                                        mba:enqueueInternalEvent($mba, $event)
                                    )
                                else if ($location = '#_parent') then
                                        (

                                            let $parentmba := sc:getMBAFromText(mba:getParentInvoke($mba)/parent)

                                            let $event := <event name="{$eventtext}" sendid="{$idlocation}" invokeid="{mba:getParentInvoke($mba)/id}" type="external" origintype="{$origintype}"  origin="{$origin}"  xmlns=""> {$eventbody}</event>
                                            return mba:enqueueExternalEvent($parentmba, $event)
                                        )

                                    else if (fn:matches($location, '#_scxml_')) then
                                            (
                                                let $sendMba := sc:getMBAFromText($location)
                                                let $event := <event name="{$eventtext}" sendid="{$idlocation}" invokeid="{mba:getParentInvoke($mba)/id}" type="external" origintype="{$origintype}"   origin="{$origin}"  xmlns=""> {$eventbody}</event>
                                                return (mba:enqueueExternalEvent($sendMba, $event))
                                            )

                                        else if (fn:matches($location, '#_')) then
                                                (
                                                    let $sendMba := sc:getMBAFromText(mba:getChildInvokeQueue($mba)/*[@id = fn:substring($location, 3)]/text())
                                                    let $event := <event name="{$eventtext}" sendid="{$idlocation}" invokeid="{mba:getParentInvoke($mba)/id}" type="external" origintype="{$origintype}"  origin="{$origin}"  xmlns="" > {$eventbody}</event>
                                                    return (mba:enqueueExternalEvent($sendMba, $event))
                                                )
                                            else
                                                (

                                                    let $sendMba := sc:getMBAFromText($location)
                                                    return

                                                        if ((fn:matches(fn:string($sendMba), '^err:')) or (fn:matches(fn:string($sendMba), '^bxerr:'))) then
                                                            (
                                                                let $event := <event name="error.communication.send" sendid="{$idlocation}" type="platform" xmlns=""></event>
                                                                return (mba:enqueueInternalEvent($mba, $event)))
                                                        else

                                                            let $event := <event name="{$eventtext}"  sendid="{$idlocation}" invokeid="{mba:getParentInvoke($mba)/id}" type="external" origintype="{$origintype}"   origin="{$origin}"  xmlns=""> {$eventbody}</event>
                                                            return (mba:enqueueExternalEvent($sendMba, $event)))
                            )


                    )
            case element(sc:cancel) return
                () (: TODO: has to be implementent:)
            case element(sc:if) return

                let $ifcontent :=
                    if (sc:evaluateCond($content/@cond, $dataModels)) then
                        let $til :=
                            if (fn:empty($content/sc:elseif)) then
                                $content/sc:else
                            else $content/sc:elseif

                        let $index :=
                            try
                            {
                                functx:index-of-node($content/*, $til)
                            }
                            catch *
                            {

                                fn:count($content/*) + 1
                            }
                        return $content/*[fn:position() < $index]
                    else
                    (: finde das erste elseif das ok ist. :)
                        let $elseifs := $content/*[self::sc:elseif and sc:evaluateCond(./@cond, $dataModels)][1]
                        return
                            if (not(fn:empty($elseifs))) then

                                let $til := $elseifs/following-sibling::node()[(self::sc:elseif or self::sc:else)][1]
                                let $index := functx:index-of-node($elseifs/following-sibling::node(), $til)
                                return
                                    $elseifs/following-sibling::node()[fn:position() < $index]

                            else
                                $content/*[self::sc:else]/following-sibling::node()
                for $c in $ifcontent
                return sc:runExecutableContent($dbName, $collectionName, $mbaName, $c)

            case element(sc:foreach) return
                ()
        (: TODO: is not supported:)

            default return ()
};



declare updating function sc:invokeStates($mba)
{
    let $scxml := mba:getSCXML($mba)

    let $configuration := mba:getConfiguration($mba)
    let $dataModels := mba:selectDataModels($configuration)


    let $states := mba:getStatesToInvoke($mba)


    for $s in $states

    for $stateInvoke in $s/sc:invoke


    let $type := if (fn:empty($stateInvoke/@type)) then
        if (fn:empty($stateInvoke/@typeexpr)) then
            ()
        else
            sc:evalWithError($stateInvoke/@typeexpr, $dataModels)
    else
        $stateInvoke/@type


    let $src := if (fn:empty($stateInvoke/@src)) then
        if (fn:empty($stateInvoke/@srcexpr)) then
            ()
        else
            sc:evalWithError($stateInvoke/@srcexpr, $dataModels)
    else
        $stateInvoke/@src


    let $id := if (fn:empty($stateInvoke/@id)) then
        ()
    else $stateInvoke/@id/data()


    let $generateId :=


        $s/@id || '.' || fn:generate-id($stateInvoke)


    let $idInsert :=
        if (fn:empty($id)) then
            $generateId
        else
            $id


    let $autoforwards := $stateInvoke/@autoforward


    let $content :=
        if (fn:empty($src)) then
            $stateInvoke/sc:content/*
        else
            if (fn:substring-before($src, ':') = 'file') then
                fn:doc($src)
            else
                $src


    let $content :=
        if (fn:empty($src)) then
            if (fn:empty($stateInvoke/sc:content/@expr)) then
                $stateInvoke/sc:content/*
            else
                (

                    sc:evalWithError(($stateInvoke/sc:content/@expr), $dataModels))

        else
            if (fn:substring-before($src, ':') = 'file') then
                fn:doc(fn:substring-after($src, ':'))
            else
                $src


    let $param := $stateInvoke/sc:param

    let $namelist := $stateInvoke/@namelist

    let $namelistData :=
        for $n in fn:tokenize($namelist, '\s')
        return
            (<var xmlns="" name="{$n}">{sc:eval($n, $dataModels)}</var>)

    let $error :=
        some $n in $namelistData satisfies
        fn:matches($n/text(), '^err:')
                or not(fn:matches($namelist/data(), '\$'))

    return
        if ($error) then
            ()
        else
            (


                let $insertMBA :=
                    <mba xmlns="http://www.dke.jku.at/MBA" xmlns:sc="http://www.w3.org/2005/07/scxml" xmlns:sync="http://www.dke.jku.at/MBA/Synchronization" hierarchy="simple" name="invoke">
                        <topLevel name="invokeLevel">
                            <elements>


                                {$content}

                            </elements>
                        </topLevel>
                    </mba>


                let $insertMBA :=
                    copy $insertMBA := $insertMBA
                    modify
                    (
                        mba:init($insertMBA)
                    )
                    return $insertMBA

                let $insertMBA :=
                    if (not(fn:empty($param))) then
                        copy $insertMBA := $insertMBA
                        modify
                        (


                            let $dataModels := mba:selectAllDataModels($insertMBA)


                            for $p in $param
                            let $data := ($dataModels/sc:data[@id = $p/@name])

                            return if (fn:empty($data)) then
                                ()
                            else
                                (
                                    if (fn:empty($data/@expr)) then
                                        insert node (attribute {'expr'} {$p/@expr})   into $data
                                    else
                                        replace value of node $data/@expr with $p/@expr
                                )

                        )
                        return $insertMBA

                    else
                        $insertMBA


                let $insertMBA :=
                    if (not(fn:empty($namelistData))) then
                        copy $insertMBA := $insertMBA
                        modify
                        (


                            let $dataModels := mba:selectAllDataModels($insertMBA)

                            for $dat in $namelistData
                            let $data := if (fn:matches($dat/@name, '^\$'))
                            then
                                ($dataModels/sc:data[@id = substring($dat/@name, 2)])
                            else
                                ($dataModels/sc:data[@id = substring($dat/@name, 1)])

                            return if (fn:empty($data)) then
                                ()
                            else
                                (
                                    if (fn:empty($data/@expr)) then
                                        insert node (attribute {'expr'} {$dat/data()})   into $data
                                    else
                                        replace value of node $data/@expr with $dat/data()
                                )

                        )
                        return $insertMBA

                    else
                        $insertMBA


                let $insertMBA :=
                    copy $insertMBA := $insertMBA
                    modify
                    (
                        let $parentInvoke := mba:getParentInvoke($insertMBA)
                        let $mbaName := $mba/@name
                        let $collectionname := mba:getCollectionName($mba)
                        let $dbName := mba:getDatabaseName($mba)
                        let $text := 'mba:' || $dbName || ',' || $collectionname || ',' || $mbaName

                        return ( insert node <parent>{$text}</parent> into $parentInvoke,
                        insert node <id>{$idInsert}</id> into $parentInvoke)
                    )
                    return $insertMBA


                let $dbNameNew := 'invoke' || fn:generate-id($insertMBA)


                let $insertMBA :=
                    copy $insertMBA := $insertMBA
                    modify
                    (

                        let $dbSave := $insertMBA//*[@id = '_x']/db
                        let $text := 'mba:' || $dbNameNew || ',' || 'invoke' || ',' || 'invoke'
                        return
                            if (fn:empty($dbSave/text())) then
                                (insert node $dbNameNew into $dbSave,
                                replace node $insertMBA//*[@id = '_sessionid']  with
                                <sc:data id="_sessionid">{$text}</sc:data>)
                            else
                                ()
                    )
                    return $insertMBA

                return


                    if ($type = 'http://www.w3.org/TR/scxml/' or $type = 'http://www.w3.org/TR/scxml' or $type = 'scxml' or fn:empty($type))
                    then


                        if ($insertMBA/@hierarchy = 'simple') then

                            let $collectionName := $insertMBA/@name
                            let $fileName := 'collections/' || $collectionName || '.xml'
                            let $collectionEntry :=


                                <mba:collection name='{$collectionName}' file="{$fileName}" hierarchy="simple">
                                    <mba:new> <mba:mba ref="{$insertMBA/@name}"/>
                                    </mba:new>
                                    <mba:updated/>
                                </mba:collection>
                            let $documenttest :=
                                <mba:collections>{$collectionEntry} </mba:collections>


                            return (
                                db:create($dbNameNew, ($insertMBA, $documenttest), ( $fileName, 'collections.xml')),
                                (if (fn:empty($stateInvoke/@idlocation)) then ()
                                else
                                    (
                                        let $content := <sc:assign location="{$stateInvoke/@idlocation}"  expr="'{$generateId}'"> </sc:assign>

                                        return sc:runExecutableContent(mba:getDatabaseName($mba), mba:getCollectionName($mba), $mba/@name, $content)


                                    )),
                                mba:updatechildInvoke($mba, $s, $dbNameNew, 'invoke', 'invoke', $idInsert)
                            )

                        else
                            ()
                    else
                        ()

            )

};


(:(:<xs:transition> {$transition}</xs:transition>
  <xs:test> {$von/@id}</xs:test>
   <xs:test> {$to/@id}</xs:test>
  <xs:test> {$toN}</xs:test> :):)




