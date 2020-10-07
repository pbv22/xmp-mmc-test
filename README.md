# XML-Maven-Plugin-Multi-Module-Catalog-Test (xmp-mmc-test)

This is a demo/test project for a potential issue in
[xml-maven-plugin](https://github.com/mojohaus/xml-maven-plugin).

## Potential Issue

In a multi-module-project the configured catalog is only resolved for the first
module. All modules built afterwards will use the catalog determined for the
first module. Any catalog configured for these plugins will not be
resolved/used.

## Demo Project

The demo project consists of an aggregator and several modules for helper
artifacts. Among these: XML schemas and an XML catalog that makes these schemas
resolvable when placed next to the schemas. The heart of the demo project are
two projects containing WSDL files which import the XML schemas and which are
transformed using an XSLT-stylesheet. The transformation requires the catalog to
"find" the schemas. The WSDL-projects function generally the same but import
different schemas.

### Execute/Build the Demo Project

1. Clone the repository
```
git clone https://github.com/pbv22/xmp-mmc-test.git
```

2. Change into the aggregator's directory
```
cd xmp-mmc-test/xmp-mmc-test
```

3. Execute the build
```
mvn clean install
```

#### Expected Behavior

After some setup for the other/helper parts of the multi-module-project, the
WSDL projects are built:

1. _xmp-mmc-test-wsdl-a_ is built:
	
	1.1 _schema-a.xsd_ is copied to _target/xsd_. _schema-b.xsd_ is **not**
	copied there.
	
	1.2 _catalog.xml_ is copied to _target/xsd_.
	
	1.3 The transformation is executed with _xml-maven-plugin_.
	
	1.4 The transformed version of _wsdl-a.wsdl_ is in
	_xmp-mmc-test-wsdl-a/target/generated-resources/xml/xslt/service-a.wsdl_
	and looks like this:
	
	```
	...
	<types>
		<schema xmlns="http://www.w3.org/2001/XMLSchema"
			xmlns:tns="urn:example:com.example.schema.a"
			targetNamespace="urn:example:com.example.schema.a">
			<element name="name" type="tns:Name"/>
			<complexType name="Name">
				<sequence>
					<element name="firstName" type="string"/>
					<element name="lastName" type="string"/>
				</sequence>
			</complexType>
		</schema>
	</types>
	...
	```
	
2. _xmp-mmc-test-wsdl-b_ is built:
	
	2.1 _schema-b.xsd_ is copied to _target/xsd_. _schema-a.xsd_ is **not**
	copied there.
	
	2.2 _catalog.xml_ is copied to _target/xsd_.
	
	2.3 The transformation is executed with _xml-maven-plugin_.
	
	2.4 The transformed version of _wsdl-b.wsdl_ is in
	_xmp-mmc-test-wsdl-b/target/generated-resources/xml/xslt/service-b.wsdl_
	and looks like this:
	
	```
	...
	<types>
		<schema xmlns="http://www.w3.org/2001/XMLSchema"
			xmlns:tns="urn:example:com.example.schema.b"
			targetNamespace="urn:example:com.example.schema.b">
			<element name="address" type="tns:Address"/>
			<complexType name="Address">
				<sequence>
					<element name="street" type="string"/>
					<element name="houseNo" type="string"/>
					<element name="zip" type="string"/>
					<element name="city" type="string"/>
				</sequence>
			</complexType>
		</schema>
	</types>
	...
	```

#### Actual Behavior

1. Build of _xmp-mmc-test-wsdl-a_ works as expected.

2. Build of _xmp-mmc-test-wsdl-b_ completes successfully, but:
	
	2.1 _xml-maven-plugin_ issues an info message:
	```
	[INFO] --- xml-maven-plugin:1.0.2:transform (transform-wsdl) @ xmp-mmc-test-wsdl-b ---
	[INFO] Transforming file: /home/paul/wc/xmp-mmc-test/xmp-mmc-test-wsdl-b/src/main/resources/service-b.wsdl
	jar:file:/home/paul/wc/xmp-mmc-test/xmp-mmc-test-xslt/target/xmp-mmc-test-xslt-1.0.0-SNAPSHOT.jar!/transform.xsl; Zeilennummer38; Spaltennummer60; Angefordertes Dokument kann nicht geladen werden: /home/paul/wc/xmp-mmc-test/xmp-mmc-test-wsdl-a/target/xsd/schema-b.xsd (Datei oder Verzeichnis nicht gefunden)
	[INFO] Transformed 1 file(s).
	```
	i.e. _schema-b.xsd_ is looked for in _xmp-mmc-test-wsdl-**a**/target/xsd_
	where it can't be found. Because of the relative paths in the catalog file
	that means that the catalog file is also read from that directory. The
	catalog should actually be read from _xmp-mmc-test-wsdl-**b**/target/xsd_.
	
	2.2 The build completes successfully. This may be ok, the build needn't
	necessarily fail altogether under the given circumstances. But the info
	messsage saying that the requested document _.../schema-b.xsd_ could not be
	found should rather be a warning.
	
	2.3 The transformed version of _wsdl-b.wsdl_ is in
	_xmp-mmc-test-wsdl-b/target/generated-resources/xml/xslt/service-b.wsdl_
	but looks like this:
	
	```
	...
	<types/>
	...
	```

