create or replace package body prd_api_report_pkg is
/*********************************************************
 *  Product reports API <br />
 *  Created by Madan B.(madan@bpcbt.com) at 02.04.2014 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate$ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: prd_api_report_pkg <br />
 *  @headcom
 **********************************************************/

/**************************************************
 *
 * It prepares data for a landscape report for the structure
 * of products and all their inclusives: services and attributes.
 *
 * @param o_xml        Data - source for report
 * @param i_inst_id    Filter for institute
 * @param i_product_id Start with this product
 * @param i_status     Filter for product status
 * @param i_lang       Language
 *
 ***************************************************/
procedure product_structure (
    o_xml            out clob
    , i_inst_id      in com_api_type_pkg.t_inst_id
    , i_product_id   in com_api_type_pkg.t_short_id    default null
    , i_status       in com_api_type_pkg.t_dict_value  default null
    , i_lang         in com_api_type_pkg.t_dict_value  default null
) is
    XML_NULL  constant  com_api_type_pkg.t_name        := chr(38) || '#8212;';
    XML_DASH  constant  com_api_type_pkg.t_name        := chr(38) || '#8211;';
    XML_SPACE constant  com_api_type_pkg.t_name        := ' ';
    DT_FORMAT constant  com_api_type_pkg.t_name        := 'yyyy-mm-dd hh24:mi:ss';

    type type_hierarchy_rec is record (
        id              com_api_type_pkg.t_long_id
      , num             com_api_type_pkg.t_name
      , level           pls_integer
      , name            com_api_type_pkg.t_full_desc
    );
    type type_hierarchy_tbl is table of type_hierarchy_rec;

    l_lang              com_api_type_pkg.t_dict_value;
    l_charset           com_api_type_pkg.t_name;
    l_result            clob;
    l_prod_hierarchy    type_hierarchy_tbl             := type_hierarchy_tbl();

    l_product_id        prd_product.id%type;
    l_service_id        prd_service.id%type;

    l_yes               com_api_type_pkg.t_name;
    l_no                com_api_type_pkg.t_name;

------------------------------------------------------------
procedure add_data (
    i_str  in  com_api_type_pkg.t_lob_data
) is
begin
    if i_str is not null then
        dbms_lob.writeappend(l_result, length(i_str), i_str);
    end if;
end add_data;

------------------------------------------------------------
procedure close_tags (
    i_level  in  com_api_type_pkg.t_name
) is
begin
    if upper(i_level) in ('SERVICE', 'PRODUCT', 'ALL')
      and l_service_id is not null then
        l_service_id := null;
    end if;
    if upper(i_level) = 'ALL' then
        pragma inline (add_data, 'YES'); add_data('</body></report>');
    end if;
end close_tags;

------------------------------------------------------------
procedure add_report
is
    l_str           com_api_type_pkg.t_lob_data;
    l_product_name  com_api_type_pkg.t_name;
begin
    if i_product_id is not null then
        select
            product_number || ' ' || XML_DASH || ' ' || product_name
        into
            l_product_name
        from (
            select
                label as product_name
              , product_number
              , row_number() over (partition by id
                                       order by decode(lang, l_lang, 0, com_api_const_pkg.LANGUAGE_ENGLISH, 1, 2)) as rn
            from
                prd_ui_product_vw
            where
                id = i_product_id
        ) where
            rn = 1;
    end if;
    l_str := '<report><header>'                                             ||
    '<report_name>Report for SmartVista product''s structure</report_name>' ||
    '<report_inst>' || i_inst_id || '</report_inst>'                        ||
    '<report_parent_prod>'                                                  ||
    nvl(l_product_name, XML_NULL)                                           ||
    '</report_parent_prod>'                                                 ||
    '<report_prod_status>'                                                  ||
    case
        when i_status is null then
            'all'
        when i_status = prd_api_const_pkg.PRODUCT_STATUS_ACTIVE then
            'only active'
        when i_status = prd_api_const_pkg.PRODUCT_STATUS_INACTIVE then
            'only inactive'
        else
            'unknown'
    end                                                                     ||
    '</report_prod_status>'                                                 ||
    '</header><body>';
    pragma inline (add_data, 'YES'); add_data(l_str);
end add_report;

