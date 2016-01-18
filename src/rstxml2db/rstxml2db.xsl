<?xml version="1.0" encoding="UTF-8"?>
<!--
   Purpose:
     Transforms RST XML into DocBook

   Parameters:
     * indexfile
       Path to the '.booktree.xml' file

   Input:
     RST XML file, converted with sphinx-build using option -b xml

   Output:
     DocBook document

   Author:
     Thomas Schraitle <toms AT opensuse.org>
     Copyright 2016 SUSE Linux GmbH

-->
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:exsl="http://exslt.org/common"
  exclude-result-prefixes="exsl">

  <xsl:key name="id" match="*" use="@ids"/>

  <xsl:param name="xml.ext">.xml</xsl:param>
  <xsl:param name="indexfile" select="'.booktree.xml'"/>

  <xsl:variable name="index" select="document($indexfile, .)"/>
  <xsl:variable name="sections" select="$index//section"/>
  <xsl:variable name="indexids" select="$index//@id"/>

  <xsl:template match="*">
    <xsl:message>WARN: Unknown element '<xsl:value-of select="local-name()"/>'</xsl:message>
  </xsl:template>


  <xsl:template name="has.section.id">
    <xsl:param name="id"/>

    <xsl:value-of select="boolean($indexids[. = $id])"/>
  </xsl:template>

  <xsl:template name="get.section.from.id">
    <xsl:param name="id"/>

    <xsl:value-of select="$sections[@id = $id]"/>
  </xsl:template>

  <xsl:template name="get.level.from.id">
    <xsl:param name="id"/>

    <xsl:value-of select="$index//*[@id = $id]/@level"/>
  </xsl:template>

  <xsl:template name="get.structural.name">
    <xsl:param name="level"/>
    <xsl:choose>
      <xsl:when test="$level = 0">book</xsl:when>
      <xsl:when test="$level = 1">chapter</xsl:when>
      <xsl:when test="$level = 2">sect1</xsl:when>
      <xsl:when test="$level = 3">sect2</xsl:when>
      <xsl:when test="$level = 4">sect3</xsl:when>
      <xsl:when test="$level = 5">sect4</xsl:when>
      <xsl:when test="$level = 6">sect5</xsl:when>
      <xsl:otherwise>
        <xsl:message>ERROR: Level too big!</xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="create.structural.name">
    <xsl:param name="id" select="@ids"/>
    <xsl:variable name="level">
      <xsl:call-template name="get.level.from.id">
        <xsl:with-param name="id" select="$id"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="name">
      <xsl:call-template name="get.structural.name">
        <xsl:with-param name="level" select="$level"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:value-of select="$name"/>
  </xsl:template>

  <!-- =================================================================== -->
  <!-- Ignored elements                                                    -->
  <xsl:template match="section[@names='search\ in\ this\ guide']"/>


  <!-- =================================================================== -->
  <xsl:template match="document">
    <xsl:apply-templates/>
  </xsl:template>

  <!--<xsl:template match="document/section">
    <xsl:variable name="name">
      <xsl:call-template name="create.structural.name"/>
    </xsl:variable>

    <xsl:element name="{$name}">
      <xsl:if test="@ids">
        <xsl:attribute name="id">
          <xsl:value-of select="@ids"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>-->

  <xsl:template match="section[@names='abstract']">
    <abstract>
      <xsl:apply-templates/>
    </abstract>
  </xsl:template>

  <xsl:template match="section">
    <xsl:variable name="name">
      <xsl:call-template name="create.structural.name"/>
    </xsl:variable>

    <xsl:element name="{$name}">
      <xsl:if test="@ids">
        <xsl:attribute name="id">
          <xsl:choose>
            <!-- Use the 2nd argument in @ids -->
            <xsl:when test="contains(@ids, ' ')">
              <xsl:value-of select="substring-after(@ids, ' ')"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="@ids"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="section/title">
    <xsl:copy-of select="."/>
  </xsl:template>

  <xsl:template match="section[@names='contents']">
    <xsl:apply-templates mode="xinclude"/>
  </xsl:template>

  <xsl:template match="compound[@classes='toctree-wrapper']">
    <xsl:apply-templates mode="xinclude"/>
  </xsl:template>

  <xsl:template match="text()" mode="xinclude"/>

  <xsl:template match="list_item[@classes='toctree-l1']" mode="xinclude">
    <xsl:variable name="xiref" select="concat(*/reference/@refuri, $xml.ext)"/>
    <xi:include href="{$xiref}" xmlns:xi="http://www.w3.org/2001/XInclude"/>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>

  <!-- =================================================================== -->
  <xsl:template match="literal_block[@language='shell' or @language='console']">
    <screen>
      <xsl:apply-templates/>
    </screen>
  </xsl:template>

  <xsl:template match="literal_block[@language]">
    <screen language="{@language}">
      <xsl:apply-templates/>
    </screen>
  </xsl:template>

  <xsl:template match="literal_block">
    <screen>
      <xsl:apply-templates/>
    </screen>
  </xsl:template>

  <xsl:template match="note|tip|warning|caution|important">
    <xsl:variable name="name">
      <xsl:choose>
        <xsl:when test="local-name()='caution'">important</xsl:when>
        <xsl:otherwise><xsl:value-of select="local-name(.)"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:element name="{$name}">
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="paragraph">
    <para>
      <xsl:apply-templates/>
    </para>
  </xsl:template>

  <xsl:template match="bullet_list[@bullet='-' or @bullet='*']">
    <itemizedlist>
      <xsl:apply-templates/>
    </itemizedlist>
  </xsl:template>

  <xsl:template match="list_item">
    <listitem>
      <xsl:apply-templates/>
    </listitem>
  </xsl:template>

  <xsl:template match="enumerated_list">
    <procedure>
      <xsl:apply-templates/>
    </procedure>
  </xsl:template>

  <xsl:template match="enumerated_list/list_item">
    <step>
      <xsl:apply-templates/>
    </step>
  </xsl:template>

  <xsl:template match="definition_list">
    <variablelist>
      <term>
        <xsl:apply-templates select="definition_list_item"/>
      </term>
    </variablelist>
  </xsl:template>

  <xsl:template match="definition_list_item">
    <varlistentry>
      <xsl:apply-templates/>
      <xsl:apply-templates select="../definition"/>
    </varlistentry>
  </xsl:template>

  <xsl:template match="definition_list_item/term">
    <term>
      <xsl:apply-templates/>
    </term>
  </xsl:template>

  <xsl:template match="definition">
    <listitem>
      <xsl:apply-templates/>
    </listitem>
  </xsl:template>

  <!-- =================================================================== -->
  <xsl:template match="emphasis">
    <xsl:copy-of select="."/>
  </xsl:template>

  <xsl:template match="emphasis[@classes='guilabel']">
    <guilabel>
      <xsl:apply-templates/>
    </guilabel>
  </xsl:template>

  <xsl:template match="emphasis[@classes='menuselection']">
    <menuchoice>
      TODO
    </menuchoice>
  </xsl:template>

  <xsl:template match="strong[@classes='command']">
    <command>
      <xsl:apply-templates/>
    </command>
  </xsl:template>

  <xsl:template match="strong">
    <emphasis role="bold">
      <xsl:apply-templates/>
    </emphasis>
  </xsl:template>

  <xsl:template match="literal">
    <xsl:copy-of select="."/>
  </xsl:template>

  <xsl:template match="literal_emphasis[contains(@classes, 'option')]">
    <option>
      <xsl:apply-templates/>
    </option>
  </xsl:template>

  <xsl:template match="reference[@refuri]">
    <ulink url="{@refuri}">
      <xsl:value-of select="."/>
    </ulink>
  </xsl:template>

  <xsl:template match="reference[@refid]">
    <xref linkend="{@refid}"/>
  </xsl:template>

</xsl:stylesheet>