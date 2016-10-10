<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:template match="/">
<html>
<head>
	
</head>
 
<body>
		<h3>addEvent</h3>
		<h3> <xsl:value-of select="local-name(./*)"/></h3>
				
				
				 <form method="post" action="update">
				
			   <input type="hidden" name="eventName">
    <xsl:attribute name="value">
       <xsl:value-of select="local-name(./*)"/>
    </xsl:attribute>
	</input>  

			
	
   
   <xsl:for-each select="./*/*/hidden/*">
   
   <input type="hidden">
    <xsl:attribute name="value">
       <xsl:value-of select="."/>
    </xsl:attribute>
   <xsl:attribute name="name">
       <xsl:value-of select="local-name(.)"/>
    </xsl:attribute>
	</input>   
   </xsl:for-each>
   
    
   
   
   <xsl:for-each select="./*/*/data">
				<xsl:value-of select="."/>
				<br> </br>
				<input type = "text">
<xsl:attribute name="name">
       <xsl:value-of select="."/>
    </xsl:attribute>
	</input>
				
			<br></br>
			  
   
   </xsl:for-each>
  

   <xsl:for-each select="eigenesEvent">
	Own EventName 
	 <br></br>
	 <input type="text" name="ownEventName"> </input> 
   <br></br>
   </xsl:for-each>
   
Own DataElementName  

<br></br>
  <input type="text" name="ownDataName"> 
   </input>
   <br></br>
Own  DataElementData  
<br></br>
  <input type="text" name="ownDataData"> 
   </input>
   <br></br>
   
   
   

   

   
	 <input type="submit"> </input>
   </form>
   
    
   
   
  </body>
  </html>
</xsl:template>


</xsl:stylesheet>