------------------------------------------------------------
procedure add_product (
    i_id             in  prd_product.id%type
  , i_number         in  prd_product.product_number%type
  , i_name           in  com_api_type_pkg.t_name
  , i_status         in  com_api_type_pkg.t_name
  , i_type           in  com_api_type_pkg.t_name
  , i_contract_type  in  com_api_type_pkg.t_name
  , i_level          in  pls_integer
) is
    l_str            com_api_type_pkg.t_lob_data;
    l_path           com_api_type_pkg.t_lob_data;
    l_parents_count  simple_integer := 0;
begin
    close_tags('PRODUCT');
    if l_prod_hierarchy.count > 0 then
        for i in reverse 1 .. l_prod_hierarchy.count loop
            if l_prod_hierarchy(i).level >= i_level then
                l_prod_hierarchy.trim;
            else
                exit;
            end if;
        end loop;
    end if;
    l_prod_hierarchy.extend(1);
    l_prod_hierarchy(l_prod_hierarchy.count).id    := i_id;
    l_prod_hierarchy(l_prod_hierarchy.count).num   := i_number;
    l_prod_hierarchy(l_prod_hierarchy.count).level := i_level;
    l_prod_hierarchy(l_prod_hierarchy.count).name  := i_name;
    if l_prod_hierarchy.count > 0 then
        for i in reverse 1 .. l_prod_hierarchy.count loop
            if l_prod_hierarchy(i).level < i_level then
                if l_parents_count > 0 then
                    l_path := ' \ ' || l_path;
                end if;
                l_path := l_prod_hierarchy(i).num || ' ' || XML_DASH || ' ' || l_prod_hierarchy(i).name || l_path;
                l_parents_count := l_parents_count + 1;
            end if;
        end loop;
    end if;
    l_str := '<row type="filler"><column1></column1></row>';
    l_str := l_str || '<row type="col_names">'
          || '<column1>Number:</column1>'
          || '<column2>Name:</column2>'
          || '<column3>Product type:</column3>'
          || '<column4>Contract type:</column4>'
          || '<column5>Parents:</column5>'
          || '<column6>Status:</column6>'
          || '</row>';
    l_str := l_str || '<row type="product">'
          || '<column1>' || i_number || '</column1>'
          || '<column2 style="bold">' || i_name || '</column2>'
          || '<column3>' || i_type   || '</column3>'
          || '<column4>' || i_contract_type || '</column4>'
          || '<column5>' || l_path   || '</column5>'
          || '<column6>' || i_status || '</column6>'
          || '</row>';
    pragma inline (add_data, 'YES');
    add_data(l_str);
    l_product_id := i_id;
end add_product;

------------------------------------------------------------
procedure add_service (
    i_id         in  prd_service.id%type
  , i_number     in  prd_service.service_number%type
  , i_name       in  com_api_type_pkg.t_name
  , i_min        in  prd_product_service.min_count%type
  , i_max        in  prd_product_service.max_count%type
) is
    l_str        com_api_type_pkg.t_lob_data;
    l_mandatory  com_api_type_pkg.t_name;
begin
    close_tags('SERVICE');
    if nvl(i_min, 0) > 0 then
        l_mandatory := l_yes;
    else
        l_mandatory := l_no;
    end if;
    l_str := '<row type="col_names">'
          || '<column1>Number:</column1>'
          || '<column2>Name:</column2>'
          || '<column3>Min ' || XML_DASH || ' max occurrences:</column3>'
          || '<column4>Mandatory:</column4>'
          || '</row>';
    l_str := l_str || '<row type="service">'
          || '<column1>' || i_number || '</column1>'
          || '<column2 style="bold">' || i_name || '</column2>'
          || '<column3>' || i_min || ' ' || XML_DASH || ' ' || i_max || '</column3>'
          || '<column4>' || l_mandatory || '</column4>'
          || '</row>';
    l_str := l_str || '<row type="col_names">'
          || '<column1>ID:</column1>'
          || '<column2>(Type) Name:</column2>'
          || '<column3>Definition level:</column3>'
          || '<column4>Modificator:</column4>'
          || '<column5>Value:</column5>'
          || '<column6>Date from:</column6>'
          || '<column7>Date to:</column7>'
          || '<column8>Inherited from:</column8>'
          || '</row>';
    pragma inline (add_data, 'YES');
    add_data(l_str);
    l_service_id := i_id;
end add_service;

------------------------------------------------------------
procedure add_attr_group (
    i_name       in  com_api_type_pkg.t_name
  , i_type       in  com_api_type_pkg.t_name
) is
    l_str        com_api_type_pkg.t_lob_data;
    l_name       com_api_type_pkg.t_name;
