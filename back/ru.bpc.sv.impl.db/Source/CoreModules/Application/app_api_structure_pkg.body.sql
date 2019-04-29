create or replace package body app_api_structure_pkg as
/*******************************************************************
*  API for application's structure <br />
*  Created by Filimonov A.(filimonov@bpc.ru)  at 01.01.2010 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: app_api_structure_pkg <br />
*  @headcom
******************************************************************/

XSD_HEADER          constant    com_api_type_pkg.t_full_desc :=
com_api_const_pkg.XML_HEADER||chr(10)||
'<schema xmlns="http://www.w3.org/2001/XMLSchema" 
        targetNamespace="' || app_api_const_pkg.APPL_XMLNS || '" 
        xmlns:tns="' || app_api_const_pkg.APPL_XMLNS || '" 
        elementFormDefault="qualified">';

XSD_FOOTER          constant    com_api_type_pkg.t_full_desc := '</schema>';

COMPLEX_TYPE_HEADER constant    com_api_type_pkg.t_full_desc := '<complexType name=":type_name">';

COMPLEX_TYPE_FOOTER constant    com_api_type_pkg.t_full_desc := '
        <attribute name="id" use="required">
            <simpleType>
                <restriction base="string">
                    <maxLength value="200"></maxLength>
                </restriction>
            </simpleType>
        </attribute>

    </complexType>';

SIMPLE_TYPE_HEADER  constant    com_api_type_pkg.t_full_desc := '<simpleType>';

SIMPLE_TYPE_FOOTER  constant    com_api_type_pkg.t_full_desc := '</simpleType>';

SIMPLE_CONT_HEADER  constant    com_api_type_pkg.t_full_desc := '<simpleContent>';

SIMPLE_CONT_FOOTER  constant    com_api_type_pkg.t_full_desc := '</simpleContent>';

EXTENSION_HEADER    constant    com_api_type_pkg.t_full_desc := '<extension base=":type_name">';

EXTENSION_FOOTER    constant    com_api_type_pkg.t_full_desc := '</extension>';

SEQUENCE_HEADER     constant    com_api_type_pkg.t_full_desc := '<sequence>';

SEQUENCE_FOOTER     constant    com_api_type_pkg.t_full_desc := '</sequence>';

ELEMENT_HEADER      constant    com_api_type_pkg.t_full_desc := '<element name=":element_name":type_name:min_occurs:max_occurs>';

ELEMENT_FOOTER      constant    com_api_type_pkg.t_full_desc := '</element>';

TYPE_NAME           constant    com_api_type_pkg.t_full_desc := ' type="tns::type_name"';

MIN_OCCURS          constant    com_api_type_pkg.t_full_desc := ' minOccurs=":min_occurs"';

MAX_OCCURS          constant    com_api_type_pkg.t_full_desc := ' maxOccurs=":max_occurs"';

RESTRICTION_HEADER  constant    com_api_type_pkg.t_full_desc := '<restriction base=":type_name">';

RESTRICTION_FOOTER  constant    com_api_type_pkg.t_full_desc := '</restriction>';

MIN_LENGTH          constant    com_api_type_pkg.t_full_desc := '<minLength value=":length_value"></minLength>';

MAX_LENGTH          constant    com_api_type_pkg.t_full_desc := '<maxLength value=":length_value"></maxLength>';

MIN_INCLUSIVE       constant    com_api_type_pkg.t_full_desc := '<minInclusive value=":min_value"></minInclusive>';

MAX_INCLUSIVE       constant    com_api_type_pkg.t_full_desc := '<maxInclusive value=":max_value"></maxInclusive>';

LANGUAGE_ATTR       constant    com_api_type_pkg.t_full_desc := '<attribute name="language" type="string" default="LANGENG"></attribute>';

ENTITY_NAME_TYPE    constant    com_api_type_pkg.t_full_desc := 'tns:entity_name';

