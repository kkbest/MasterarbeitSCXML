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
            <p class="lead">Erhalten eines Ergebnisses</p>
          </div>
        </div>
      </div>
	
	

  <xsl:apply-templates/> 
 

	
    </div>
  </body>
  </html>
</xsl:template>




<xsl:template match="response">

<xsl:for-each select="*">
  <xsl:value-of select="local-name(.)"/> : 
  <xsl:value-of select="./@id"/> : 
		  <xsl:value-of select="."/>
		  <br />
		  
	
		</xsl:for-each>	 


</xsl:template>


<xsl:template match="hidden">

		<xsl:for-each select="*">
  <xsl:value-of select="local-name(.)"/> : 
		  <xsl:value-of select="."/>
		  <br />
		  
	
		</xsl:for-each>	 
</xsl:template> 


</xsl:stylesheet>
	