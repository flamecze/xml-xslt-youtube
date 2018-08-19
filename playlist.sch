<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2">
    <pattern>
        <rule context="seznam_videi">
            <assert test="xs:dateTime(vytvoreno) &lt; current-dateTime()">Datum a čas vytvoření seznamu musí být v minulosti.</assert>
            <assert test="xs:dateTime(aktualizovano) &lt; current-dateTime()">Datum a čas aktualizace seznamu musí být v minulosti.</assert>
            <assert test="xs:dateTime(aktualizovano) &gt; xs:dateTime(vytvoreno)">Datum a čas aktualizace seznamu musí být pozdější než datum a čas vytvoření.</assert>
        </rule>
        <rule context="video">
            <assert test="xs:dateTime(nahrano) &lt; current-dateTime()">Datum a čas nahrání videa musí být v minulosti.</assert>
            <assert test="xs:dateTime(publikovano) &lt; current-dateTime()">Datum a čas publikování videa musí být v minulosti.</assert>
            <assert test="xs:dateTime(publikovano) &gt;= xs:dateTime(nahrano)">Datum a čas publikování videa musí být stejný nebo pozdější než datum a čas nahrání.</assert>
            <report test="count(../video[@vid = current()/@vid]) &gt; 1">Duplicitní ID videa: <value-of select="@vid"/></report>
        </rule>
        <rule context="komentar">
            <assert test="xs:dateTime(zverejneno) &lt; current-dateTime()">Datum a čas zveřejnění komentáře musí být v minulosti.</assert>
            <assert test="xs:dateTime(zverejneno) &gt; xs:dateTime(../../publikovano)">Zveřejnění komentáře musí proběhnout po publikování videa.</assert>
            <report test="count(../komentar[@cid = current()/@cid]) &gt; 1">Duplicitní ID komentáře: <value-of select="@cid"/></report>
        </rule>
    </pattern>
</schema>