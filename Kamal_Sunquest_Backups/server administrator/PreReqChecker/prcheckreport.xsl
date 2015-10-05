<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format">
	<xsl:key name="pridkey" match="/PRCheckReport/PRCheckList/PRCheck" use="@pr_id"/>
	<xsl:template match="PRCheckReport">
		<html>
			<head>
				<title>OpenManage Install Prerequisite Check</title>
			</head>
			<body>
				<xsl:apply-templates select="./FeatureList/Feature"/>
			</body>
		</html>
	</xsl:template>
	<xsl:template match="Feature">
		<!--Test to see if any of our PRCheckID's have a status of non-zero.  If so we will continue.-->
		<xsl:choose>
          <xsl:when test="key('pridkey',PRCheckID//@value)/Status != 0">
            <table border="1" align="center" width="100%">
				<thead>
					<tr>
						<th colspan="3" align="left">
							<strong><xsl:value-of select="./@name"/></strong>
						</th>
					</tr>
				</thead>
				<tbody>
					<xsl:for-each select="PRCheckID">
							<xsl:variable name="idval" select="./@value"/>
							<xsl:apply-templates select="/PRCheckReport/PRCheckList/PRCheck[@pr_id=$idval and Status != 0]"/>
					</xsl:for-each>
				</tbody>
			</table>
          </xsl:when>
          <xsl:when test="key('pridkey',PRCheckID//@value)/Status = 0"/>
          <xsl:otherwise>
            <table border="1" align="center" width="100%">
				<thead>
					<tr>
						<th colspan="3" align="left">
							<strong>Error, ID not found!</strong>
						</th>
					</tr>
				</thead>
                <tbody/>
			</table>
          </xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="PRCheck">
		<xsl:variable name="capid" select="CaptionID"/>
		<xsl:variable name="descid" select="DescriptionID"/>
		<xsl:variable name="urlid" select="URLID"/>
		<tr>
		<td>
			<xsl:value-of select="document('prereqstrings.xml')/PRCheckStringList/CaptionStringList/CaptionString[@cap_id = $capid]"/>
		</td>
		<td>
			<xsl:value-of select="document('prereqstrings.xml')/PRCheckStringList/DescriptionStringList/DescriptionString[@des_id = $descid]"/>
		</td>
		<td>
			<a href="{document('prereqstrings.xml')/PRCheckStringList/URLStringList/URLString[@url_id = $urlid]}">
				<xsl:value-of select="document('prereqstrings.xml')/PRCheckStringList/URLStringList/URLString[@url_id = $urlid]"/>
			</a>
		</td>
		</tr>
	</xsl:template>
</xsl:stylesheet>
