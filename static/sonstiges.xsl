<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">


  

<xsl:template match="/">
  <html>
  <body>
  <xsl:apply-templates/>
  </body>
  </html>
</xsl:template>

<xsl:template match="response">
  <p>
   <h2> <xsl:apply-templates/> </h2>
  </p>
   <a href="http://localhost:8984/">Zurück zum Start </a> <br></br>
</xsl:template>



</xsl:stylesheet>


	