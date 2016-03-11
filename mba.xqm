(:~

 : --------------------------------
 : MBAse: An MBA database in XQuery
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
  
 : This module provides basic functionality for the management of
 : databases for multilevel business artifacts (MBAs). 
 
 : @author Christoph Schütz
 :)
module namespace mba='http://www.dke.jku.at/MBA';

import module namespace functx = 'http://www.functx.com';

import module namespace sc='http://www.w3.org/2005/07/scxml';

declare updating function mba:createMBAse($newDb as xs:string) {
  let $dbDimSchemaFileName := 'xsd/collections.xsd'
  let $dbDimFileName       := 'collections.xml'
  
  let $dbDimSchema :=
    <xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema" 
               xmlns:mba="http://www.dke.jku.at/MBA" 
               targetNamespace="http://www.dke.jku.at/MBA"
               elementFormDefault="qualified" 
               attributeFormDefault="unqualified">
      <xs:element name="collections">
        <xs:complexType>
          <xs:sequence>
            <xs:element name="collection" minOccurs="0" maxOccurs="unbounded">
              <xs:complexType>
                <xs:attribute name="name"      type="xs:string"     use="required"/>
                <xs:attribute name="file"      type="xs:string"     use="required"/>
                <xs:attribute name="hierarchy" type="hierarchyType" use="optional" default="complex"/>
              </xs:complexType>
            </xs:element>
          </xs:sequence>
        </xs:complexType>
        <xs:key name="keyCollectionName">
          <xs:selector xpath="mba:collection"/>
          <xs:field xpath="@name"/>
        </xs:key>
        <xs:key name="keyCollectionName">
          <xs:selector xpath="mba:collection"/>
          <xs:field xpath="@file"/>
        </xs:key>
      </xs:element>
      <xs:simpleType name="hierarchyType">
        <xs:restriction base="xs:string">
          <xs:enumeration value="simple"/>
          <xs:enumeration value="complex"/>
        </xs:restriction>
      </xs:simpleType>
    </xs:schema>
    
  let $dbDimContent := 
    <collections 
      xmlns="http://www.dke.jku.at/MBA" 
      xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
      xsi:schemaLocation="http://www.dke.jku.at/MBA {$dbDimSchemaFileName}"/>
  
  let $mbaSchemaSimple :=
    <xs:schema xmlns="http://www.dke.jku.at/MBA" 
               xmlns:mba="http://www.dke.jku.at/MBA" 
               xmlns:sc="http://www.w3.org/2005/07/scxml"
               xmlns:xs="http://www.w3.org/2001/XMLSchema" 
               targetNamespace="http://www.dke.jku.at/MBA" 
               elementFormDefault="qualified" 
               attributeFormDefault="unqualified">
      <xs:element name="mba">
        <xs:complexType>
          <xs:attribute name="name"      type="xs:string"     use="required"/>
          <xs:attribute name="hierarchy" type="hierarchyType" use="required" default="simple"/>
          <xs:sequence>
            <xs:element name="topLevel" minOccurs="1" maxOccurs="1">
              <xs:complexType>
              </xs:complexType>
            </xs:element>
          </xs:sequence>
        </xs:complexType>
      </xs:element>
      <xs:simpleType name="hierarchyType">
        <xs:restriction base="xs:string">
          <xs:enumeration value="simple"/>
        </xs:restriction>
      </xs:simpleType>
    </xs:schema>
  
  let $mbaSchemaFileNameSimple := 'xsd/mba_simple.xsd'
  
  
  return db:create(
    $newDb,
    ($dbDimSchema, $mbaSchemaSimple, $dbDimContent), 
    ($dbDimSchemaFileName, $mbaSchemaFileNameSimple, $dbDimFileName)
  )
};

(:~
 : Insert an MBA with a simple hierarchy as a new collection into the database.
 :
 : @param $db the name of the database.
 : @param $mba an MBA with a simple level hierarchy. 
 :)
