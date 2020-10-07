<?xml version="1.0"?>
<!--
   Copyright 2020 pbv22@github.com

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
-->
<xsl:stylesheet exclude-result-prefixes="xsl" version="1.0"
	xmlns="http://schemas.xmlsoap.org/wsdl/"
	xmlns:wsdl="http://schemas.xmlsoap.org/wsdl/"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:output indent="yes" method="xml"/>

	<xsl:template match="/wsdl:definitions">
		<xsl:copy>
			<xsl:apply-templates select="@* | node()"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="wsdl:types">
		<xsl:copy>
			<xsl:apply-templates select="xs:import"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="xs:import">
		<xsl:apply-templates select="document(@schemaLocation)"/>
	</xsl:template>

	<xsl:template match="@* | node()">
		<xsl:copy>
			<xsl:apply-templates select="@* | node()"/>
		</xsl:copy>
	</xsl:template>

</xsl:stylesheet>
