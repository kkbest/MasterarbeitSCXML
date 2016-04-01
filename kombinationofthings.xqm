module namespace kk = 'http://www.w3.org/2005/07/kk';
import module namespace scx = 'http://www.w3.org/2005/07/scxml/extension/';
import module namespace functx = 'http://www.functx.com';
import module namespace mba = 'http://www.dke.jku.at/MBA';
import module namespace sc = 'http://www.w3.org/2005/07/scxml';
import module namespace sync = 'http://www.dke.jku.at/MBA/Synchronization';


declare updating function kk:initMBARest($dbName, $collectionName, $mbaName as xs:string)
{

    let $mba := mba:getMBA($dbName, $collectionName, $mbaName)
    let $scxml := mba:getSCXML($mba)
    return
        mba:init($mba), kk:removeFromUpdateLog($dbName, $collectionName, $mbaName)
};


declare updating function kk:initSCXMLRest($dbName, $collectionName, $mbaName as xs:string)
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


declare updating function kk:updateRunning($dbName, $collectionName, $mbaName as xs:string)
{
    let $mba := mba:getMBA($dbName, $collectionName, $mbaName)
    let $currentEvent := mba:getCurrentEvent($mba)

    return
        (
            if (
                $currentEvent/type = 'cancel') then
                mba:updateRunning($mba, fn:false())
            else
                ())

};


