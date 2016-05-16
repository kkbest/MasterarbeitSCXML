<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:template match="/">


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
   
   
    <div class="form-group">
  <label><xsl:value-of select="."/></label>
  <input type="text" class="form-control">
  <xsl:attribute name="name">
       <xsl:value-of select="."/>
    </xsl:attribute>
	<xsl:attribute name="id">
       <xsl:value-of select="."/>
    </xsl:attribute>
	
</input>

  
</div>		  
   
   </xsl:for-each>
  

   <xsl:for-each select="eigenesEvent">
  
    <div class="form-group">
  <label>Own EventName</label>
  <input type="text" class="form-control" id="ownEventName" name="ownEventName" />
</div>

   </xsl:for-each>
   

 <div class="form-group">
  <label for="dbName">Own DataElementName</label>
  <input type="text" class="form-control" id="ownDataName" name="ownDataName" />
</div>


 <div class="form-group">
  <label for="dbName">Own DataElementData</label>
  <input type="text" class="form-control" id="ownDataData" name="ownDataData" />
</div>
   
	 <input type="submit"> </input>
   </form>
   
    
   
   </div>
  </body>
  </html>
</xsl:template>


</xsl:stylesheet>