begin
    close_tags('ATTR_GROUP');
    if i_type = 'SUBGROUP_NAME' then
        l_name := XML_SPACE || XML_SPACE || XML_SPACE || XML_DASH || XML_SPACE || i_name;
    else
        l_name := i_name;
    end if;
    l_str := '<row type="attr_group">'
          || '<column1>' || l_name || '</column1>'
          || '</row>';
    pragma inline (add_data, 'YES');
    add_data(l_str);
end add_attr_group;

------------------------------------------------------------
procedure add_attribute (
    i_id                in  prd_attribute.id%type
  , i_prev_id           in  prd_attribute.id%type
  , i_next_id           in  prd_attribute.id%type
  , i_type              in  com_api_type_pkg.t_name
  , i_name              in  com_api_type_pkg.t_name
  , i_definition_level  in  com_api_type_pkg.t_name
  , i_mod_name          in  com_api_type_pkg.t_name
  , i_value             in  com_api_type_pkg.t_raw_data
  , i_data_type         in  com_api_type_pkg.t_dict_value
  , i_start_date        in  date
  , i_end_date          in  date
  , i_lov_id            in  com_api_type_pkg.t_short_id
  , i_src_type          in  com_api_type_pkg.t_dict_value
  , i_src_id            in  com_api_type_pkg.t_long_id
  , i_orig_type         in  com_api_type_pkg.t_dict_value
  , i_src_name          in  com_api_type_pkg.t_name
  , i_actuality         in  com_api_type_pkg.t_short_id
) is
    l_str        com_api_type_pkg.t_lob_data;
    l_row_type   com_api_type_pkg.t_name;
    l_parent     com_api_type_pkg.t_name;
    l_value      com_api_type_pkg.t_lob_data;
    l_style      com_api_type_pkg.t_name;
begin
    case
        when nvl(i_prev_id, 0) <> nvl(i_id, 0) and nvl(i_next_id, 0)  = nvl(i_id, 0) then
            l_row_type := 'attr_first';
        when nvl(i_prev_id, 0)  = nvl(i_id, 0) and nvl(i_next_id, 0)  = nvl(i_id, 0) then
            l_row_type := 'attr_grouped';
        when nvl(i_prev_id, 0)  = nvl(i_id, 0) and nvl(i_next_id, 0) <> nvl(i_id, 0) then
            l_row_type := 'attr_last';
        else
            l_row_type := 'attr';
    end case;

    if l_row_type in ('attr', 'attr_first') then
        l_str := '<row type="' || l_row_type || '">'
              || '<column1>' || i_id || '</column1>'
              || '<column2>(' || i_type || ') ' || i_name || '</column2>'
              || '<column3>' || i_definition_level || '</column3>';
    else
        l_str := '<row type="' || l_row_type || '">';
    end if;

    if i_orig_type = fcl_api_const_pkg.ENTITY_TYPE_FEE then
        l_value := fcl_ui_fee_pkg.get_fee_desc(i_value);
    elsif i_orig_type = fcl_api_const_pkg.ENTITY_TYPE_CYCLE then
        l_value := fcl_ui_cycle_pkg.get_cycle_desc(i_value);
    elsif i_orig_type = fcl_api_const_pkg.ENTITY_TYPE_LIMIT then
        l_value := fcl_ui_limit_pkg.get_limit_desc(i_value);
    else
        if i_lov_id is not null then
            l_value := nvl(com_api_type_pkg.get_lov_value(i_data_type, i_value, i_lov_id), i_value);
        else
            l_value := i_value;
        end if;
    end if;
    if (i_src_id is not null and i_src_type is not null)
       and ((i_src_type = prd_api_const_pkg.ENTITY_TYPE_PRODUCT and l_product_id <> i_src_id)
         or (i_src_type = prd_api_const_pkg.ENTITY_TYPE_SERVICE)) then
        l_parent := case
                        when i_src_type = prd_api_const_pkg.ENTITY_TYPE_PRODUCT then
                            '(P)'
                        when i_src_type = prd_api_const_pkg.ENTITY_TYPE_SERVICE then
                            '(S)'
                        else
                            '(?)'
                    end
                 || ' ' || i_src_name;
    end if;

    if nvl(i_end_date, sysdate) < sysdate then
        l_style := ' style="legacy"';
    elsif nvl(i_start_date, sysdate) > sysdate then
        l_style := ' style="in_future"';
    elsif i_actuality > 1 then
        l_style := ' style="not_active"';
    end if;

    l_str := l_str
          || '<column4' || l_style || '>' || i_mod_name || '</column4>'
          || '<column5' || l_style || '>' || l_value || '</column5>'
          || '<column6' || l_style || '>' || to_char(i_start_date, com_api_const_pkg.XML_DATE_FORMAT) || '</column6>'
          || '<column7' || l_style || '>' || to_char(i_end_date, com_api_const_pkg.XML_DATE_FORMAT) || '</column7>'
          || '<column8' || l_style || '>' || l_parent || '</column8>'
          || '</row>';

    pragma inline (add_data, 'YES');
    add_data(l_str);
