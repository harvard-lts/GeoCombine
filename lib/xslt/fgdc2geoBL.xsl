<?xml version="1.0" encoding="UTF-8"?>
<!--
     fgdc2geoBL.xsl - Transformation from FGDC into GeoBlacklight Solr

          -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="1.0">
  <xsl:output method="text" version="1.0" encoding="UTF-8" indent="yes"/>
  <xsl:strip-space elements="*"/>

  <xsl:param name="zipName" select="'data.zip'"/>

  <xsl:variable name="institution">
    <xsl:text>Harvard</xsl:text>
  </xsl:variable>

  <!-- Output bounding box -->
<xsl:variable name="upperCorner">
    <xsl:value-of select="number(metadata/idinfo/spdom/bounding/eastbc)"/>
  <xsl:text> </xsl:text>
    <xsl:value-of select="number(metadata/idinfo/spdom/bounding/northbc)"/>
</xsl:variable>

  <xsl:variable name="lowerCorner">
    <xsl:value-of select="number(metadata/idinfo/spdom/bounding/westbc)"/>
    <xsl:text> </xsl:text>
    <xsl:value-of select="number(metadata/idinfo/spdom/bounding/southbc)"/>
  </xsl:variable>
  <xsl:variable name="x2" select="number(metadata/idinfo/spdom/bounding/eastbc)"/><!-- E -->
  <xsl:variable name="x1" select="number(metadata/idinfo/spdom/bounding/westbc)"/><!-- W -->
  <xsl:variable name="y2" select="number(metadata/idinfo/spdom/bounding/northbc)"/><!-- N -->
  <xsl:variable name="y1" select="number(metadata/idinfo/spdom/bounding/southbc)"/><!-- S -->


  <xsl:variable name="format">
    <xsl:choose>
      <xsl:when test="contains(metadata/idinfo/citation/citeinfo/geoform, 'raster digital data')">
      <xsl:text>GeoTIFF</xsl:text>
    </xsl:when>
      <xsl:when test="contains(metadata/idinfo/citation/citeinfo/geoform, 'vector digital data')">
        <xsl:text>Shapefile</xsl:text>
      </xsl:when>
      <xsl:when test="contains(metadata/distinfo/stdorder/digform/digtinfo/formname, 'TIFF')">
        <xsl:text>GeoTIFF</xsl:text>
      </xsl:when>
      <xsl:when test="contains(metadata/distinfo/stdorder/digform/digtinfo/formname, 'JPEG2000') or contains(metadata/distinfo/stdorder/digform/digtinfo/formname, 'JPEG') or contains(metadata/distinfo/stdorder/digform/digtinfo/formname, 'JP2')" >
        <xsl:text>GeoTIFF</xsl:text>
      </xsl:when>
      <xsl:when test="contains(metadata/distinfo/stdorder/digform/digtinfo/formname, 'Shape')">
        <xsl:text>Shapefile</xsl:text>
      </xsl:when>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="uuid">
    <xsl:value-of select="substring-after(metadata/idinfo/citation/citeinfo/onlink, 'harvard-')"/>
  </xsl:variable>

  <xsl:variable name="geoserver_root">
    <xsl:text>https://geodata-proxy.lib.harvard.edu/geoserver/proxy/</xsl:text>
  </xsl:variable>

  <xsl:variable name="fgdc_base">
    <xsl:text>https://raw.githubusercontent.com/harvard-library/harvard-geodata/main/fgdc/</xsl:text>
  </xsl:variable>

  <xsl:variable name="lowercase" select="'abcdefghijklmnopqrstuvwxyz-'" />
  <xsl:variable name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ_'" />
  <xsl:variable name="quot"><xsl:text>"</xsl:text></xsl:variable>
  <xsl:variable name="apos"><xsl:text>'</xsl:text></xsl:variable>

  <xsl:template match="metadata">
    <xsl:text>{</xsl:text>

    <xsl:text>"geoblacklight_version": "1.0",</xsl:text>

    <xsl:text>"dc_identifier_s": "</xsl:text>
    <xsl:value-of select="translate(idinfo/citation/citeinfo/onlink, $uppercase, $lowercase)"/>
    <xsl:text>",</xsl:text>

    <xsl:text>"dc_title_s": "</xsl:text>
    <xsl:value-of select="normalize-space(idinfo/citation/citeinfo/title)"/>
    <xsl:text>",</xsl:text>

    <xsl:text>"dc_description_s": "</xsl:text>
    <xsl:value-of select="normalize-space(translate(idinfo/descript/abstract, $quot , $apos))"/>
    <xsl:text>",</xsl:text>

    <xsl:text>"dc_rights_s": "</xsl:text>
    <xsl:choose>
      <xsl:when test="contains(idinfo/accconst, 'Restricted')">
        <xsl:text>Restricted</xsl:text>
      </xsl:when>
      <xsl:when test="contains(idinfo/accconst, 'Unrestricted')">
        <xsl:text>Public</xsl:text>
      </xsl:when>
      <xsl:when test="contains(idinfo/accconst, 'No restriction')">
        <xsl:text>Public</xsl:text>
      </xsl:when>
      <xsl:when test="contains(idinfo/accconst, $institution)">
        <xsl:text>Restricted</xsl:text>
      </xsl:when>
      <xsl:when test="contains(idinfo/accconst, 'None')">
        <xsl:text>Public</xsl:text>
      </xsl:when>
      <xsl:when test="contains(idinfo/useconst, 'Restricted')">
        <xsl:text>Restricted</xsl:text>
      </xsl:when>
      <xsl:when test="contains(idinfo/useconst, $institution)">
        <xsl:text>Restricted</xsl:text>
      </xsl:when>
      <xsl:when test="contains(idinfo/useconst, 'None')">
        <xsl:text>Public</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>Restricted</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>",</xsl:text>

    <xsl:text>"dct_provenance_s": "</xsl:text>
    <xsl:value-of select="$institution"/>
    <xsl:text>",</xsl:text>

    <xsl:text>"dct_references_s": "</xsl:text>
      <xsl:text>{</xsl:text>
      <xsl:text>\"http://www.opengis.net/cat/csw/csdgm\":\"</xsl:text>
      <xsl:value-of select="$fgdc_base"/>
      <xsl:value-of select="translate($uuid, $lowercase, $uppercase)"/>
      <xsl:text>.xml\",</xsl:text>
      <xsl:text>\"http://www.opengis.net/def/serviceType/ogc/wms\":\"</xsl:text>
      <xsl:value-of select="$geoserver_root"/>
      <xsl:text>requestfile/wms\",</xsl:text>
      <xsl:text>\"http://www.opengis.net/def/serviceType/ogc/wfs\":\"</xsl:text>
      <xsl:value-of select="$geoserver_root"/>
      <xsl:text>requestfile/wfs\",</xsl:text>
       <xsl:text>\"http://schema.org/DownloadAction\":\"</xsl:text>
      <xsl:value-of select="$geoserver_root"/>
      <xsl:text>downloadfile\"</xsl:text>
      <xsl:text>}</xsl:text>
    <xsl:text>",</xsl:text>

    <xsl:text>"layer_id_s": "</xsl:text>
    <xsl:text>urn:</xsl:text>
    <xsl:value-of select="$uuid"/>
    <xsl:text>",</xsl:text>

    <xsl:text>"layer_slug_s": "</xsl:text>
    <xsl:value-of select="translate($institution, $uppercase, $lowercase)"/>
    <xsl:text>-</xsl:text>
    <xsl:value-of select="translate($uuid, $uppercase, $lowercase)"/>
    <xsl:text>",</xsl:text>

    <xsl:choose>
      <xsl:when test="contains(metadata/spdoinfo/ptvctinf/sdtsterm/sdtstype, 'G-polygon')">
        <xsl:text>"layer_geom_type_s": "</xsl:text>
        <xsl:text>Polygon</xsl:text>
        <xsl:text>",</xsl:text>
      </xsl:when>
      <xsl:when test="contains(metadata/spdoinfo/ptvctinf/sdtsterm/sdtstype, 'Entity point')">
        <xsl:text>"layer_geom_type_s": "</xsl:text>
        <xsl:text>Point</xsl:text>
        <xsl:text>",</xsl:text>
      </xsl:when>
      <xsl:when test="contains(metadata/spdoinfo/ptvctinf/sdtsterm/sdtstype, 'String')">
        <xsl:text>"layer_geom_type_s": "</xsl:text>
        <xsl:text>Line</xsl:text>
        <xsl:text>",</xsl:text>
      </xsl:when>
      <xsl:when test="contains(metadata/spdoinfo/direct, 'Raster')">
        <xsl:text>"layer_geom_type_s": "</xsl:text>
        <xsl:text>Raster</xsl:text>
        <xsl:text>",</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>"layer_geom_type_s": "</xsl:text>
        <xsl:text>Unknown</xsl:text>
        <xsl:text>",</xsl:text>
      </xsl:otherwise>
    </xsl:choose>

    <xsl:choose>
      <xsl:when test="string-length(metainfo/metd)=4">
        <xsl:text>"layer_modified_dt": "</xsl:text>
        <xsl:value-of select="metainfo/metd"/>
        <xsl:text>T00:00:00Z",</xsl:text>
      </xsl:when>

      <xsl:when test="string-length(metainfo/metd)=6">
        <xsl:text>"layer_modified_dt": "</xsl:text>
        <xsl:value-of select="substring(metainfo/metd,1,4)"/>
        <xsl:text>-</xsl:text>
        <xsl:value-of select="substring(metainfo/metd,5,2)"/>
        <xsl:text>T00:00:00Z",</xsl:text>
      </xsl:when>

      <xsl:when test="string-length(metainfo/metd)=8">
        <xsl:text>"layer_modified_dt": "</xsl:text>
        <xsl:value-of select="substring(metainfo/metd,1,4)"/>
        <xsl:text>-</xsl:text>
        <xsl:value-of select="substring(metainfo/metd,5,2)"/>
        <xsl:text>-</xsl:text>
        <xsl:value-of select="substring(metainfo/metd,7,2)"/>
        <xsl:text>T00:00:00Z",</xsl:text>
      </xsl:when>
    </xsl:choose>


    <xsl:if test="idinfo/citation/citeinfo/origin">
      <xsl:text>"dc_creator_sm": [</xsl:text>
      <xsl:for-each select="idinfo/citation/citeinfo/origin">
        <xsl:text>"</xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>"</xsl:text>
        <xsl:if test="position() != last()">
          <xsl:text>,</xsl:text>
        </xsl:if>
      </xsl:for-each>
      <xsl:text>],</xsl:text>
    </xsl:if>



    <xsl:if test="idinfo/citation/citeinfo/pubinfo/publish">
      <xsl:text>"dc_publisher_s": [</xsl:text>
      <xsl:for-each select="idinfo/citation/citeinfo/pubinfo/publish">
        <xsl:text>"</xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>"</xsl:text>
        <xsl:if test="position() != last()">
          <xsl:text>,</xsl:text>
        </xsl:if>
      </xsl:for-each>
      <xsl:text>],</xsl:text>
    </xsl:if>


    <xsl:text>"dc_format_s": "</xsl:text>
    <xsl:value-of select="$format"/>
    <xsl:text>",</xsl:text>

    <xsl:if test="contains(idinfo/descript/langdata, 'en')">
      <xsl:text>"dc_language_sm": "</xsl:text>
      <xsl:text>English</xsl:text>
      <xsl:text>",</xsl:text>
    </xsl:if>

    <!-- DCMI Type vocabulary: defaults to dataset -->
    <xsl:text>"dc_type_s": "</xsl:text>
    <xsl:text>Dataset</xsl:text>
    <xsl:text>",</xsl:text>


    <xsl:if test="idinfo/keywords/theme/themekey">
      <xsl:text>"dc_subject_sm": [</xsl:text>
      <xsl:for-each select="idinfo/keywords/theme/themekey">
        <xsl:if test="not(themekt = 'FGDC')">
          <xsl:text>"</xsl:text>
          <xsl:value-of select="."/>
          <xsl:text>"</xsl:text>
          <xsl:if test="position() != last()">
            <xsl:text>,</xsl:text>
          </xsl:if>
        </xsl:if>
      </xsl:for-each>
      <xsl:text>],</xsl:text>
    </xsl:if>

    <xsl:if test="idinfo/keywords/place/placekey">
      <xsl:text>"dct_spatial_sm": [</xsl:text>
      <xsl:for-each select="idinfo/keywords/place/placekey">
        <xsl:text>"</xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>"</xsl:text>
        <xsl:if test="position() != last()">
          <xsl:text>,</xsl:text>
        </xsl:if>
      </xsl:for-each>
      <xsl:text>],</xsl:text>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="string-length(idinfo/citation/citeinfo/pubdate)=4">
        <xsl:text>"dct_issued_s": "</xsl:text>
        <xsl:value-of select="idinfo/citation/citeinfo/pubdate"/>
        <xsl:text>",</xsl:text>
      </xsl:when>

      <xsl:when test="string-length(idinfo/citation/citeinfo/pubdate)=6">
        <xsl:text>"dct_issued_s": "</xsl:text>
        <xsl:value-of select="substring(idinfo/citation/citeinfo/pubdate,1,4)"/>
        <xsl:text>-</xsl:text>
        <xsl:value-of select="substring(idinfo/citation/citeinfo/pubdate,5,2)"/>
        <xsl:text>",</xsl:text>
      </xsl:when>

      <xsl:when test="string-length(idinfo/citation/citeinfo/pubdate)=8">
        <xsl:text>"dct_issued_s": "</xsl:text>
        <xsl:value-of select="substring(idinfo/citation/citeinfo/pubdate,1,4)"/>
        <xsl:text>-</xsl:text>
        <xsl:value-of select="substring(idinfo/citation/citeinfo/pubdate,5,2)"/>
        <xsl:text>-</xsl:text>
        <xsl:value-of select="substring(idinfo/citation/citeinfo/pubdate,7,2)"/>
        <xsl:text>",</xsl:text>
      </xsl:when>
    </xsl:choose>

    <!-- singular content date: YYYY -->

    <xsl:if test="idinfo/timeperd/timeinfo/sngdate/caldate">
      <xsl:text>"dct_temporal_sm": ["</xsl:text>
      <xsl:for-each select="idinfo/timeperd/timeinfo/sngdate/caldate">
        <xsl:value-of select="substring(.,1,4)"/>
        <xsl:if test="position() != last()">
          <xsl:text>"</xsl:text>
          <xsl:text>,</xsl:text>
        </xsl:if>
      </xsl:for-each>
      <xsl:text>"],</xsl:text>
    </xsl:if>

    <xsl:if test="idinfo/timeperd/timeinfo/mdattim/sngdate">
      <xsl:text>"dct_temporal_sm": ["</xsl:text>
      <xsl:for-each select="idinfo/timeperd/timeinfo/mdattim/sngdate">
        <xsl:value-of select="substring(.,1,4)"/>
        <xsl:if test="position() != last()">
          <xsl:text>"</xsl:text>
          <xsl:text>,"</xsl:text>
        </xsl:if>
      </xsl:for-each>
      <xsl:text>"],</xsl:text>
    </xsl:if>


    <!-- months, days YYYY-MM, YYYY-MM-DD
             <xsl:when test="string-length(idinfo/timeperd/timeinfo/sngdate/caldate)=4">
             <xsl:value-of select="idinfo/timeperd/timeinfo/sngdate/caldate"/>
             </xsl:when>
             <xsl:when test="string-length(idinfo/timeperd/timeinfo/sngdate/caldate)=6">
             <xsl:value-of select="substring(idinfo/timeperd/timeinfo/sngdate/caldate,1,4)"/>
             <xsl:text>-</xsl:text>
             <xsl:value-of select="substring(idinfo/timeperd/timeinfo/sngdate/caldate,5,2)"/>
             </xsl:when>
             <xsl:when test="string-length(idinfo/timeperd/timeinfo/sngdate/caldate)=8">
             <xsl:value-of select="substring(idinfo/timeperd/timeinfo/sngdate/caldate,1,4)"/>
             <xsl:text>-</xsl:text>
             <xsl:value-of select="substring(idinfo/timeperd/timeinfo/sngdate/caldate,5,2)"/>
             <xsl:text>-</xsl:text>
             <xsl:value-of select="substring(idinfo/timeperd/timeinfo/sngdate/caldate,7,2)"/>
             </xsl:when>  -->

    <!-- content date range: YYYY-YYYY if dates in range differ -->

    <xsl:if test="idinfo/timeperd/timeinfo/rngdates">
      <xsl:text>"dct_temporal_sm": ["</xsl:text>
      <xsl:for-each select="idinfo/timeperd/timeinfo/rngdates">
        <xsl:value-of select="substring(begdate, 1,4)"/>
        <xsl:if test="substring(begdate,1,4) != substring(enddate,1,4)">
          <xsl:text>-</xsl:text>
          <xsl:value-of select="substring(enddate,1,4)"/>
        </xsl:if>
        <xsl:if test="position() != last()">
          <xsl:text>"</xsl:text>
          <xsl:text>,"</xsl:text>
        </xsl:if>
      </xsl:for-each>
      <xsl:text>"],</xsl:text>
    </xsl:if>

    <xsl:if test="idinfo/keywords/temporal/tempkey">
      <xsl:if test="text() != substring(idinfo/timeperd/timeinfo/sngdate/caldate,1,4)">
        <xsl:text>"dct_temporal_sm": ["</xsl:text>
        <xsl:for-each select="idinfo/keywords/temporal/tempkey">
          <xsl:value-of select="."/>
          <xsl:if test="position() != last()">
            <xsl:text>"</xsl:text>
            <xsl:text>,"</xsl:text>
          </xsl:if>
        </xsl:for-each>
        <xsl:text>"],</xsl:text>
      </xsl:if>
    </xsl:if>

    <!-- collection -->

    <xsl:if test="idinfo/citation/citeinfo/lworkcit/citeinfo/title">
      <xsl:choose>
        <xsl:when test="idinfo/citation/citeinfo/lworkcit/citeinfo/serinfo/sername">
          <xsl:text>"dct_isPartOf_sm": [</xsl:text>
          <xsl:for-each select="idinfo/citation/citeinfo/lworkcit/citeinfo | idinfo/citation/citeinfo/lworkcit/citeinfo/serinfo">
            <xsl:text>"</xsl:text>
            <xsl:value-of select="title | sername"/>
            <xsl:text>"</xsl:text>
              <xsl:if test="position() != last()">
                <xsl:text>,</xsl:text>
              </xsl:if>
          </xsl:for-each>
          <xsl:text>],</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>"dct_isPartOf_sm": [</xsl:text>
          <xsl:for-each select="idinfo/citation/citeinfo/lworkcit/citeinfo">
            <xsl:text>"</xsl:text>
            <xsl:value-of select="title"/>
            <xsl:text>"</xsl:text>
              <xsl:if test="position() != last()">
                <xsl:text>,</xsl:text>
              </xsl:if>
          </xsl:for-each>
          <xsl:text>],</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>

    <xsl:text>"solr_geom": "ENVELOPE(</xsl:text>
    <xsl:value-of select="$x1"/>
    <xsl:text>, </xsl:text>
    <xsl:value-of select="$x2"/>
    <xsl:text>, </xsl:text>
    <xsl:value-of select="$y2"/>
    <xsl:text>, </xsl:text>
    <xsl:value-of select="$y1"/>
    <xsl:text>)",</xsl:text>

    <!-- content date for solr year: choose singular, or beginning date of range: YYYY -->
    <xsl:if test="idinfo/timeperd/timeinfo">
      <xsl:choose>
        <xsl:when test="(idinfo/timeperd/timeinfo/sngdate/caldate/text() != '') and (string(number(idinfo/timeperd/timeinfo/sngdate/caldate)) != 'NaN')">
          <xsl:text>"solr_year_i": </xsl:text>
          <xsl:value-of select="format-number(substring(idinfo/timeperd/timeinfo/sngdate/caldate,1,4), 0)"/>
        </xsl:when>

        <xsl:when test="(idinfo/timeperd/timeinfo/mdattim/sngdate/caldate/text() != '') and (string(number(idinfo/timeperd/timeinfo/mdattim/sngdate/caldate)) != 'NaN')">
          <xsl:if test="position() = 1">
            <xsl:text>"solr_year_i": </xsl:text>
            <xsl:value-of select="format-number(substring(idinfo/timeperd/timeinfo/mdattim/sngdate/caldate,1,4), 0)"/>
          </xsl:if>
        </xsl:when>

        <xsl:when test="(idinfo/timeperd/timeinfo/rngdates/begdate/text() != '') and (string(number(idinfo/timeperd/timeinfo/rngdates/begdate)) != 'NaN')">
          <xsl:if test="position() = 1">
            <xsl:text>"solr_year_i": </xsl:text>
            <xsl:value-of select="format-number(substring(idinfo/timeperd/timeinfo/rngdates/begdate, 1,4), 0)"/>
          </xsl:if>
        </xsl:when>

        <xsl:when test="//metadata/idinfo/keywords/temporal/tempkey/text() != '' and (string(number(//metadata/idinfo/keywords/temporal/tempkey)) != 'NaN')">
          <xsl:for-each select="//metadata/idinfo/keywords/temporal/tempkey[1]">
            <xsl:if test="text() != ''">
              <xsl:text>"solr_year_i": </xsl:text>
              <xsl:value-of select="format-number(., 0)"/>
            </xsl:if>
          </xsl:for-each>
        </xsl:when>

        <!-- currently the schema is built so one has to have a solr_year_i setting to a non real value for cleanup-->
        <xsl:otherwise>
          <xsl:text>"solr_year_i": 9999</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>

    <xsl:text>}</xsl:text>
   </xsl:template>
</xsl:stylesheet>