declare updating function kk:autoForward($dbName, $collectionName, $mbaName as xs:string, $s)
{

    let $mba := mba:getMBA($dbName, $collectionName, $mbaName)
    let $configuration := mba:getConfiguration($mba)
    let $currentEvent := mba:getCurrentEvent($mba)
    let $dataModel := sc:selectAllDataModels($mba)
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

                let $insertMba := kk:getMBAFromText(mba:getChildInvokeQueue($mba)/*[@ref = $s/@id]/text())
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


declare updating function kk:removeFromInsertLog($dbName, $collectionName, $mbaName)
{
    let $mba := mba:getMBA($dbName, $collectionName, $mbaName)
    return mba:removeFromInsertLog($mba)
};


declare updating function kk:markAsUpdated($dbName, $collectionName, $mbaName)
{
    let $mba := mba:getMBA($dbName, $collectionName, $mbaName)
    return mba:markAsUpdated($mba)
};


declare updating function kk:getNextExternalEvent($dbName, $collectionName, $mbaName)
{
    let $mba := mba:getMBA($dbName, $collectionName, $mbaName)
    return mba:loadNextExternalEvent($mba)
};


declare updating function kk:getNextInternalEvent($dbName, $collectionName, $mbaName)
{
    let $mba := mba:getMBA($dbName, $collectionName, $mbaName)
    return mba:loadNextInternalEvent($mba)
};


declare function kk:getExecutableContentsExit($dbName, $collectionName, $mbaName, $state)
{
    for $s in $state
    return $s/sc:onexit/reverse(*)
};


declare function kk:getExecutableContentsTransitions($dbName, $collectionName, $mbaName)
{
    let $mba := mba:getMBA($dbName, $collectionName, $mbaName)
    let $transitions := mba:getCurrentTransitionsQueue($mba)/transitions/*
    let $contents :=
        for $t in $transitions
        return $t/*
    return ($contents)
};


declare updating function kk:runExecutableContent($dbName, $collectionName, $mbaName, $content)
{
    let $mba := mba:getMBA($dbName, $collectionName, $mbaName)
    let $scxml := mba:getSCXML($mba)

    let $configuration := mba:getConfiguration($mba)
    let $dataModels := sc:selectAllDataModels($mba)
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
                                kk:runExecutableContent(mba:getDatabaseName($mba), mba:getCollectionName($mba), $mba/@name, $idContent)
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

                                            let $parentmba := kk:getMBAFromText(mba:getParentInvoke($mba)/parent)

                                            let $event := <event name="{$eventtext}" sendid="{$idlocation}" invokeid="{mba:getParentInvoke($mba)/id}" type="external" origintype="{$origintype}"  origin="{$origin}"  xmlns=""> {$eventbody}</event>
                                            return mba:enqueueExternalEvent($parentmba, $event)
                                        )

                                    else if (fn:matches($location, '#_scxml_')) then
                                            (
                                                let $sendMba := kk:getMBAFromText($location)
                                                let $event := <event name="{$eventtext}" sendid="{$idlocation}" invokeid="{mba:getParentInvoke($mba)/id}" type="external" origintype="{$origintype}"   origin="{$origin}"  xmlns=""> {$eventbody}</event>
                                                return (mba:enqueueExternalEvent($sendMba, $event))
                                            )

                                        else if (fn:matches($location, '#_')) then
                                                (
                                                    let $sendMba := kk:getMBAFromText(mba:getChildInvokeQueue($mba)/*[@id = fn:substring($location, 3)]/text())
                                                    let $event := <event name="{$eventtext}" sendid="{$idlocation}" invokeid="{mba:getParentInvoke($mba)/id}" type="external" origintype="{$origintype}"  origin="{$origin}"  xmlns="" > {$eventbody}</event>
                                                    return (mba:enqueueExternalEvent($sendMba, $event))
                                                )
                                            else
                                                (

                                                    let $sendMba := kk:getMBAFromText($location)
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
                return kk:runExecutableContent($dbName, $collectionName, $mbaName, $c)

            case element(sc:foreach) return
                ()
        (: TODO: is not supported:)

            default return ()
};



declare function kk:getExecutableContentsEnter($dbName, $collectionName, $mbaName, $state, $historyContent)
{
    let $mba := mba:getMBA($dbName, $collectionName, $mbaName)
    let $scxml := mba:getSCXML($mba)

    let $configuration := mba:getConfiguration($mba)
    let $dataModels := sc:selectDataModels($configuration)


    let $transitions :=
        mba:getCurrentTransitionsQueue($mba)/transitions/*


    let $content1 :=

        ($state/sc:onentry/*, $state/sc:initial/sc:transition/*)


    let $content2 :=

        $historyContent


    return ($content1, $content2)
};


declare updating function kk:executeExecutablecontent($dbName, $collectionName, $mbaName, $content, $counter)
{
    kk:runExecutableContent($dbName, $collectionName, $mbaName, $content[$counter])
};


declare updating function kk:removeFromUpdateLog($dbName, $collectionName, $mbaName)
{

    let $mba := mba:getMBA($dbName, $collectionName, $mbaName)
    return mba:removeFromUpdateLog($mba)
};


declare function kk:getcurrentExternalEvent($mba)
{
    let $queue := mba:getExternalEventQueue($mba)
    let $nextEvent := ($queue/event)[1]
    let $nextEventName := <name xmlns="">{fn:string($nextEvent/@name)}</name>
    let $nextEventData := <data xmlns="">{$nextEvent/*}</data>
    let $currentEvent := mba:getCurrentEvent($mba)
    return $currentEvent
};




declare function kk:getResult($dbName, $collectionName, $mbaName, $id)
{


    let $mba := mba:getMBA($dbName, $collectionName, $mbaName)
    return $mba/mba:topLevel/mba:elements/sc:scxml/sc:datamodel/sc:data[@id = '_x']/response/response[@ref = $id]

};


declare function kk:getCounter($dbName, $collectionName, $mbaName)
{
    let $mba := mba:getMBA($dbName, $collectionName, $mbaName)
    return $mba/*/*/sc:scxml/sc:datamodel/sc:data[@id = '_x']/response/counter/text()
};


declare updating function kk:updateCounter($dbName, $collectionName, $mbaName)
{

    let $mba := mba:getMBA($dbName, $collectionName, $mbaName)
    let $oldValue := $mba/*/*/sc:scxml/sc:datamodel/sc:data[@id = '_x']/response/counter/text()
    let $newCounter := <counter>{$oldValue + 1}</counter>
    return replace value of node $mba/*/*/sc:scxml/sc:datamodel/sc:data[@id = '_x']/response/counter with $newCounter
};


declare updating function kk:exitStatesSingle($dbName, $collectionName, $mbaName, $stateToExit, $type)
{


    let $mba := mba:getMBA($dbName, $collectionName, $mbaName)
    let $scxml := mba:getSCXML($mba)


    let $configuration := mba:getConfiguration($mba)
    let $dataModels := sc:selectDataModels($configuration)


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

                        (:for $h in kk:getStateHistoryNodes($state):)
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


                    let $insertMba := kk:getMBAFromText($src)
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


declare updating function kk:enterStatesSingle($dbName, $collectionName, $mbaName, $state as element())
{


    let $mba := mba:getMBA($dbName, $collectionName, $mbaName)
    let $scxml := mba:getSCXML($mba)

    let $currentEvent := mba:getCurrentEvent($mba)
    let $eventName := $currentEvent/name

    let $configuration := mba:getConfiguration($mba)
    let $dataModels := sc:selectDataModels($configuration)


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
                                    (mba:enqueueInternalEvent($mba, $eventError), mba:enqueueInternalEvent($mba, $event), mba:enqueueInternalEvent($mba, $parallelEvent), mba:addstatesToInvoke($mba, $state), kk:initDatamodel($state, $mba), mba:addCurrentStates($mba, $state))

                                else

                                    (mba:enqueueInternalEvent($mba, $event), mba:enqueueInternalEvent($mba, $parallelEvent), mba:addstatesToInvoke($mba, $state), kk:initDatamodel($state, $mba), mba:addCurrentStates($mba, $state))


                        else
                            if ($error or $errorParams) then
                                (mba:enqueueInternalEvent($mba, $eventError), mba:enqueueInternalEvent($mba, $event), mba:addstatesToInvoke($mba, $state), kk:initDatamodel($state, $mba), mba:addCurrentStates($mba, $state))
                            else
                                (mba:enqueueInternalEvent($mba, $event), mba:addstatesToInvoke($mba, $state), kk:initDatamodel($state, $mba), mba:addCurrentStates($mba, $state))

                    else
                        if ($error or $errorParams) then

                            (mba:enqueueInternalEvent($mba, $eventError), mba:enqueueInternalEvent($mba, $event), mba:addstatesToInvoke($mba, $state), kk:initDatamodel($state, $mba), mba:addCurrentStates($mba, $state))
                        else
                            (   mba:enqueueInternalEvent($mba, $event), mba:addstatesToInvoke($mba, $state), kk:initDatamodel($state, $mba), mba:addCurrentStates($mba, $state))

            else

                ( (:TODO set running to false:)

                mba:updateRunning($mba, fn:false()), mba:addstatesToInvoke($mba, $state), kk:initDatamodel($state, $mba), mba:addCurrentStates($mba, $state))
        else
            ( mba:addstatesToInvoke($mba, $state), kk:initDatamodel($state, $mba), mba:addCurrentStates($mba, $state))

};


declare updating function kk:exitInterpreter($dbName, $collectionName, $mbaName)

{let $mba := mba:getMBA($dbName, $collectionName, $mbaName)

let $states := mba:getStatesToInvokeQueue($mba)


let $configuration := mba:getConfiguration($mba)

for $s in $configuration

return (: runExitcontent , cancelInvoke, :)
    if (sc:isFinalState($s) and not(fn:empty($s/parent::*[self::sc:scxml]))) then
        let $invokeid := mba:getParentInvoke($mba)/id
        let $name := 'done.invoke' || $invokeid

        let $event := <event invokeid="{$invokeid}"  name="{$name}"></event>

        let $src := mba:getParentInvoke($mba)/parent

        let $insertMba := kk:getMBAFromText($src)


        return (mba:enqueueExternalEvent($insertMba, $event))

    else
        ()

};


declare updating function kk:initDatamodel($states, $mba)
{

    let $scxml := mba:getSCXML($mba)
    let $configuration := mba:getConfiguration($mba)
    let $dataModels := sc:selectDataModels($configuration)

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

declare function kk:getMBAFromText($src as xs:string)
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


declare updating function kk:invokeStateswithNewDb($mba)
{
    let $scxml := mba:getSCXML($mba)

    let $configuration := mba:getConfiguration($mba)
    let $dataModels := sc:selectDataModels($configuration)


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
                        <topLevel name="university">
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


                            let $dataModels := sc:selectAllDataModels($insertMBA)


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


                            let $dataModels := sc:selectAllDataModels($insertMBA)

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

                                        return kk:runExecutableContent(mba:getDatabaseName($mba), mba:getCollectionName($mba), $mba/@name, $content)


                                    )),
                                mba:updatechildInvoke($mba, $s, $dbNameNew, 'invoke', 'invoke', $idInsert)
                            )

                        else
                            ()
                    else
                        ()

            )

};
