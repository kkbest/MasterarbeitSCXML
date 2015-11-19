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
 
 : Provide a customized version of this module in your own projects. It allows
 : for the introduction of additional system variables and functions as well as
 : the definition of module imports.
 
 : @author Christoph Schütz
 :)
 module namespace scx='http://www.w3.org/2005/07/scxml/extension/';

declare function scx:importModules() as xs:string {
  ()
};

declare function scx:builtInFunctionDeclarations() as xs:string {
  
  let $inFunction :=
    'let $_in := function($stateId) { ' ||
      'fn:exists($_x/currentStatus/state[@ref=$stateId])' || 
    '} '
  
  return $inFunction
};