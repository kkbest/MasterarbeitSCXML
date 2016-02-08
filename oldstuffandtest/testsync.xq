import module namespace kk = 'http://www.w3.org/2005/07/kk';
import module namespace scx='http://www.w3.org/2005/07/scxml/extension/';
import module namespace functx = 'http://www.functx.com';
import module namespace mba='http://www.dke.jku.at/MBA'; 
import module namespace sc = 'http://www.w3.org/2005/07/scxml';
import module namespace sync = 'http://www.dke.jku.at/MBA/Synchronization';



declare variable $dbName := 'myMBAse';
declare variable $collectionName := 'JohannesKeplerUniversity';
declare variable $mbaName := 'InformationSystems';

  let $mba1 := mba:getMBA($dbName, $collectionName, $mbaName)
  let $executableContent :=  kk:getExecutableContents(mba:getMBA($dbName, $collectionName, $mbaName))


  let $content := $executableContent[1]
 
  let $scxml := mba:getSCXML($mba1)
      
      let $configuration := mba:getConfiguration($mba1)
      let $dataModels := sc:selectDataModels($configuration)
      return
       typeswitch($content)
          case element(sc:assign) return 
            copy $copymba := $mba1
              modify 
              (
            sc:assign($dataModels, $content/@location, $content/@expr, $content/@type, $content/@attr, $content/*)
              )
              return $copymba
          case element(sync:newDescendant) return 
               
               let $name := $content/@name
             let $level := $content/@level
             let $parents := $content/@parents
             let $collection := mba:getCollection($dbName, $collectionName)
              let $nodelist := $content/*
           
        let $name := 
          if ($name) then sync:eval($name, $dataModels) 
          else functx:capitalize-first($level) || 
            count($collection/mba:mba[@topLevel = $level])
        
        let $parents := fn:trace(
          if ($parents) then sync:eval($parents, $dataModels) else fn:string($mba1/@name))
          
       let $parentElements :=
          for $p in $parents return mba:getMBA($dbName, $collectionName, $p)
        
         let $new := mba:concretize($parentElements, $name, $level)
               
               
        return  copy $parentElementscopy := $parentElements
      modify 
      (
            insert node $new into 
           $parentElementscopy[1]/mba:concretizations
        ) 
        
        return $parentElements
     
      default return ()

