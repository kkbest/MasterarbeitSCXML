<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"   exclude-result-prefixes="xsl fo xs fn sc mba scx test page">
 <xsl:output omit-xml-declaration="yes" indent="yes"/>
    <xsl:strip-space elements="*"/>

<xsl:template match="/">



<!--  <html xmlns="http://www.w3.org/1999/xhtml">-->
<html>
    <head>
      <title>Event Adding Service</title>
      <link rel="stylesheet" href="static/bootstrap/css/bootstrap.min.css" /> 

      <script src="static/bootstrap/js/bootstrap.min.js"></script>  
    </head>
    <body>
    <div class="navbar navbar-inverse">
  <div class="navbar-header">
    <button type="button" class="navbar-toggle" data-toggle="collapse" data-target=".navbar-inverse-collapse">
      <span class="icon-bar"></span>
      <span class="icon-bar"></span>
      <span class="icon-bar"></span>
    </button>
    <a class="navbar-brand" href="#">SCXML-Interpreter</a>
  </div>
  </div>

 <div class="container">
<div class="page-header" id="banner">
        <div class="row">
          <div class="col-lg-6">
            <h1> SCXML - Interpreter</h1>
            <p class="lead">Hinzufügen von Events</p>
          </div>
        </div>
      </div>
	
	

<form action="addEventWithName" method="POST" role="form" class="form-horizontal">
  
     <div class="radio">
  <label><input type="radio" name="event" value="eigenesEvent"/>ownEvent</label>
</div>

  <xsl:apply-templates/> 
 

  <div class="form-group">
    <div class="col-sm-offset-2 col-sm-10">
      <button type="submit" class="btn btn-primary">Create Event</button>
    </div>
  </div>
</form>

	
    </div>
  </body>
  </html>
</xsl:template>




<xsl:template match="auswahl">

		
<xsl:for-each select="event">
		
					  <div class="radio">
  <label><input type="radio" name="event">
<xsl:attribute name="value">
       <xsl:value-of select="."/>
    </xsl:attribute>
	</input>
	<xsl:value-of select="."/></label>
</div>

</xsl:for-each>	


</xsl:template>


<xsl:template match="hidden">

		<xsl:for-each select="*">
			<!--- <xsl:variable name="input"><xsl:value-of select="."/></xsl:variable> -->

		
<div class="form-group" >
  <input type="hidden" class="form-control" >
  <xsl:attribute name="value">
       <xsl:value-of select="."/>
    </xsl:attribute>
	<xsl:attribute name="id">
       <xsl:value-of select="."/>
    </xsl:attribute>
	
	 <xsl:attribute name="name">
       <xsl:value-of select="local-name(.)"/>
    </xsl:attribute>
	
  </input>
  
  
</div>

	
		</xsl:for-each>	 
</xsl:template> 


</xsl:stylesheet>
	