ENTITY_DESC_TYPE    constant    com_api_type_pkg.t_full_desc := 'tns:entity_desc';

APPLICATIONS_ELEMENT constant   com_api_type_pkg.t_full_desc :=
'    <element name="applications" type="tns:applications"></element>

    <complexType name="applications">
        <sequence maxOccurs="unbounded" minOccurs="1">
            <element name="application" type="tns:application"></element>
        </sequence>
    </complexType>

    <simpleType name="entity_name">
        <restriction base="string">
            <maxLength value="200"></maxLength>
        </restriction>
    </simpleType>

    <simpleType name="entity_desc">
        <restriction base="string">
            <maxLength value="2000"></maxLength>
        </restriction>
    </simpleType>
';


procedure generate_xsd(
    i_appl_type         in       com_api_type_pkg.t_dict_value
  , i_flow_id           in       com_api_type_pkg.t_tiny_id     default null    
) is
    l_xsd_source        clob;
    l_offset_level      pls_integer := 0;
    l_line              com_api_type_pkg.t_full_desc;
    l_type_name         com_api_type_pkg.t_name;
    l_filter_present    pls_integer := 0;
    function offset return varchar2 is
    begin
        return lpad(' ', 4 * l_offset_level);
    end;
begin

    dbms_lob.createtemporary(l_xsd_source, true);

    l_line := XSD_HEADER||chr(10);
    dbms_lob.writeappend(l_xsd_source, length(l_line), l_line);

    for r in (
      select name
           , element_type
           , id
           , is_multilang
           , display_order
        from (
        select x.name
             , x.element_type
             , x.id
             , x.is_multilang
             , x.display_order
             , x.p
             , row_number() over(partition by name order by lvl ) rn 
        from (
          select distinct
                 a.name
               , a.element_type
               , a.element_id as id
               , a.is_multilang
               , a.display_order
               , sys_connect_by_path(
                     case when element_type = 'COMPLEX' then lpad(to_char(display_order,'TM9'),3,'0') end,'/'
                 ) p
               , level lvl
            from app_ui_structure_vw a , (select i_appl_type  app_type from dual) x
           where appl_type      = x.app_type 
             and lang           = 'LANGENG'
             and a.element_type = 'COMPLEX'
        connect by nocycle prior element_id = parent_element_id 
                        and prior appl_type =  x.app_type 
                         and a.element_type = 'COMPLEX'
        start with appl_type =  x.app_type
          and element_id in (select x.id from app_element x where x.name = 'APPLICATION' )
        ) x
      )
      where rn = 1
      order by p, display_order
    ) loop
        l_offset_level := l_offset_level + 1;

        l_line := offset||replace(COMPLEX_TYPE_HEADER, ':type_name', lower(r.name))||chr(10);
        dbms_lob.writeappend(l_xsd_source, length(l_line), l_line);
        l_offset_level := l_offset_level + 1;

        l_line := offset||SEQUENCE_HEADER||chr(10);
        dbms_lob.writeappend(l_xsd_source, length(l_line), l_line);

        for p in (
            select e.name
                 , e.element_type
                 , s.min_count
                 , s.max_count
                 , case when e.data_type = com_api_const_pkg.DATA_TYPE_CHAR then 'string'
                        when e.data_type = com_api_const_pkg.DATA_TYPE_NUMBER and greatest(nvl(e.max_length,0), nvl(length(e.max_value),0)) > 16 then 'float'
                        when e.data_type = com_api_const_pkg.DATA_TYPE_NUMBER and greatest(nvl(e.max_length,0), nvl(length(e.max_value),0)) > 8  then 'long'
                        when e.data_type = com_api_const_pkg.DATA_TYPE_NUMBER then 'int'
                        when e.data_type = com_api_const_pkg.DATA_TYPE_DATE then 'date'
                        else 'string'
                   end data_type
                 , e.min_value
                 , e.max_value
                 , e.min_length
                 , e.max_length
                 , e.is_multilang
                 , nvl(s.lov_id, e.lov_id) lov_id
                 , s.id struct_id
                 , nvl(s.default_value, e.default_value) as default_value
                 , 1 is_updatable
              from app_element_all_vw e
                 , app_structure s
             where s.appl_type         = i_appl_type
               and s.element_id        = e.id
               and s.parent_element_id = r.id
             order by s.display_order
        ) loop
            l_offset_level := l_offset_level + 1;
            
            if  i_flow_id is not null then
                select count(1)
                    into    l_filter_present
                    from app_flow_filter ff join app_flow_stage fs on (ff.stage_id = fs.id)
                    where fs.appl_status = 'APST0001' 
                      and flow_id = i_flow_id
                      and struct_id = p.struct_id;
                      
                if l_filter_present > 0 then  
                    select f.min_count
                         , f.max_count
                         , f.default_value
                         , f.is_updatable
                      into p.min_count
                         , p.max_count
                         , p.default_value
                         , p.is_updatable
                      from app_flow_filter f 
                         , app_flow_stage s 
                     where s.appl_status = 'APST0001'
                       and f.stage_id    = s.id 
                       and s.flow_id     = i_flow_id
                       and f.struct_id   = p.struct_id;
                end if;
            end if;        
            
            if p.element_type = app_api_const_pkg.APPL_ELEMENT_TYPE_COMPLEX then

                l_line := replace(ELEMENT_HEADER, ':element_name', lower(p.name));
                l_line := replace(l_line, ':type_name', replace(TYPE_NAME, ':type_name', lower(p.name)));
                if p.min_count is null then
                    l_line := offset||replace(l_line, ':min_occurs', '');
                else
                    l_line := offset||replace(l_line, ':min_occurs', replace(MIN_OCCURS, ':min_occurs', p.min_count));
                end if;
                if p.max_count is null then
                    l_line := replace(l_line, ':max_occurs', '');
                else
                    l_line := replace(l_line, ':max_occurs', replace(MAX_OCCURS, ':max_occurs', replace(p.max_count, '999', 'unbounded')));
                end if;
                l_line := l_line||ELEMENT_FOOTER||chr(10)||chr(10);
                dbms_lob.writeappend(l_xsd_source, length(l_line), l_line);

            elsif p.element_type = app_api_const_pkg.APPL_ELEMENT_TYPE_SIMPLE then

                l_line := replace(ELEMENT_HEADER, ':element_name', lower(p.name));
                if p.data_type = 'date' then
                    l_line := replace(l_line, ':type_name', replace(TYPE_NAME, 'tns::type_name', p.data_type));
                else
                    l_line := replace(l_line, ':type_name', '');
                end if;

                if p.min_count is null then
                    l_line := offset||replace(l_line, ':min_occurs', '');
                else
                    l_line := offset||replace(l_line, ':min_occurs', replace(MIN_OCCURS, ':min_occurs', p.min_count));
                end if;
                if p.max_count is null then
                    l_line := replace(l_line, ':max_occurs', '')||case p.data_type when 'date' then '' else chr(10) end;
                else
                    l_line := replace(l_line, ':max_occurs', replace(MAX_OCCURS, ':max_occurs', replace(p.max_count, '999', 'unbounded')))
                      ||case p.data_type when 'date' then '' else chr(10) end;
                end if;

                dbms_lob.writeappend(l_xsd_source, length(l_line), l_line);


                if p.data_type = 'string' then

                    if p.is_multilang = com_api_const_pkg.TRUE then
                        l_offset_level := l_offset_level + 1;
                        l_line := offset||'<complexType>'||chr(10);
                        dbms_lob.writeappend(l_xsd_source, length(l_line), l_line);

                        l_offset_level := l_offset_level + 1;
                        l_line := offset||SIMPLE_CONT_HEADER||chr(10);
                        dbms_lob.writeappend(l_xsd_source, length(l_line), l_line);

                        if p.max_length < 2000 then
                            l_type_name := ENTITY_NAME_TYPE;
                        else
                            l_type_name := ENTITY_DESC_TYPE;
                        end if;

                        l_offset_level := l_offset_level + 1;
                        l_line := offset||replace(EXTENSION_HEADER, ':type_name', l_type_name)||chr(10);
                        dbms_lob.writeappend(l_xsd_source, length(l_line), l_line);

                        l_offset_level := l_offset_level + 1;
                        l_line := offset||LANGUAGE_ATTR||chr(10);
                        dbms_lob.writeappend(l_xsd_source, length(l_line), l_line);
                        l_offset_level := l_offset_level - 1;

                        l_line := offset||EXTENSION_FOOTER||chr(10);
                        dbms_lob.writeappend(l_xsd_source, length(l_line), l_line);
                        l_offset_level := l_offset_level - 1;

                        l_line := offset||SIMPLE_CONT_FOOTER||chr(10);
                        dbms_lob.writeappend(l_xsd_source, length(l_line), l_line);
                        l_offset_level := l_offset_level - 1;

                        l_line := offset||'</complexType>'||chr(10);
                        dbms_lob.writeappend(l_xsd_source, length(l_line), l_line);
                        l_offset_level := l_offset_level - 1;
                    else
                        l_offset_level := l_offset_level + 1;
                        l_line := offset||SIMPLE_TYPE_HEADER||chr(10);
                        dbms_lob.writeappend(l_xsd_source, length(l_line), l_line);

                        l_offset_level := l_offset_level + 1;
                        l_line := offset||replace(RESTRICTION_HEADER, ':type_name', p.data_type)||chr(10);
                        dbms_lob.writeappend(l_xsd_source, length(l_line), l_line);

                        l_offset_level := l_offset_level + 1;
                        if p.min_length is not null then
                            l_line := offset||replace(MIN_LENGTH, ':length_value', p.min_length)||chr(10);
                            dbms_lob.writeappend(l_xsd_source, length(l_line), l_line);
                        end if;
                        if p.max_length is not null then
                            l_line := offset||replace(MAX_LENGTH, ':length_value', p.max_length)||chr(10);
                            dbms_lob.writeappend(l_xsd_source, length(l_line), l_line);
                        end if;

                        if p.lov_id is not null then
                            for q in (
                                select a.dict||a.code code
                                     , get_text (i_table_name   => 'com_dictionary'
                                               , i_column_name  => 'name'
                                               , i_object_id    => a.id
                                               , i_lang         => 'LANGENG')
                                       as name
                                  from com_dictionary a
                                     , com_lov b
                                 where a.dict = b.dict
                                   and b.id   = p.lov_id
                                   and ((p.is_updatable = 0 and a.dict||a.code = p.default_value) or ( p.is_updatable != 0))
                                   and ((p.name = 'APPLICATION_TYPE' and a.dict || a.code = i_appl_type) or (p.name != 'APPLICATION_TYPE'))
                                 order by a.code
                            )loop
                                l_line := offset||'<enumeration value="'||q.code||'"><!-- '||q.name||' --></enumeration>'||chr(10);
                                dbms_lob.writeappend(l_xsd_source, length(l_line), l_line);
                            end loop;
                        end if;
                        l_offset_level := l_offset_level - 1;

                        l_line := offset||RESTRICTION_FOOTER||chr(10);
                        dbms_lob.writeappend(l_xsd_source, length(l_line), l_line);
                        l_offset_level := l_offset_level - 1;

                        l_line := offset||SIMPLE_TYPE_FOOTER||chr(10);
                        dbms_lob.writeappend(l_xsd_source, length(l_line), l_line);
                        l_offset_level := l_offset_level - 1;
                    end if;

                elsif p.data_type in ('int', 'float', 'long') then

                    l_offset_level := l_offset_level + 1;
                    l_line := offset||SIMPLE_TYPE_HEADER||chr(10);
                    dbms_lob.writeappend(l_xsd_source, length(l_line), l_line);

                    l_offset_level := l_offset_level + 1;
                    l_line := offset||replace(RESTRICTION_HEADER, ':type_name', p.data_type)||chr(10);
                    dbms_lob.writeappend(l_xsd_source, length(l_line), l_line);

                    l_offset_level := l_offset_level + 1;
                    if p.min_value is not null then
                        l_line := offset||replace(MIN_INCLUSIVE, ':min_value', p.min_value)||chr(10);
                        dbms_lob.writeappend(l_xsd_source, length(l_line), l_line);
                    end if;
                    if p.max_value is not null then
                        l_line := offset||replace(MAX_INCLUSIVE, ':max_value', p.max_value)||chr(10);
                        dbms_lob.writeappend(l_xsd_source, length(l_line), l_line);
                    end if;
                    l_offset_level := l_offset_level - 1;

                    l_line := offset||RESTRICTION_FOOTER||chr(10);
                    dbms_lob.writeappend(l_xsd_source, length(l_line), l_line);
                    l_offset_level := l_offset_level - 1;

                    l_line := offset||SIMPLE_TYPE_FOOTER||chr(10);
                    dbms_lob.writeappend(l_xsd_source, length(l_line), l_line);
                    l_offset_level := l_offset_level - 1;

                else
                    null;
                end if;

                l_line := case p.data_type when 'date' then '' else offset end||ELEMENT_FOOTER||chr(10)||chr(10);
                dbms_lob.writeappend(l_xsd_source, length(l_line), l_line);

            else
                null;
            end if;
            l_offset_level := l_offset_level - 1;

        end loop;

        l_line := offset||SEQUENCE_FOOTER||chr(10);
        dbms_lob.writeappend(l_xsd_source, length(l_line), l_line);

        if r.is_multilang = com_api_const_pkg.TRUE then
            l_line := offset||LANGUAGE_ATTR||chr(10);
            dbms_lob.writeappend(l_xsd_source, length(l_line), l_line);
        end if;

        l_offset_level := l_offset_level - 1;

        l_line := offset||COMPLEX_TYPE_FOOTER||chr(10)||chr(10);
        dbms_lob.writeappend(l_xsd_source, length(l_line), l_line);
        l_offset_level := l_offset_level - 1;

    end loop;

    dbms_lob.writeappend(l_xsd_source, length(APPLICATIONS_ELEMENT), APPLICATIONS_ELEMENT);

    l_line := XSD_FOOTER;
    dbms_lob.writeappend(l_xsd_source, length(l_line), l_line);

    if i_flow_id is null then
        update app_type set xsd_source = l_xsd_source where appl_type = i_appl_type;
    else 
        update app_flow set xsd_source = l_xsd_source where id = i_flow_id;
    end if;

    dbms_lob.freetemporary(l_xsd_source);
end generate_xsd;

function element_exists(
    i_appl_type         in       com_api_type_pkg.t_dict_value
  , i_element_id        in       com_api_type_pkg.t_short_id
  , i_parent_element_id in       com_api_type_pkg.t_short_id    default null
) return com_api_type_pkg.t_boolean
is
    l_id                         com_api_type_pkg.t_short_id;
begin
    begin
        select s.id
          into l_id
          from app_structure s
         where s.appl_type  = i_appl_type
           and s.element_id = i_element_id
           and (i_parent_element_id is null or s.parent_element_id = i_parent_element_id)
           and rownum       = 1;
    exception
        when no_data_found then
            null;
    end;

    return case
               when l_id is null
               then com_api_const_pkg.FALSE
               else com_api_const_pkg.TRUE
           end;
end element_exists;

end;
/