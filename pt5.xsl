<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:pt="https://github.com/dariok/pt"
  xmlns="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="#all"
  version="3.0">
  
  <xsl:output indent="1" />
  
  <xd:doc>
    <xd:desc>
      <xd:p>Try to find the borders of blocks</xd:p>
    </xd:desc>
  </xd:doc>
  
  <!-- assumptions when guessing blocks:
       - no preceding-sibling::tei:l  ––  e.g. first line after heading
       - @left has some other value than the main left of the page
       - @size is different than the previous lines’
       - the previous line is more than 1% of total width shorter than it’s preceding line (we assume all pages have
         roughly the same width or it will get even more complicated)
       - does not start with a small letter
  -->
  <xsl:template match="tei:div">
    <div>
      <xsl:for-each-group select="*"
        group-starting-with="tei:l[not(matches(., '^[a-z]')) and (
          not(preceding-sibling::tei:l)
          or @left ne preceding::tei:pb[1]/@l
          or @size ne preceding-sibling::tei:l[1]/@size
          or preceding-sibling::tei:l[1]/@right/number() lt preceding-sibling::tei:l[2]/@right/number() - 0.01 *
               preceding::tei:pb[1]/@width
        )]">
        <xsl:variable name="first" select="(current-group()[self::tei:l])[1]" />
        <xsl:variable name="id" select="generate-id($first)" />
        <xsl:choose>
          <xsl:when test="$first">
            <xsl:apply-templates select="current-group()[following-sibling::*[generate-id() = $id]]" />
            <ab>
              <xsl:apply-templates select="$first | current-group()[preceding-sibling::*[generate-id() = $id]
                 and not(self::tei:div)]" />
            </ab>
            <xsl:apply-templates select="current-group()[self::tei:div]" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="current-group()" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each-group>
    </div>
  </xsl:template>
  
  <!-- 
  <xsl:sequence select="@size | $group[1]/@rendition" />
          <xsl:attribute name="top" select="min($group/@top)" />
          <xsl:attribute name="left" select="min($group/@left)" />
          <xsl:attribute name="width" select="max($group/@width)" />
          <xsl:attribute name="height" select="$group[last()]/@top + $group[last()]/@height - $group[1]/@top" />
          <xsl:apply-templates select="$group" mode="head" />
  -->
  
  <xsl:template match="tei:head/@level" />
  <xsl:template match="@* | node()">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()" />
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