declare updating function mba:insertAsCollection($db as xs:string,
                                                 $mba as element()) {
  if($mba/@hierarchy = 'simple') then 
    let $document        := db:open($db, 'collections.xml')
    let $collectionName  := $mba/@name
    let $fileName        := 'collections/' || $collectionName || '.xml'
    let $collectionEntry :=
      <collection name='{$collectionName}' file="{$fileName}" hierarchy="simple">
        <new/>
        <updated/>
      </collection>
    
    return (
      db:add($db, $mba, $fileName),
      insert node $collectionEntry into $document/mba:collections
    )
  else () (: can only insert MBAs with simple hierarchy as collection :)
};

declare function mba:concretize($parents  as element()*,
                                $name     as xs:string,
                                $topLevel as xs:string) as element() {
  let $parent := $parents[1]
  
  let $level := $parent/mba:topLevel//mba:childLevel[@name = $topLevel]
  
  let $concretization :=
    <mba:mba name="{$name}" hierarchy="simple">
      <mba:topLevel name="{$topLevel}">
        {$level/*}
      </mba:topLevel>
      <mba:concretizations/>
    </mba:mba>
  
  let $concretization := copy $c := $concretization modify (
    if (not ($c/mba:topLevel/mba:elements/sc:scxml[1]/sc:datamodel/sc:data[@id = '_event'])) then
      insert node <sc:data id = "_event"/> into $c/mba:topLevel/mba:elements/sc:scxml[1]/sc:datamodel
    else (),
    if (not ($c/mba:topLevel/mba:elements/sc:scxml[1]/sc:datamodel/sc:data[@id = '_x'])) then
      insert node 
        <sc:data id = "_x">
          <db xmlns="">{mba:getDatabaseName($parent)}</db>
          <collection xmlns="">{mba:getCollectionName($parent)}</collection>
          <name xmlns="">{$name}</name>
          <currentStatus xmlns=""/>
          <externalEventQueue xmlns=""/>
          <internalEventQueue xmlns=""/>
          <currentEntrySet xmlns=""/>
          <currentExitSet xmlns=""/>
          <currentTransitions xmlns=""/>
          <statesToInvoke xmlns=""/>
          <response  xmlns="">
               <counter xmlns="">1</counter>
           </response>
          <historyStates xmlns=""/>
        </sc:data>
      into $c/mba:topLevel/mba:elements/sc:scxml[1]/sc:datamodel
    else ()
  ) return $c
  
  return $concretization
};

declare function mba:getMBA($db             as xs:string,
                            $collectionName as xs:string,
                            $mbaName        as xs:string) {
  let $collection :=
    db:open($db, 'collections.xml')/mba:collections/mba:collection
    [@name=$collectionName]
  
  let $document := db:open($db, $collection/@file)
  let $mba := 
    if($collection/@hierarchy = 'simple') then
      $document/descendant-or-self::mba:mba[@name = $mbaName]
    else ()
  
  return $mba
};

declare function mba:getCollection($db             as xs:string,
                                   $collectionName as xs:string) {
  let $collection :=
    db:open($db, 'collections.xml')/mba:collections/mba:collection
    [@name=$collectionName]
  
  let $document := db:open($db, $collection/@file)
  
  return $document
};

declare function mba:getTopLevelName($mba as element()) as xs:string { 
  if($mba/@hierarchy = 'simple') then $mba/mba:topLevel/@name else ()
};

declare function mba:getElementsAtLevel($mba       as element(),
                                        $levelName as xs:string) as element()* { 
  let $level :=
    if($mba/@hierarchy = 'simple') then 
      ($mba/mba:topLevel[@name = $levelName],
       $mba/mba:topLevel//mba:childLevel[@name = $levelName])
    else ()
  
  return $level/mba:elements
};

declare function mba:getSCXML($mba as element()) as element() {
  let $levelName := mba:getTopLevelName($mba)
  let $elements  := mba:getElementsAtLevel($mba, $levelName)
  
  let $scxml :=
    if($elements/@activeVariant) then 
      $elements/sc:scxml[@name = $elements/@activeVariant]
    else $elements/sc:scxml[1]
  
  return $scxml
};

declare updating function mba:addSCXML($mba       as element(),
                                       $levelName as xs:string,
                                       $scxml     as element()) {
  let $elements := mba:getElementsAtLevel($mba, $levelName)
  
  return
    if(not($elements/sc:scxml[@name = $scxml/@name])) then
      insert node $scxml into $elements
    else ()
};

declare updating function mba:removeSCXML($mba       as element(),
                                          $levelName as xs:string,
                                          $scxmlName as xs:string) {
  let $elements := mba:getElementsAtLevel($mba, $levelName)
  
  return
    delete node $elements/sc:scxml[@name = $scxmlName]
};

declare updating function mba:insertLevel($mba             as element(),
                                          $levelName       as xs:string,
                                          $parentLevelName as xs:string,
                                          $childLevelName  as xs:string?) {
  let $parentLevel := $mba/mba:topLevel[@name = $parentLevelName]
  let $parentLevel :=
    if ($parentLevel) then $parentLevel
    else $mba/mba:topLevel//mba:childLevel[@name = $parentLevelName]
  
  let $childLevel := if ($childLevelName) 
    then $mba/mba:topLevel//mba:childLevel[@name = $childLevelName] else ()
  
  let $newLevel :=
    <mba:childLevel name="{$levelName}">
      {$childLevel}
    </mba:childLevel>
  
  return insert node $newLevel into $parentLevel
};

declare function mba:getAncestorAtLevel($mba   as element(),
                                        $level as xs:string) as element() {
  if($mba/@hierarchy = 'simple') then
    $mba/ancestor::mba:mba[./mba:topLevel/@name = $level]
  else ()
};

declare function mba:getAncestors($mba   as element()) as element() {
  if($mba/@hierarchy = 'simple') then
    $mba/ancestor::mba:mba
  else ()
};

declare function mba:getDescendants($mba as element()) as element()* {
  if($mba/@hierarchy = 'simple') then
    $mba/descendant::mba:mba
  else ()
};

declare function mba:getDescendantsAtLevel($mba   as element(),
                                           $level as xs:string) as element()* {
  if($mba/@hierarchy = 'simple') then
    $mba/descendant::mba:mba[./mba:topLevel/@name = $level]
  else ()
};

declare function mba:isInState($mba     as element(),
                               $stateId as xs:string) as xs:boolean {
  let $currentStatus := mba:getCurrentStatus($mba)
  
  return fn:exists($currentStatus/state[@ref=$stateId])
};

declare function mba:getCurrentStatus($mba as element()) as element()* {
  let $scxml := mba:getSCXML($mba)
  let $_x := $scxml/sc:datamodel/sc:data[@id = '_x']
  let $currentStatus := if ($_x) then $_x/currentStatus
    else ()
  
  return $currentStatus
};




declare function mba:getRunning($mba as element()) as xs:boolean
{
  
   let $scxml := mba:getSCXML($mba)
  let $_x := $scxml/sc:datamodel/sc:data[@id = '_x']
   
   let $isRunning := if ($_x) then $_x/isRunning
    else ()
  
  return fn:boolean($isRunning)
  
};


declare updating function mba:updateRunning($mba as element(), $value as xs:boolean)
{
  let $running :=    
  let $scxml := mba:getSCXML($mba)
  return $scxml/sc:datamodel/sc:data[@id = '_x']/isRunning
 
  return replace node $running with <isRunning>{$value}</isRunning>
 
  
};

declare function mba:getConfiguration($mba as element()) as element()* {
  let $scxml := mba:getSCXML($mba)
  let $currentStatus := mba:getCurrentStatus($mba)
  
  return if ($currentStatus) then
    for $s in $currentStatus/*
      return typeswitch($s)
        case element(initial)
          return $scxml//sc:initial[./parent::sc:scxml/@name = $s/@state or
                                    ./parent::sc:state/@id = $s/@state]
        case element(state)
          return ($scxml//sc:state[$s/@ref = ./@id],$scxml//sc:final[$s/@ref = ./@id], $scxml//sc:parallel[$s/@ref = ./@id])
        default return ()
   else ()
};

declare updating function mba:addCurrentStates($mba    as element(),
                                               $states as element()*){
  let $currentStatus := mba:getCurrentStatus($mba)
  
  let $newStates := 
    for $state in 
        $states[not (some $s in $currentStatus/* satisfies $s/@ref = ./@id)]
      return <state xmlns="" ref="{$state/@id}"/>
  
  return insert nodes $newStates into $currentStatus
};

declare updating function mba:addCurrentState($mba   as element(),
                                              $state as element()){
  let $currentStatus := mba:getCurrentStatus($mba)
  
  let $newState := 
    <state xmlns="" ref="{$state/@id}"/> 
    
  return insert node $newState into $currentStatus
};

declare updating function mba:removeCurrentStates($mba    as element(),
                                                  $states as element()*){
  let $currentStatus := mba:getCurrentStatus($mba)
  
  let $removeStates := 
    for $s in $states
      return typeswitch($s)
        case element(sc:initial) return 
          typeswitch ($s/..)
            case element(sc:scxml) return 
              $currentStatus/initial[@state=$s/../@name]
            case element(sc:state) return 
                            $currentStatus/initial[@state=$s/../@id or @final=$s/../@id]
            default return ()
        case element(sc:state) return
          $currentStatus/state[@ref=$s/@id]
          
                   case element(sc:parallel)  return
        $currentStatus/state[@ref=$s/@id]  
        
        case element(sc:final)  return
        $currentStatus/state[@ref=$s/@id]  

        default return ()
    
  return delete nodes $removeStates
};

declare updating function mba:removeCurrentState($mba   as element(),
                                                 $state as element()){
  let $currentStatus := mba:getCurrentStatus($mba)
  
  return delete node $currentStatus/state[@ref=$state/@id]
};

declare function mba:getExternalEventQueue($mba as element()) as element() {
  let $scxml := mba:getSCXML($mba)
  
  return $scxml/sc:datamodel/sc:data[@id = '_x']/externalEventQueue
};

declare function mba:getInternalEventQueue($mba as element()) as element() {
  let $scxml := mba:getSCXML($mba)
  
  return $scxml/sc:datamodel/sc:data[@id = '_x']/internalEventQueue
};

declare function mba:getCurrentEntrySet($mba as element()) as node()* {
  let $scxml := mba:getSCXML($mba)
  
  for $ s  in $scxml/sc:datamodel/sc:data[@id = '_x']/currentEntrySet/*
  return $scxml//*[@id=$s/@ref]
};


declare function mba:getCurrentEntryQueue($mba as element()) as node()* {
  let $scxml := mba:getSCXML($mba)
  return $scxml/sc:datamodel/sc:data[@id = '_x']/currentEntrySet
};



declare function mba:getCurrentExitSet($mba as element()) as node()* {
  let $scxml := mba:getSCXML($mba)
  
  for $ s  in $scxml/sc:datamodel/sc:data[@id = '_x']/currentExitSet/*
  return $scxml//*[@id=$s/@ref]
};


declare function mba:getCurrentExitQueue($mba as element()) as node()* {
  let $scxml := mba:getSCXML($mba)
  return $scxml/sc:datamodel/sc:data[@id = '_x']/currentExitSet
};


declare function mba:getCurrentTransitionsQueue($mba as element()) as node()* {
  let $scxml := mba:getSCXML($mba)
  return $scxml/sc:datamodel/sc:data[@id = '_x']/currentTransitions
};


declare function mba:getChildInvokeQueue($mba as element()) as node()* {
  let $scxml := mba:getSCXML($mba)
  return $scxml/sc:datamodel/sc:data[@id = '_x']/childInvoke
};



declare function mba:getStatesToInvokeQueue($mba as element()) as node()* {
  let $scxml := mba:getSCXML($mba)
  return $scxml/sc:datamodel/sc:data[@id = '_x']/statesToInvoke
};

declare function mba:getStatesToInvoke($mba as element())
{
  
   let $queue := mba:getStatesToInvokeQueue($mba)/*
   
    for $s in $queue[1]/ancestor::sc:scxml//*[@id = $queue/@ref]
   return $s

};


declare updating function mba:deleteStatesToInvokeQueue($mba as element())
{
  
   let $queue := mba:getStatesToInvokeQueue($mba)/*
   
  return delete node $queue

};



declare function mba:getParentInvoke($mba as element()) as node()* {
  let $scxml := mba:getSCXML($mba)
  return $scxml/sc:datamodel/sc:data[@id = '_x']/parentInvoke
};


declare updating function mba:setParentInvoke($mba   as element(), 
                                                   $mbaparent as element()) {
  let $parentinvoke := mba:getParentInvoke($mba)
  
  
 
   
  let $mbaName :=  $mbaparent/@name
  let $collectionname := mba:getCollectionName($mbaparent)
  let $dbName := mba:getDatabaseName($mbaparent)
  
  let $text := 'mba:' ||$dbName || ',' || $collectionname ||',' ||$mbaName
  
  return (
    insert node <parent>{$text}</parent> into $parentinvoke,
    mba:markAsNew($mba)
  )
};


declare function mba:getHistory($mba as element()) {
  let $scxml := mba:getSCXML($mba)
  
  return if(fn:empty( $scxml/sc:datamodel/sc:data[@id = '_x']/historyStates)) then 
  ()
  else
  
   $scxml/sc:datamodel/sc:data[@id = '_x']/historyStates
};


declare updating function mba:enqueueExternalEvent($mba   as element(), 
                                                   $event as element()) {
  let $queue := mba:getExternalEventQueue($mba)
  
  return (
    insert node $event into $queue,
    mba:markAsUpdated($mba)
  )
};

declare updating function mba:enqueueInternalEvent($mba   as element(), 
                                                   $event as element()) {
  let $queue := mba:getInternalEventQueue($mba)
  
  return (
    insert node $event into $queue
  )
};


declare updating function mba:updatecurrentEntrySet($mba   as element(), 
                                                   $entrySet as element()*) {
  let $queue := mba:getCurrentEntryQueue($mba)
  
  let $entrySet := 
  for $s in $entrySet 
  return 
  <state ref="{$s/@id}"></state>
  return
    
    if (fn:empty($queue/*)) then
insert node $entrySet into $queue
else
 replace node $queue with <currentEntrySet xmlns="" > {$entrySet}</currentEntrySet>
};


declare updating function mba:updateCurrentExitSet($mba   as element(), 
                                                   $exitSet as element()*) {
  let $queue := mba:getCurrentExitQueue($mba)
  
  let $exitSet := 
  for $s in $exitSet 
  return 
  <state ref="{$s/@id}"></state>
  return
    
    if (fn:empty($queue/*)) then
insert node $exitSet into $queue
else
 replace node $queue with <currentExitSet xmlns="" > {$exitSet}</currentExitSet>
};




declare updating function mba:addstatesToInvoke($mba   as element(), 
                                                   $entrySet as element()*) {
  let $queue := mba:getStatesToInvokeQueue($mba)
  
  let $entrySet := 
  for $s in $entrySet 
  return 
  <state ref="{$s/@id}"></state>
  return
    

insert node $entrySet into $queue

};



declare updating function mba:removestatesToInvoke($mba   as element(), 
                                                   $exitSet as element()*) {
                                                     
  
  let $queue := mba:getStatesToInvokeQueue($mba)

  return delete node $queue/state[@ref=$exitSet/@id]


};



declare updating function mba:updatecurrentTransitions($mba   as element(), 
                                                   $transitions ) {
  let $queue := mba:getCurrentTransitionsQueue($mba)
  
return
    
    if (fn:empty($queue/*)) then
insert node $transitions into $queue
else
 replace node $queue with <currentTransitions xmlns="" > {$transitions}</currentTransitions>
};



declare updating function mba:updatechildInvoke($mba   as element(), 
                                                   $state, $dbName, $collectionName, $mbaName  ) {
  let $queue := mba:getChildInvokeQueue($mba)


 
 let $text := 'mba:' ||$dbName || ',' || $collectionName ||',' ||$mbaName
 
let $insert :=  <invoke ref="{$state/@id}">{$text}</invoke>


return
   
insert node $insert into $queue

};







declare function mba:getDatabaseName($mba) {
  let $dbName := db:name($mba)
  
  return $dbName
};

declare function mba:getCollectionName($mba) {
  let $dbName := mba:getDatabaseName($mba)
  let $path := db:path($mba)
  
  let $document := db:open($dbName, 'collections.xml')
    
  let $collectionName := 
    $document/mba:collections/mba:collection[@file = $path]/@name
  
  return fn:string($collectionName)
};

declare updating function mba:markAsUpdated($mba as element()) {
  let $dbName := mba:getDatabaseName($mba)
  let $collectionName := mba:getCollectionName($mba)
  
  let $document := db:open($dbName, 'collections.xml')
  let $collectionEntry := 
    $document/mba:collections/mba:collection[@name = $collectionName]
  
  return
    insert node <mba:mba ref="{$mba/@name}"/> into $collectionEntry/mba:updated
};

declare updating function mba:markAsNew($mba as element()) {
  let $dbName := mba:getDatabaseName($mba)
  let $collectionName := mba:getCollectionName($mba)
  
  let $document := db:open($dbName, 'collections.xml')
  let $collectionEntry := 
    $document/mba:collections/mba:collection[@name = $collectionName]
  
  return
    insert node <mba ref="{$mba/@name}"/> into $collectionEntry/mba:new
};

declare updating function mba:removeFromUpdateLog($mba as element()) {
  let $dbName := mba:getDatabaseName($mba)
  let $collectionName := mba:getCollectionName($mba)
  
  let $document := db:open($dbName, 'collections.xml')
  let $collectionEntry := 
    $document/mba:collections/mba:collection[@name = $collectionName]
  
  return
    delete node functx:first-node(
      $collectionEntry/mba:updated/mba:mba[@ref = $mba/@name]
    )
};

declare updating function mba:removeFromInsertLog($mba as element()) {
  let $dbName := mba:getDatabaseName($mba)
  let $collectionName := mba:getCollectionName($mba)
  
  let $document := db:open($dbName, 'collections.xml')
  let $collectionEntry := 
    $document/mba:collections/mba:collection[@name = $collectionName]
  
  return
    delete node functx:first-node(
      $collectionEntry/mba:new/mba:mba[@ref = $mba/@name]
    )
};

declare updating function mba:dequeueExternalEvent($mba as element()) {
  let $queue := mba:getExternalEventQueue($mba)
  
  return delete node ($queue/*)[1]
};

declare updating function mba:dequeueInternalEvent($mba as element()) {
  let $queue := mba:getInternalEventQueue($mba)
  
  return delete node ($queue/*)[1]
};


declare function mba:getCurrentEvent($mba as element()) as element() {
  let $scxml := mba:getSCXML($mba)
  
  return $scxml/sc:datamodel/sc:data[@id = '_event']
};

declare updating function mba:loadNextExternalEvent($mba as element()) {
  let $queue := mba:getExternalEventQueue($mba)
  let $nextEvent := ($queue/event)[1]
  let $nextEventName := <name xmlns="">{fn:string($nextEvent/@name)}</name>
   let $nextEventType := <type xmlns="">{fn:string($nextEvent/@type)}</type>
  let $nextEventSendid := <sendid xmlns="">{fn:string($nextEvent/@sendid)}</sendid>
  let $nextEventOrigin := <origin xmlns="">{fn:string($nextEvent/@origin)}</origin>
  let $nextOriginType := <origintype xmlns="">{fn:string($nextEvent/@origintype)}</origintype>
  let $nextInvokeid := <invokeid xmlns="">{fn:string($nextEvent/@invokeid)}</invokeid>
  let $nextEventData := <data xmlns="">{$nextEvent/*}</data>
  let $nextEventData1 := <data xmlns="">{$nextEvent/text()}</data>
  let $currentEvent := mba:getCurrentEvent($mba)
  
  return (
    mba:removeCurrentEvent($mba),
    if ($nextEvent) then insert node $nextEventName into $currentEvent else (),
     if ($nextEvent) then insert node $nextEventType into $currentEvent else (),
    if ($nextEvent) then insert node $nextEventSendid into $currentEvent else (),
    if ($nextEvent) then insert node $nextEventOrigin into $currentEvent else (),
    if ($nextEvent) then insert node $nextOriginType into $currentEvent else (),
    if ($nextEvent) then insert node $nextInvokeid into $currentEvent else (),
    if ($nextEvent) then insert node $nextEventData into $currentEvent else (),
      if ($nextEvent) then insert node $nextEventData1 into $currentEvent else (),
    mba:dequeueExternalEvent($mba)
  )
};



declare function mba:getCounter($mba)
{
       $mba/*/*/sc:scxml/sc:datamodel/sc:data[@id='_x']/response/counter/text()
};




declare updating function mba:loadNextInternalEvent($mba as element()) {
  let $queue := mba:getInternalEventQueue($mba)
  let $nextEvent := ($queue/event)[1]
  let $nextEventName := <name xmlns="">{fn:string($nextEvent/@name)}</name>
  let $nextEventType := <type xmlns="">{fn:string($nextEvent/@type)}</type>
  let $nextEventSendid := <sendid xmlns="">{fn:string($nextEvent/@sendid)}</sendid>
  let $nextEventOrigin := <origin xmlns="">{fn:string($nextEvent/@origin)}</origin>
  let $nextOriginType := <origintype xmlns="">{fn:string($nextEvent/@origintype)}</origintype>
  let $nextInvokeid := <invokeid xmlns="">{fn:string($nextEvent/@invokeid)}</invokeid>
  let $nextEventData := <data xmlns="">{$nextEvent/*}</data>
let $counter := 
if(fn:empty( mba:getCurrentEvent($mba)/data/id/text())) then 
mba:getCounter($mba) -1 

else
 mba:getCurrentEvent($mba)/data/id/text()
  let $currentEvent := mba:getCurrentEvent($mba)
  
  return (
    mba:removeCurrentEvent($mba),
    if ($nextEvent) then insert node $nextEventName into $currentEvent else (),
    if ($nextEvent) then insert node $nextEventType into $currentEvent else (),
    if ($nextEvent) then insert node $nextEventSendid into $currentEvent else (),
    if ($nextEvent) then insert node $nextEventOrigin into $currentEvent else (),
    if ($nextEvent) then insert node $nextOriginType into $currentEvent else (),
    if ($nextEvent) then insert node $nextInvokeid into $currentEvent else (),
    if ($nextEvent) then insert node $nextEventData into $currentEvent else (),
    mba:dequeueInternalEvent($mba)
  )
};




declare updating function mba:removeCurrentEvent($mba as element()) {
  let $currentEvent := mba:getCurrentEvent($mba)
  
  return delete nodes $currentEvent/*
};

declare updating function mba:init($mba as element()) {
  let $scxml := mba:getSCXML($mba)
  
  let $dbName := try
          {mba:getDatabaseName($mba)
        }
        catch *
        {()}
  
  let $collectionName := try 
         {mba:getCollectionName($mba)
        }
        catch *
        {'invoke'}
  let $insertotherdm := $scxml//*
  return (
  
  if (not ($scxml/sc:datamodel)) then 
  
  ( insert node
   <sc:datamodel>
    <sc:data id = "_event"/> 
    <sc:data id = "_sessionid">{generate-id($mba)} </sc:data>
      <sc:data id = "_name">  {$scxml/@name/data()} </sc:data>
       <sc:data id = "_ioprocessors">{'http://www.w3.org/TR/scxml/#SCXMLEventProcessor'}
        </sc:data>
       
      <sc:data id = "_x">
          <db xmlns="">{ $dbName}
        </db>
         
         <collection xmlns="">
         {$collectionName}</collection>
          <name xmlns="">{fn:string($mba/@name)}</name>
          <currentStatus xmlns=""/>
          <externalEventQueue xmlns=""/>
          <internalEventQueue xmlns=""/>
           <isRunning xmlns="">{fn:true()}</isRunning>
           <parentInvoke xmlns=""/>
            <childInvoke xmlns=""/>
         <currentEntrySet xmlns=""/>
         <currentExitSet xmlns=""/>
         <currentTransitions xmlns=""/>
          <statesToInvoke xmlns=""/>
          <response  xmlns="">
               <counter xmlns="">1</counter>
           </response>
          <historyStates xmlns=""/>
        </sc:data>
   </sc:datamodel> into $scxml
 )
   else
   ( 
   
   if (not ($scxml/sc:datamodel/sc:data[@id = '_sessionid'])) then
      insert node <sc:data id = "_sessionid">{generate-id($mba)}</sc:data> into $scxml/sc:datamodel
    else (),
    
   if (not ($scxml/sc:datamodel/sc:data[@id = '_event'])) then
      insert node <sc:data id = "_event"/> into $scxml/sc:datamodel
    else (),
    
   if (not ($scxml/sc:datamodel/sc:data[@id = '_name'])) then
      insert node <sc:data id = "_name">{$scxml/@name/data()} </sc:data> into $scxml/sc:datamodel
    else (),
    
    if (not ($scxml/sc:datamodel/sc:data[@id = '_ioprocessors'])) then
      insert node <sc:data id = "_ioprocessors">{'http://www.w3.org/TR/scxml/#SCXMLEventProcessor'}</sc:data> into $scxml/sc:datamodel
    else (),
    if (not ($scxml/sc:datamodel/sc:data[@id = '_x'])) then
      insert node 
        <sc:data id = "_x">
          <db xmlns="">{$dbName}</db>
          <collection xmlns="">{$collectionName}</collection>
          <name xmlns="">{fn:string($mba/@name)}</name>
          <currentStatus xmlns=""/>
          <isRunning xmlns="">{fn:true()}</isRunning>
           <parentInvoke xmlns=""/>
            <childInvoke xmlns=""/>
          <externalEventQueue xmlns=""/>
          <internalEventQueue xmlns=""/>
          <currentEntrySet xmlns=""/>
          <currentExitSet xmlns=""/>
          <currentTransitions xmlns=""/>
          <statesToInvoke xmlns=""/>
          <response  xmlns="">
               <counter xmlns="">1</counter>
           </response>
          <historyStates xmlns=""/>
            
        </sc:data>
      into $scxml/sc:datamodel
    else (),
    if (not ($mba/mba:concretizations)) then
      insert node <mba:concretizations/> into $mba
    else ()
  ))
};



declare updating function mba:createDatamodel($mba)
{
  
let $scxml := mba:getSCXML($mba)
let $configuration := mba:getConfiguration($mba)
let $dataModels := sc:selectAllDataModels($mba)

let $data :=  $scxml/sc:datamodel/sc:data[not ( functx:is-value-in-sequence(@id, ('_x', '_event'))) ]
for $d in $data

return 

if ($d/@expr) then
(try
         {
           let $value := sc:eval($d/@expr,$dataModels)
           let $test := fn:trace("hallo")
           return insert node <data id="{$d/@id}">{$value} </data> into $scxml/sc:datamodel, delete node $d
            
         } 
         catch *
         {
            let $test := fn:trace("hallo2")
            let $test := fn:trace($err:description,"errdesc")
            let $event := <event name="error.execution" xmlns=""></event>           
           return mba:enqueueInternalEvent($mba,$event), insert node <data id="{$d/@id}"></data> into $scxml/sc:datamodel, delete node $d
           
         })

else if($d/@src)  then
(try
         {
           let $value :=  
           if (fn:substring-before($d/@src, ':') = 'file') then 
           
             let $test := fn:trace("hallofile")
          return fn:unparsed-text(fn:substring-after($d/@src,':'))
          else
          ()
           
           let $test := fn:trace("hallo")
           return insert node <data id="{$d/@id}">{$value} </data> into $scxml/sc:datamodel, delete node $d
            
         } 
         catch *
         {
            let $test := fn:trace("hallo2")
            let $event := <event name="error.execution" xmlns=""></event>           
           return mba:enqueueInternalEvent($mba,$event), insert node <data id="{$d/@id}">{$err:code}</data> into $scxml/sc:datamodel, delete node $d
           
         })
         
else if($d/@systemsrc)  then
(try
         {
           let $value :=  sc:eval($d/@systemsrc,$dataModels)/text()
                     
           let $test := fn:trace("hallo")
           return insert node <data id="{$d/@id}">{$value} </data> into $scxml/sc:datamodel, delete node $d
            
         } 
         catch *
         {
            let $test := fn:trace("hallo2")
            let $event := <event name="error.execution" xmlns=""></event>           
           return mba:enqueueInternalEvent($mba,$event), insert node <data id="{$d/@id}">{$err:code}</data> into $scxml/sc:datamodel, delete node $d
           
         })         
         
else
()
                
};




