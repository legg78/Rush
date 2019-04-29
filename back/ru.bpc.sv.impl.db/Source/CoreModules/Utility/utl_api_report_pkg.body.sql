create or replace package body utl_api_report_pkg is

    procedure run_report_dict (
        o_xml                       out clob
        , i_lang                    in com_api_type_pkg.t_dict_value
        , i_module_code             in com_api_type_pkg.t_module_code
        , i_table_name              in com_api_type_pkg.t_name
        , i_is_constraint           in com_api_type_pkg.t_boolean
        , i_is_index                in com_api_type_pkg.t_boolean
    ) is
        l_result                xmltype;
        l_table_name            com_api_type_pkg.t_name;
    begin
        trc_log_pkg.debug (
            i_text          => 'utl_api_report_pkg.run_report_dict [#1][#2][#3][#4]'
            , i_env_param1  => i_module_code
            , i_env_param2  => i_table_name
            , i_env_param3  => i_is_constraint
            , i_env_param4  => i_is_index
        );

        l_table_name := upper(i_table_name) || '%';

        select
            xmlelement("report",
                xmlagg(
                    xmlelement("table",
                        xmlelement("module_code", x.module_code)
                        , xmlelement("module_name", x.module_name)
                        , xmlelement("tab_name", x.tab_name)
                        , xmlelement("tab_comment", x.tab_comment)
                        , xmlelement("object_type", x.object_type)
                        , xmlelement("column_name", x.column_name)
                        , xmlelement("column_seq", x.column_seq)
                        , xmlelement("column_data_type", x.column_data_type)
                        , xmlelement("column_comment", x.column_comment)
                        , xmlelement("const_name", x.const_name)
                        , xmlelement("const_seq", x.const_seq)
                        , xmlelement("const_column", x.const_column)
                        , xmlelement("const_type", x.const_type)
                        , xmlelement("const_expr", x.const_expr)
                        , xmlelement("const_condition", x.const_condition)
                    )
                    order by
                        x.module_code
                        , x.tab_name
                        , x.object_order
                        , x.object_type
                        , x.const_name
                        , x.const_seq
                )
            )
        into
            l_result
        from (
            select
                m.module_code
                , m.name module_name
                , t.tab_name
                , t.tab_comment
                , t.object_type
                , t.object_order
                , t.column_name
                , t.column_seq
                , t.column_data_type
                , t.column_comment
                , t.const_name
                , t.const_column
                , t.const_seq
                , t.const_type
                , t.const_expr
                , t.const_condition
            from (
                select
                    tb.table_name tab_name
                    , tc.comments tab_comment

                    , 'Column Summary' object_type
                    , 0 object_order

                    , tl.column_name
                    , tl.column_id column_seq
                    , tl.data_type||'('||to_char(tl.data_length)||decode(tl.data_precision, null, ')', ', '||
                        to_char(tl.data_precision)||')')||decode(tl.nullable, 'Y', null, ' NOT NULL') column_data_type
                    , cc.comments column_comment

                    , null const_name
                    , tl.column_name const_column
                    , tl.column_id const_seq
                    , null const_type
                    , null const_expr
                    , null const_condition
                from
                    user_tables tb
                    , user_tab_comments tc
                    , user_tab_columns  tl
                    , user_col_comments cc
                where
                    tc.table_name = tb.table_name
                    and tl.table_name = tb.table_name
                    and cc.table_name(+) = tl.table_name
                    and cc.column_name(+) = tl.column_name
                    and upper(tb.table_name) like l_table_name
                union all
                -- index
                select
                    ix.table_name tab_name
                    , to_char(null) tab_comment

                    , 'Index Summary' object_type
                    , 3 object_order

                    , null column_name
                    , null column_seq
                    , null column_data_type
                    , null column_comment

                    , ix.index_name const_name
                    , cl.column_name const_column
                    , cl.column_position const_seq
                    , ix.index_type const_type
                    , ex.column_expression const_expr
                    , null const_condition
                from
                    user_indexes ix,
                    user_ind_columns cl,
                    --user_ind_expressions ex
                    (
                    with xml as (
                        select
                            xmltype(dbms_xmlgen.getxml('select * from user_ind_expressions')) as xml
                        from
                            dual
                    )
                    , parsed_xml as (
                        select
                            extractvalue(xs.object_value, '/ROW/INDEX_NAME') index_name
                            , extractvalue(xs.object_value, '/ROW/TABLE_NAME') table_name
                            , extractvalue(xs.object_value, '/ROW/COLUMN_EXPRESSION') column_expression
                            , extractvalue(xs.object_value, '/ROW/COLUMN_POSITION') column_position
                        from
                            xml x
                            , table(xmlsequence(extract(x.xml, '/ROWSET/ROW'))) xs
                    )
                    select
                        index_name
                        , table_name
                        , column_expression
                        , column_position
                    from
                      parsed_xml
                    ) ex
                where
                    ix.table_owner = user
                    and ix.table_name  = cl.table_name
                    and ix.index_name  = cl.index_name
                    and cl.index_name = ex.index_name(+)
                    and cl.table_name = ex.table_name(+)
                    and cl.column_position = ex.column_position(+)
                    and upper(ix.table_name) like l_table_name
                    and i_is_index = com_api_type_pkg.TRUE
                union all
                -- check constraint
                select
                    cn.table_name tab_name
                    , to_char(null) tab_comment

                    , 'Check Constraints' object_type
                    , 2 object_order

                    , null column_name
                    , null column_seq
                    , null column_data_type
                    , null column_comment

                    , cn.constraint_name const_name
                    , to_char(null) const_column
                    , null const_seq
                    , to_char(null) const_type
                    , null const_expr
                    , cn.search_condition const_condition
                from
                    --user_constraints cn
                    ( with xml as (
                          select
                              xmltype(dbms_xmlgen.getxml('select * from user_constraints')) as xml
                          from
                              dual
                      )
                      , parsed_xml as (
                          select
                              extractvalue(xs.object_value, '/ROW/CONSTRAINT_NAME') constraint_name
                              , extractvalue(xs.object_value, '/ROW/CONSTRAINT_TYPE') constraint_type
                              , extractvalue(xs.object_value, '/ROW/TABLE_NAME') table_name
                              , extractvalue(xs.object_value, '/ROW/SEARCH_CONDITION') search_condition
                              , extractvalue(xs.object_value, '/ROW/R_CONSTRAINT_NAME') r_constraint_name
                              , extractvalue(xs.object_value, '/ROW/GENERATED') generated
                          from
                              xml x
                              , table(xmlsequence(extract(x.xml, '/ROWSET/ROW'))) xs
                      )
                      select
                          constraint_name
                          , constraint_type
                          , table_name
                          , search_condition
                          , r_constraint_name
                          , generated
                      from
                           parsed_xml
                    ) cn
                where
                    cn.generated != 'GENERATED NAME'
                    and cn.constraint_type = 'C'
                    and upper(cn.table_name) like l_table_name
                    and i_is_constraint = com_api_type_pkg.TRUE
                union all
                -- primary key
                select
                    cn.table_name tab_name
                    , to_char(null) tab_comment

                    , decode(cn.constraint_type, 'C', 'Check Constraint',
                                                 'P', 'Primary Key',
                                                 'U', 'Unique Key',
                                                 'R', 'Foreign Key',
                                                 'V', 'With Check Option, On a View',
                                                 'O', 'With Read Only, On a View',
                                                 '?') object_type
                    , 1 object_order

                    , null column_name
                    , null column_seq
                    , null column_data_type
                    , null column_comment

                    , cn.constraint_name const_name
                    , cl.column_name const_column
                    , cl.position const_seq
                    , to_char(null) const_type
                    , null const_expr
                    , cn.search_condition const_condition
                from
                    --user_constraints cn
                    ( with xml as (
                          select
                              xmltype(dbms_xmlgen.getxml('select * from user_constraints')) as xml
                          from
                              dual
                      )
                      , parsed_xml as (
                          select
                              extractvalue(xs.object_value, '/ROW/CONSTRAINT_NAME') constraint_name
                              , extractvalue(xs.object_value, '/ROW/CONSTRAINT_TYPE') constraint_type
                              , extractvalue(xs.object_value, '/ROW/TABLE_NAME') table_name
                              , extractvalue(xs.object_value, '/ROW/SEARCH_CONDITION') search_condition
                              , extractvalue(xs.object_value, '/ROW/R_CONSTRAINT_NAME') r_constraint_name
                              , extractvalue(xs.object_value, '/ROW/GENERATED') generated
                          from
                              xml x
                              , table(xmlsequence(extract(x.xml, '/ROWSET/ROW'))) xs
                      )
                      select
                          constraint_name
                          , constraint_type
                          , table_name
                          , search_condition
                          , r_constraint_name
                          , generated
                      from
                          parsed_xml
                    ) cn
                    , user_cons_columns cl
                where
                    cn.constraint_name = cl.constraint_name
                    and cn.generated != 'GENERATED NAME'
                    and cn.constraint_type not in ('R', 'C')
                    and upper(cn.table_name) like l_table_name
                    and i_is_constraint = com_api_type_pkg.TRUE
                union all
                -- foreign key
                select
                    cn.table_name tab_name
                    , to_char(null) tab_comment

                    , decode(cn.constraint_type, 'C', 'Check Constraint',
                                                 'P', 'Primary Key',
                                                 'U', 'Unique Key',
                                                 'R', 'Foreign Key',
                                                 'V', 'With Check Option, On a View',
                                                 'O', 'With Read Only, On a View',
                                                 '?') object_type
                    , 0 object_order

                    , null column_name
                    , null column_seq
                    , null column_data_type
                    , null column_comment

                    , cn.constraint_name const_name
                    , cl.column_name || ' reference ' || fl.table_name || '.' || fl.column_name const_column
                    , cl.position const_seq
                    , to_char(null) const_type
                    , null const_expr
                    , cn.search_condition const_condition
                from
                    --user_constraints cn
                    ( with xml as (
                          select
                              xmltype(dbms_xmlgen.getxml('select * from user_constraints')) as xml
                          from
                              dual
                      )
                      , parsed_xml as (
                          select
                              extractvalue(xs.object_value, '/ROW/CONSTRAINT_NAME') constraint_name
                              , extractvalue(xs.object_value, '/ROW/CONSTRAINT_TYPE') constraint_type
                              , extractvalue(xs.object_value, '/ROW/TABLE_NAME') table_name
                              , extractvalue(xs.object_value, '/ROW/SEARCH_CONDITION') search_condition
                              , extractvalue(xs.object_value, '/ROW/R_CONSTRAINT_NAME') r_constraint_name
                              , extractvalue(xs.object_value, '/ROW/GENERATED') generated
                          from
                              xml x
                              , table(xmlsequence(extract(x.xml, '/ROWSET/ROW'))) xs
                      )
                      select
                          constraint_name
                          , constraint_type
                          , table_name
                          , search_condition
                          , r_constraint_name
                          , generated
                      from
                          parsed_xml
                    ) cn
                    , user_cons_columns cl
                    , user_cons_columns fl
                where
                    cn.constraint_name = cl.constraint_name
                    and cn.r_constraint_name = fl.constraint_name
                    and cl.position = fl.position
                    and cn.generated != 'GENERATED NAME'
                    and cn.constraint_type = 'R'
                    and upper(cn.table_name) like l_table_name
                    and i_is_constraint = com_api_type_pkg.TRUE
                ) t
                , com_module m
            where
                m.module_code = substr(t.tab_name, 1, 3)
                and m.module_code = nvl(i_module_code, m.module_code)
            order by
                m.module_code
                , t.tab_name
                , t.object_order
                , t.object_type
                , t.const_name
                , t.const_seq
        ) x;

        o_xml := l_result.getclobval();

        trc_log_pkg.debug (
            i_text => 'utl_api_report_pkg.run_report_dict - ok'
        );
    exception
        when no_data_found then
            com_api_error_pkg.raise_error (
                i_error  => 'REPORT_DATA_NOT_FOUND'
            );
    end;

