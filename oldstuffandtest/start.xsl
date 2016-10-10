<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">


<xsl:template match="/">
<html>
<head>
	
</head>
 
<body>
		<h3>selectEvent</h3>
			<br></br>
			   <form method="post" action="addEventWithName">
   <xsl:apply-templates/>
   
   
	<input type="radio" name="event" size="50" value = "eigenesEvent"> 
			</input>ownEvent<br> </br>
   	 <input type="submit"> </input>
   </form>
   
  </body>
  </html>
</xsl:template>




<xsl:template match="auswahl">

		<xsl:for-each select="event">
		
			<xsl:variable name="event"><xsl:value-of select="."/></xsl:variable>
						
							 <input type="radio" name="event" size="50">
    <xsl:attribute name="value">
       <xsl:value-of select="."/>
    </xsl:attribute>
 	
</input>
 <xsl:value-of select="."/> 
<br> </br>
					</xsl:for-each>	
					
							
</xsl:template>


<xsl:template match="hidden">

		<xsl:for-each select="*">
			<!--- <xsl:variable name="input"><xsl:value-of select="."/></xsl:variable> -->
		
<input type="hidden">
    <xsl:attribute name="value">
       <xsl:value-of select="."/>
    </xsl:attribute>
   <xsl:attribute name="name">
       <xsl:value-of select="local-name(.)"/>
    </xsl:attribute>
	</input>
		</xsl:for-each>	 
</xsl:template> 


</xsl:stylesheet>
	