end add_attribute;

------------------------------------------------------------
begin
    l_lang := coalesce(i_lang, get_user_lang, com_api_const_pkg.DEFAULT_LANGUAGE);

    trc_log_pkg.debug (
        i_text          => 'prd_api_report_pkg.product_structure [#1][#2][#3][#3]'
        , i_env_param1  => i_inst_id
        , i_env_param2  => i_product_id
        , i_env_param3  => i_status
        , i_env_param4  => l_lang
    );

    select
        value
    into
        l_charset
    from
        nls_database_parameters
    where
        parameter = 'NLS_CHARACTERSET';

    l_yes := com_api_dictionary_pkg.get_article_text('BOOL0001', l_lang);
    l_no  := com_api_dictionary_pkg.get_article_text('BOOL0000', l_lang);

    delete prd_attribute_order_tmp;
    insert into prd_attribute_order_tmp (
        id
      , nesting_level
      , priority
    )
    select
        attr_id
      , lvl
      , rownum  as rn
    from (
        select
            id    as attr_id
          , level as lvl
        from
            prd_attribute
        start with
            parent_id is null
        connect by
            prior id = parent_id
        order siblings by
            display_order
          , id
    );

    delete prd_rpt_prd_struct_names_tmp;
    insert into prd_rpt_prd_struct_names_tmp (
        obj_id
      , obj_type
      , obj_name
    )
    select
        obj_id, obj_type, obj_name
    from (
        select
            i.text               as obj_name
          , i.table_name         as obj_type
          , to_char(i.object_id) as obj_id
          , row_number() over (partition by i.table_name, i.object_id
                                   order by decode(i.lang, l_lang, 0, com_api_const_pkg.LANGUAGE_ENGLISH, 1, 2)) as rn
        from
            com_i18n i
        where
            ((i.table_name in ('PRD_PRODUCT', 'PRD_SERVICE', 'PRD_ATTRIBUTE') and i.column_name = 'LABEL')
          or (i.table_name in ('RUL_MOD')                                     and i.column_name = 'NAME'))
        union all
        select
            i.text           as obj_name
          , i.table_name     as obj_type
          , d.dict || d.code as obj_id
          , row_number() over (partition by i.table_name, i.object_id
                                   order by decode(i.lang, l_lang, 0, com_api_const_pkg.LANGUAGE_ENGLISH, 1, 2)) as rn
        from
            com_i18n i
          , com_dictionary d
        where
            i.object_id       = d.id
            and i.table_name  = 'COM_DICTIONARY'
            and i.column_name = 'NAME'

    ) where
        rn = 1;

    dbms_lob.createtemporary(l_result, false, dbms_lob.session);
    pragma inline (add_report, 'YES'); add_report;

    for r in (
        with prod_hierarchy as (
            select --+ materialize
                p.id                            as product_id
              , '('
                || ltrim(sys_connect_by_path('"' || p.id || '"', '|'), '|')
                || ')'                          as prod_path
              , p.product_type
              , p.contract_type
              , p.parent_id
              , p.status
              , p.product_number
              , level                           as level_priority
              , connect_by_root id              as root_id
              , rownum                          as rn
            from
                prd_product p
            where
                (p.inst_id = i_inst_id or i_inst_id = ost_api_const_pkg.DEFAULT_INST)
                and (p.status = i_status or i_status is null)
            start with
                p.id = i_product_id or (i_product_id is null and p.parent_id is null)
            connect by
                prior p.id = p.parent_id
        ),
        t as (
            select
                row_number() over (partition by
                                       p.product_id
                                     , a.id
                                     , v.mod_id
                                   order by
                                       p.level_priority desc
                                     , v.start_date desc
                                     , v.register_timestamp desc) as attr_actuality
              , p.prod_path
              , p.product_id
              , p.product_number
              , p.contract_type
              , s.id                                              as service_id
              , s.service_number
              , ps.min_count                                      as srv_min_count
              , ps.max_count                                      as srv_max_count
              , p.product_type
              , p.status                                          as product_status
              , p.level_priority
              , a.id                                              as attr_id
              , a.definition_level
              , a.data_type
              , a.lov_id
              , case
                    when a.parent_id is null and a.entity_type = rul_api_const_pkg.ENTITY_TYPE_GROUP_ATTR
                        then 'GROUP_NAME'
                    when a.parent_id is not null and a.entity_type = rul_api_const_pkg.ENTITY_TYPE_GROUP_ATTR
                        then 'SUBGROUP_NAME'
                    when a.parent_id is null and a.entity_type <> rul_api_const_pkg.ENTITY_TYPE_GROUP_ATTR
                        then 'SINGLE'
                    else
                        'GROUP_MEMBER'
                end                                               as member_type
              , asort.priority                                    as attr_order
              , v.mod_id
              , v.start_date
              , v.end_date
              , v.register_timestamp
              , v.attr_value
              , v.entity_type                                     as src_type
              , v.object_id                                       as src_id
              , m.priority                                        as mod_priority
              , a.entity_type                                     as attr_entity_type
              , a.object_type                                     as attr_object_type
            from
                prod_hierarchy p
            inner join
                prd_product_service ps
            on
                ps.product_id = p.product_id
            inner join
                prd_service s
            on
                s.id = ps.service_id
            inner join
                prd_attribute a
            on
                a.service_type_id = s.service_type_id
            inner join
                prd_attribute_order_tmp asort
            on
                asort.id = a.id
            left join
                prd_attribute_value v
            on
                v.service_id             = s.id
                and v.attr_id            = a.id
                and ((a.definition_level = prd_api_const_pkg.ATTRIBUTE_DEFIN_LVL_PRODUCT and regexp_like('"' || to_char(v.object_id) || '"', p.prod_path) and v.entity_type = prd_api_const_pkg.ENTITY_TYPE_PRODUCT)
                  or (a.definition_level = prd_api_const_pkg.ATTRIBUTE_DEFIN_LVL_SERVICE and v.object_id = s.id and v.entity_type = prd_api_const_pkg.ENTITY_TYPE_SERVICE))
            left join
                rul_mod m
            on
                m.id = v.mod_id
        )
        select
            t.product_number
          , t.level_priority
          , t.product_id
          , pstname.obj_name as product_status
          , prdname.obj_name as product_name
          , prtname.obj_name as product_type
          , pctname.obj_name as contract_type
          , t.service_id
          , t.service_number
          , srvname.obj_name as service_name
          , t.srv_min_count
          , t.srv_max_count
          , t.attr_id
          , lag(t.attr_id)  over (order by t.prod_path
                                         , t.service_id
                                         , t.attr_order
                                         , t.mod_priority nulls last
                                         , t.src_id nulls last
                                         , t.start_date desc
                                         , t.register_timestamp desc) as prev_attr_id
          , lead(t.attr_id) over (order by t.prod_path
                                         , t.service_id
                                         , t.attr_order
                                         , t.mod_priority nulls last
                                         , t.src_id nulls last
                                         , t.start_date desc
                                         , t.register_timestamp desc) as next_attr_id
          , t.data_type      as attr_data_type
          , t.lov_id
          , t.member_type
          , t.attr_actuality
          , atrname.obj_name as human_attr_name
          , defname.obj_name as def_level_name
          , t.start_date     as value_start_date
          , t.end_date       as value_end_date
          , modname.obj_name as mod_name
          , t.src_id
          , sroname.obj_name as src_name
          , t.src_type       as source_type
          , case
                when t.data_type = com_api_const_pkg.DATA_TYPE_NUMBER
                    then to_char(convert_to_number(t.attr_value))
                when t.data_type = com_api_const_pkg.DATA_TYPE_DATE
                    then to_char(convert_to_date(t.attr_value), DT_FORMAT)
                else
                    nvl(avlname.obj_name, t.attr_value)
            end                     as attr_value
          , t.attr_entity_type      as orig_attr_entity_type
          , case
                when t.attr_object_type is not null then
                    t.attr_object_type
                when t.attr_object_type is null and t.lov_id is not null then
                    'LIST' || lpad(to_char(t.lov_id), 4, '0')
                else
                    atpname.obj_name
            end as attr_type
        from
            t
          , prd_rpt_prd_struct_names_tmp prdname
          , prd_rpt_prd_struct_names_tmp prtname
          , prd_rpt_prd_struct_names_tmp pstname
          , prd_rpt_prd_struct_names_tmp pctname
          , prd_rpt_prd_struct_names_tmp srvname
          , prd_rpt_prd_struct_names_tmp atrname
          , prd_rpt_prd_struct_names_tmp modname
          , prd_rpt_prd_struct_names_tmp defname
          , prd_rpt_prd_struct_names_tmp atpname
          , prd_rpt_prd_struct_names_tmp avlname
          , prd_rpt_prd_struct_names_tmp sroname
        where
            prdname.obj_type     (+) = 'PRD_PRODUCT'
            and prdname.obj_id   (+) = t.product_id
            and prtname.obj_type (+) = 'COM_DICTIONARY'
            and prtname.obj_id   (+) = t.product_type
            and pstname.obj_type (+) = 'COM_DICTIONARY'
            and pstname.obj_id   (+) = t.product_status
            and pctname.obj_type (+) = 'COM_DICTIONARY'
            and pctname.obj_id   (+) = t.contract_type
            and srvname.obj_type (+) = 'PRD_SERVICE'
            and srvname.obj_id   (+) = t.service_id
            and atrname.obj_type (+) = 'PRD_ATTRIBUTE'
            and atrname.obj_id   (+) = t.attr_id
            and modname.obj_type (+) = 'RUL_MOD'
            and modname.obj_id   (+) = t.mod_id
            and defname.obj_type (+) = 'COM_DICTIONARY'
            and defname.obj_id   (+) = t.definition_level
            and atpname.obj_type (+) = 'COM_DICTIONARY'
            and atpname.obj_id   (+) = t.data_type
            and avlname.obj_type (+) = 'COM_DICTIONARY'
            and avlname.obj_id   (+) = t.attr_value
            and sroname.obj_type (+) = decode(t.src_type, 'ENTTPROD', 'PRD_PRODUCT', 'ENTTSRVC', 'PRD_SERVICE', t.src_type)
            and sroname.obj_id   (+) = to_char(t.src_id)
        order by
            t.prod_path
          , t.service_id
          , t.attr_order
          , t.mod_priority nulls last
          , t.src_id nulls last
          , t.start_date asc
          , t.register_timestamp asc
    ) loop
        if l_product_id is null or r.product_id <> l_product_id then
            pragma inline (add_product, 'YES');
            add_product (
                i_id            => r.product_id
              , i_number        => r.product_number
              , i_name          => r.product_name
              , i_status        => r.product_status
              , i_type          => r.product_type
              , i_contract_type => r.contract_type
              , i_level         => r.level_priority
            );
        end if;
        if l_service_id is null or r.service_id <> l_service_id then
            pragma inline (add_service, 'YES');
            add_service (
                i_id     => r.service_id
              , i_number => r.service_number
              , i_name   => r.service_name
              , i_min    => r.srv_min_count
              , i_max    => r.srv_max_count
            );
        end if;
        if r.member_type in ('GROUP_NAME', 'SUBGROUP_NAME') then
            pragma inline (add_attr_group, 'YES');
            add_attr_group (
                i_name  => r.human_attr_name
              , i_type  => r.member_type
            );
        else
            pragma inline (add_attribute, 'YES');
            add_attribute (
                i_id               => r.attr_id
              , i_prev_id          => r.prev_attr_id
              , i_next_id          => r.next_attr_id
              , i_type             => r.attr_type
              , i_name             => r.human_attr_name
              , i_definition_level => r.def_level_name
              , i_mod_name         => r.mod_name
              , i_value            => r.attr_value
              , i_data_type        => r.attr_data_type
              , i_start_date       => r.value_start_date
              , i_end_date         => r.value_end_date
              , i_lov_id           => r.lov_id
              , i_src_type         => r.source_type
              , i_src_id           => r.src_id
              , i_orig_type        => r.orig_attr_entity_type
              , i_src_name         => r.src_name
              , i_actuality        => r.attr_actuality
            );
        end if;
    end loop;

    pragma inline (close_tags, 'YES'); close_tags('ALL');
    o_xml := l_result;

    trc_log_pkg.debug (
        i_text => 'prd_api_report_pkg.product_structure - ok'
    );

exception
    when others then
        trc_log_pkg.debug (
            i_text   => sqlerrm
        );
        raise;
end product_structure;

end;
/