procedure run_report_rep
  ( o_xml          out clob
  , i_lang         in com_api_type_pkg.t_dict_value
  , i_tag_id       in com_api_type_pkg.t_tiny_id  default null
  ) 
is
    l_result       xmltype;
begin

    trc_log_pkg.debug (
        i_text          => 'utl_api_report_pkg.run_report_rep [#1][#2]]'
        , i_env_param1  => i_lang
        , i_env_param2  => i_tag_id
    );

   select
       xmlelement("report",
           xmlagg(
               xmlelement("table"
                   , xmlelement( "report_id"         , x.report_id         )
                   , xmlelement( "rep_label"         , x.rep_label         )
                   , xmlelement( "rep_desc"          , x.rep_desc          )
                   , xmlelement( "source_type"       , x.source_type       )
                   , xmlelement( "object_type"       , x.object_type       )
                   , xmlelement( "param_name"        , x.param_name        )
                   , xmlelement( "param_label"       , x.param_label       )
                   , xmlelement( "param_data_type"   , x.param_data_type   )
                   , xmlelement( "param_is_mandatory", x.param_is_mandatory)
                   , xmlelement( "tag_label"         , x.tag_label         )
                   , xmlelement( "value_descr"       , x.value_descr       )
               )
             /*  order by
                     x.rep_label
                   , x.object_type
                   , x.display_order*/
           )
       )
   into
       l_result
   from (
      select t.id report_id
           , t.rep_label
           , t.rep_desc
           , t.source_type
           , t.object_type
           , t.param_name
           , t.param_label
           , t.param_data_type
           , t.param_is_mandatory
           , t.tag_label
           , t.display_order
           , t.value_descr
        from (
               select d.id
                    , get_text ('RPT_REPORT', 'LABEL', d.id, i_lang) as rep_label
                    , get_text ('RPT_REPORT', 'DESCRIPTION', d.id, i_lang) as rep_desc
                    , com_api_dictionary_pkg.get_article_text ( d.source_type, i_lang ) as source_type
                    , d.object_type
                    , d.param_name
                    , d.param_label
                    , d.param_data_type
                    , d.param_is_mandatory
                    , d.tag_label
                    , d.display_order
                    , d.value_descr
                    , d.order_section                
                 from ( select r.id
                             , r.source_type
                             , 'Input parameters' as object_type
                             , 1 order_section
                             , rp.display_order
                             , rp.id param_id
                             , rp.param_name
                             , get_text ('RPT_PARAMETER', 'LABEL', rp.id, i_lang) as param_label
                             , com_api_dictionary_pkg.get_article_text ( rp.data_type, i_lang ) as param_data_type
                             , com_api_dictionary_pkg.get_article_text ( 'BOOL'||lpad(to_char(rp.is_mandatory),4,'0'), i_lang ) as param_is_mandatory
                             , null as tag_id
                             , null as tag_label
                             , get_text ('RPT_PARAMETER', 'DESCRIPTION', rp.id, i_lang) as value_descr
                          from rpt_report_vw r
                             , rpt_parameter_vw rp
                         where rp.report_id = r.id
                           and rp.param_name is not null
                           and ((i_tag_id is null ) or
                                (i_tag_id is not null and exists (select 1 from rpt_report_tag where report_id = r.id and tag_id = i_tag_id) )
                               )
                        union
                        select r.id
                             , r.source_type
                             ,'Tags' as object_type
                             , 3 order_section
                             , null as display_order
                             , null as param_id
                             , null as param_name
                             , replace(stragg(get_text ('RPT_TAG', 'LABEL', rt.tag_id, i_lang)), ',', ', ') as param_label
                             , null as param_type
                             , null as param_is_mandatory
                             , null as tag_id 
                             , null as tag_label 
                             , null as value_descr
                          from rpt_report_vw R
                             , rpt_report_tag_vw RT
                         where rt.report_id = r.id
                           and ((i_tag_id is null ) or
                                (i_tag_id is not null and exists (select 1 from rpt_report_tag where report_id = r.id and tag_id = i_tag_id) )
                               )
                         group by r.id
                             , r.source_type                               
                        union
                        select r.id
                             , r.source_type
                             , 'Report columns' as object_type
                             , 2 order_section
                             , rp.display_order
                             , rp.id param_id
                             , rp.param_name
                             , get_text ('RPT_PARAMETER', 'LABEL', rp.id, i_lang) as param_label
                             , null as param_data_type
                             , null as param_is_mandatory
                             , null as tag_id
                             , null as tag_label
                             , get_text ('RPT_PARAMETER', 'DESCRIPTION', rp.id, i_lang) as value_descr
                          from rpt_report_vw r
                             , rpt_parameter_vw rp
                         where rp.report_id = r.id
                           and rp.param_name is null
                           and ((i_tag_id is null ) or
                                (i_tag_id is not null and exists (select 1 from rpt_report_tag where report_id = r.id and tag_id = i_tag_id) )
                               )                               
                        union       
                        select r.id
                             , r.source_type
                             , 'Grouping' as object_type
                             , 4 order_section
                             , null as display_order
                             , null as param_id
                             , null as param_name
                             , replace(stragg(get_text ('RPT_PARAMETER', 'LABEL', rp.id, i_lang)), ',', ', ') as param_label
                             , null as param_data_type
                             , null as param_is_mandatory
                             , null as tag_id
                             , null as tag_label
                             , null as value_descr
                          from rpt_report_vw r
                             , rpt_parameter_vw rp
                         where rp.report_id = r.id
                           and rp.param_name is null
                           and rp.is_grouping = 1 
                           and ((i_tag_id is null ) or
                                (i_tag_id is not null and exists (select 1 from rpt_report_tag where report_id = r.id and tag_id = i_tag_id) )
                               )    
                         group by r.id
                             , r.source_type
                             
                        union       
                        select r.id
                             , r.source_type
                             , 'Sorting' as object_type
                             , 5 order_section
                             , null as display_order
                             , null as param_id
                             , null as param_name
                             , replace(stragg(get_text ('RPT_PARAMETER', 'LABEL', rp.id, i_lang)), ',', ', ') as param_label
                             , null as param_data_type
                             , null as param_is_mandatory
                             , null as tag_id
                             , null as tag_label
                             , null as value_descr
                          from rpt_report_vw r
                             , rpt_parameter_vw rp
                         where rp.report_id = r.id
                           and rp.param_name is null
                           and rp.is_sorting = 1 
                           and ((i_tag_id is null ) or
                                (i_tag_id is not null and exists (select 1 from rpt_report_tag where report_id = r.id and tag_id = i_tag_id) )
                               )    
                         group by r.id
                             , r.source_type                                                                                             
                        ) d
             ) t
       order by t.rep_label, t.order_section, t.object_type, t.display_order  
   ) x;

   o_xml := l_result.getclobval();

   trc_log_pkg.debug (
       i_text => 'utl_api_report_pkg.run_report_rep - ok'
   );

exception 
   when no_data_found then
       trc_log_pkg.debug (
             i_text => sqlerrm
       );
end;

end;
/

