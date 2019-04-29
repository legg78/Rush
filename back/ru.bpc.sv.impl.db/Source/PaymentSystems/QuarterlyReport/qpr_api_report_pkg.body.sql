create or replace package body qpr_api_report_pkg is

--MASTERCARD quarter reports
procedure mc_issuing(
    o_xml                       out clob
    , i_card_type_id            in  com_api_type_pkg.t_tiny_id
    , i_program_categories      in  com_api_type_pkg.t_name
    , i_year                    in  com_api_type_pkg.t_tiny_id
    , i_quarter                 in  com_api_type_pkg.t_sign
    , i_inst_id                 in  com_api_type_pkg.t_inst_id
    , i_lang                    in  com_api_type_pkg.t_dict_value
) is
    l_card_type        com_api_type_pkg.t_name;
    l_lang             com_api_type_pkg.t_dict_value;
    l_header           xmltype;
    l_detail           xmltype;
    l_result           xmltype;
    l_cmid             com_api_type_pkg.t_cmid;
begin
    trc_log_pkg.debug(
        i_text        => 'qpr_api_report_pkg.mc_issuing [#1][#2][#3][#4][#5]'
      , i_env_param1  => i_lang
      , i_env_param2  => i_year
      , i_env_param3  => i_quarter
      , i_env_param4  => i_card_type_id
      , i_env_param5  => i_inst_id
    );

    l_lang := nvl( i_lang, get_user_lang );
    l_card_type := com_api_i18n_pkg.get_text('NET_CARD_TYPE','NAME', i_card_type_id, l_lang)|| ' - '||i_program_categories;

    select max(nvl(v.cmid, '0000'))
      into l_cmid
      from qpr_param_value v
         , (select id as inst_id
              from ost_institution i
              connect by prior id = parent_id
              start with id = i_inst_id
           ) inst
     where v.year     = i_year
       and ceil(nvl(v.month_num, i_quarter*3)/3) = i_quarter
       and v.inst_id  = inst.inst_id;

    -- header
    select
        xmlconcat(
            xmlelement("card_type_id", i_card_type_id)
            , xmlelement("card_type", l_card_type)
            , xmlelement("year", i_year)
            , xmlelement("quarter", i_quarter)
            , xmlelement("cmid", l_cmid)
        )
      into l_header
      from dual;

    select
        xmlelement("issuing"
                , xmlagg(
                    xmlelement("param"
                        , xmlelement("group_id", group_id)
                        , xmlelement("group_desc", group_desc)
                        , xmlelement("param_id", param_id)
                        , xmlelement("param_desc", param_desc)
                        , xmlelement("year", i_year)
                        -- always without precision
                        -- not null for
                        -- D. Accounts/Cards
                        -- III. Card Feature Details
                        , xmlelement("value_1", case
                                                    when group_id in (/*106,*/ 115) then
                                                        trim(to_char(nvl(value_1, 0), 'FM999999999999990'))
                                                    else
                                                        trim(to_char(value_1, 'FM999999999999990'))
                                                end
                          )
                        -- always not null and without precision
                        , xmlelement("value_2", --trim(to_char(nvl(value_2, 0), 'FM999999999999990'))
                                               case
                                                    when group_id in (106) then
                                                        trim(to_char(value_2, 'FM999999999999990'))
                                                    else
                                                        trim(to_char(nvl(value_2, 0), 'FM999999999999990'))
                                                end
                          )
                        -- always not null
                        -- without precision
                        -- D. Accounts/Cards
                        --
                        , xmlelement("value_3", case
                                                    when group_id in (106) then
                                                        trim(to_char(nvl(value_3, 0), 'FM999999999999990'))
                                                    else
                                                        trim(to_char(nvl(round(value_3), 0), 'FM999999999999990'))
                                                end
                          )
                        , xmlelement("col_1_name", mc_rep_col_1_name)
                        , xmlelement("col_2_name", mc_rep_col_2_name)
                        , xmlelement("col_3_name", mc_rep_col_3_name)
                    )
                )
            )
    into
        l_detail
    from(
        select v.*
             , g.mc_rep_col_1_name
             , g.mc_rep_col_2_name
             , g.mc_rep_col_3_name
          from (
            with inst as
                 (select id as inst_id
                    from ost_institution i
                    connect by prior id = parent_id
                    start with id = i_inst_id
                 )
            select g.id           as group_id
                 , g.group_desc
                 , p.id           as param_id
                 , p.param_desc
                 , i_year         as year
                 , sum(v.value_1) as value_1
                 , sum(v.value_2) as value_2
                 , sum(v.value_3) as value_3
                 , l_card_type    as card_type
                 , g.priority     as group_priority
              from qpr_group g
                 , (select id, param_id, group_id, priority, inst_id
                      from qpr_param_group gp, inst) gp
                 , qpr_param p
                 , qpr_param_value v
                 , qpr_group_report r
             where r.report_name       = 'PS_MC_ISSUING'
               and g.id                = r.id
               and gp.group_id(+)      = g.id
               and p.id(+)             not in (1006)
               and p.id(+)             = gp.param_id
               and v.param_group_id(+) = gp.id
               and v.id_param_value(+) = gp.param_id
               and v.year(+)           = i_year
               and ceil(nvl(v.month_num(+), i_quarter*3)/3) = i_quarter
               and v.card_type(+)      = l_card_type
               and v.inst_id(+)        = gp.inst_id
               and g.priority is not null
               and nvl(gp.priority,0) != -1
          group by g.id
                 , g.group_desc
                 , p.id
                 , p.param_desc
                 , g.priority
             union all
            -- A. Purchases
            -- 6. Total (1+2+3+4+5)
            select g.id                   as group_id
                 , g.group_desc           as group_desc
                 , p.id                   as param_id
                 , p.param_desc           as param_desc
                 , i_year                 as year
                 , v.value_1              as value_1
                 , v.value_2              as value_2
                 , v.value_3              as value_3
                 , l_card_type            as card_type
                 , g.priority             as group_priority
              from (
                    select sum(v.value_1)        as value_1
                         , sum(v.value_2)        as value_2
                         , sum(v.value_3)        as value_3
                      from qpr_group g
                         , (select id, param_id, group_id, priority, inst_id
                              from qpr_param_group gp , inst) gp
                         , qpr_param p
                         , qpr_param_value v
                         , qpr_group_report r
                     where r.report_name       = 'PS_MC_ISSUING'
                       and g.id                = r.id
                       and gp.group_id(+)      = g.id
                       and p.id(+)             = gp.param_id
                       and v.param_group_id(+) = gp.id
                       and v.id_param_value(+) = gp.param_id
                       and v.year(+)           = i_year
                       and ceil(nvl(v.month_num(+), i_quarter*3)/3) = i_quarter
                       and v.card_type(+)      = l_card_type
                       and v.inst_id(+)        = gp.inst_id
                       and g.priority is not null
                       and nvl(gp.priority,0) != -1
                       and gp.id in (1000, 1001, 1002, 1003, 1004)
                   ) v
                 , qpr_group g
                 , qpr_param p
              where g.id = 101
                and p.id = 1006
             union all
            -- B. Total Cash Advances
            -- 6. Total (1+2+3+4+5)
            select g.id                   as group_id
                 , g.group_desc           as group_desc
                 , p.id                   as param_id
                 , p.param_desc           as param_desc
                 , i_year                 as year
                 , v.value_1              as value_1
                 , v.value_2              as value_2
                 , v.value_3              as value_3
                 , l_card_type            as card_type
                 , g.priority             as group_priority
              from (
                    select sum(v.value_1)        as value_1
                         , sum(v.value_2)        as value_2
                         , sum(v.value_3)        as value_3
                      from qpr_group g
                         , (select id, param_id, group_id, priority, inst_id
                              from qpr_param_group gp , inst) gp
                         , qpr_param p
                         , qpr_param_value v
                         , qpr_group_report r
                     where r.report_name       = 'PS_MC_ISSUING'
                       and g.id                = r.id
                       and gp.group_id(+)      = g.id
                       and p.id(+)             = gp.param_id
                       and v.param_group_id(+) = gp.id
                       and v.id_param_value(+) = gp.param_id
                       and v.year(+)           = i_year
                       and ceil(nvl(v.month_num(+), i_quarter*3)/3) = i_quarter
                       and v.card_type(+)      = l_card_type
                       and v.inst_id(+)        = gp.inst_id
                       and g.priority is not null
                       and nvl(gp.priority,0) != -1
                       and gp.id in (1007, 1008, 1009, 1010, 1011)
                   ) v
                 , qpr_group g
                 , qpr_param p
              where g.id = 102
                and p.id = 1006
              union all
            -- C. Refunds / Returns / Credits
            -- 6. Total (1+2+3+4+5)
            select g.id                   as group_id
                 , g.group_desc           as group_desc
                 , p.id                   as param_id
                 , p.param_desc           as param_desc
                 , i_year                 as year
                 , v.value_1              as value_1
                 , v.value_2              as value_2
                 , v.value_3              as value_3
                 , l_card_type            as card_type
                 , g.priority             as group_priority
              from (
                    select sum(v.value_1)        as value_1
                         , sum(v.value_2)        as value_2
                         , sum(v.value_3)        as value_3
                      from qpr_group g
                         , (select id, param_id, group_id, priority, inst_id
                              from qpr_param_group gp , inst) gp
                         , qpr_param p
                         , qpr_param_value v
                         , qpr_group_report r
                     where r.report_name       = 'PS_MC_ISSUING'
                       and g.id                = r.id
                       and gp.group_id(+)      = g.id
                       and p.id(+)             = gp.param_id
                       and v.param_group_id(+) = gp.id
                       and v.id_param_value(+) = gp.param_id
                       and v.year(+)           = i_year
                       and ceil(nvl(v.month_num(+), i_quarter*3)/3) = i_quarter
                       and v.card_type(+)      = l_card_type
                       and v.inst_id(+)        = gp.inst_id
                       and g.priority is not null
                       and nvl(gp.priority,0) != -1
                       and gp.id in (1028, 1029, 1030, 1031, 1032)
                   ) v
                 , qpr_group g
                 , qpr_param p
              where g.id = 105
                and p.id = 1006
--             union
--            select max(v.group_id)        as group_id
--                 , max(v.group_desc)      as group_desc
--                 , 1006                   as param_id
--                 , '6. Total (1+2+3+4+5)' as param_desc
--                 , i_year                 as year
--                 , trim(to_char(sum(nvl(v.value_1,0)), 'FM999999999999990')) as value_1
--                 , trim(to_char(sum(nvl(v.value_2,0)), 'FM999999999999990d00', 'nls_numeric_characters=,.')) as value_2
--                 , trim(to_char(sum(nvl(v.value_3,0)), 'FM999999999999990')) as value_3
--                 , l_card_type            as card_type
--                 , max(v.group_priority)  as group_priority
--              from (
--                    select max(g.group_desc)            as group_desc
--                         , sum(nvl(v.value_1,0))        as value_1
--                         , round(sum(nvl(v.value_2,0))) as value_2
--                         , sum(nvl(v.value_3,0))        as value_3
--                         , max(g.priority)              as group_priority
--                         , gp.id                        as group_id
--                      from qpr_group g
--                         , (select id, param_id, group_id, priority, inst_id
--                              from qpr_param_group gp , inst) gp
--                         , qpr_param p
--                         , qpr_param_value v
--                         , qpr_group_report r
--                     where r.report_name       = 'PS_MC_ISSUING'
--                       and g.id                = r.id
--                       and gp.group_id(+)      = g.id
--                       and p.id(+)             = gp.param_id
--                       and v.param_group_id(+) = gp.id
--                       and v.id_param_value(+) = gp.param_id
--                       and v.year(+)           = i_year
--                       and ceil(nvl(v.month_num(+), i_quarter*3)/3) = i_quarter
--                       and v.card_type(+)      = l_card_type
--                       and v.inst_id(+)        = gp.inst_id
--                       and g.priority is not null
--                       and nvl(gp.priority,0) != -1
--                       and gp.id in (1021, 1022, 1023, 1024, 1025)
--                     group by gp.id
--                   ) v
--             union
--            select max(v.group_id)        as group_id
--                 , max(v.group_desc)      as group_desc
--                 , 1006                   as param_id
--                 , '6. Total (1+2+3+4+5)' as param_desc
--                 , i_year                 as year
--                 , trim(to_char(sum(nvl(v.value_1,0)), 'FM999999999999990')) as value_1
--                 , trim(to_char(sum(nvl(v.value_2,0)), 'FM999999999999990d00', 'nls_numeric_characters=,.')) as value_2
--                 , trim(to_char(sum(nvl(v.value_3,0)), 'FM999999999999990')) as value_3
--                 , l_card_type            as card_type
--                 , max(v.group_priority)  as group_priority
--              from (
--                    select max(g.group_desc)            as group_desc
--                         , sum(nvl(v.value_1,0))        as value_1
--                         , round(sum(nvl(v.value_2,0))) as value_2
--                         , sum(nvl(v.value_3,0))        as value_3
--                         , max(g.priority)              as group_priority
--                         , gp.id                        as group_id
--                      from qpr_group g
--                         , (select id, param_id, group_id, priority, inst_id
--                              from qpr_param_group gp , inst) gp
--                         , qpr_param p
--                         , qpr_param_value v
--                         , qpr_group_report r
--                     where r.report_name       = 'PS_MC_ISSUING'
--                       and g.id                = r.id
--                       and gp.group_id(+)      = g.id
--                       and p.id(+)             = gp.param_id
--                       and v.param_group_id(+) = gp.id
--                       and v.id_param_value(+) = gp.param_id
--                       and v.year(+)           = i_year
--                       and ceil(nvl(v.month_num(+), i_quarter*3)/3) = i_quarter
--                       and v.card_type(+)      = l_card_type
--                       and v.inst_id(+)        = gp.inst_id
--                       and g.priority is not null
--                       and nvl(gp.priority,0) != -1
--                       and gp.id in (1028, 1029, 1030, 1031, 1032)
--                     group by gp.id
--                   ) v
--             union
--            select max(v.group_id)       as group_id
--                 , max(v.group_desc)     as group_desc
--                 , 1110                  as param_id
--                 , '4. Total (1+2+3)'    as param_desc
--                 , i_year                as year
--                 , trim(to_char(sum(nvl(v.value_1,0)), 'FM999999999999990')) as value_1
--                 , trim(to_char(sum(nvl(v.value_2,0)), 'FM999999999999990d00', 'nls_numeric_characters=,.')) as value_2
--                 , trim(to_char(sum(nvl(v.value_3,0)), 'FM999999999999990')) as value_3
--                 , l_card_type           as card_type
--                 , max(v.group_priority) as group_priority
--              from (
--                    select max(g.group_desc)            as group_desc
--                         , sum(nvl(v.value_1,0))        as value_1
--                         , round(sum(nvl(v.value_2,0))) as value_2
--                         , sum(nvl(v.value_3,0))        as value_3
--                         , max(g.priority)              as group_priority
--                         , gp.id                        as group_id
--                      from qpr_group g
--                         , (select id, param_id, group_id, priority, inst_id
--                              from qpr_param_group gp , inst) gp
--                         , qpr_param p
--                         , qpr_param_value v
--                         , qpr_group_report r
--                     where r.report_name       = 'PS_MC_ISSUING'
--                       and g.id                = r.id
--                       and gp.group_id(+)      = g.id
--                       and p.id(+)             = gp.param_id
--                       and v.param_group_id(+) = gp.id
--                       and v.id_param_value(+) = gp.param_id
--                       and v.year(+)           = i_year
--                       and ceil(nvl(v.month_num(+), i_quarter*3)/3) = i_quarter
--                       and v.card_type(+)      = l_card_type
--                       and v.inst_id(+)        = gp.inst_id
--                       and g.priority is not null
--                       and nvl(gp.priority,0) != -1
--                       and gp.id in (1182, 1183, 1184)
--                     group by gp.id
--                   ) v
--             union
--            select max(v.group_id)       as group_id
--                 , max(v.group_desc)     as group_desc
--                 , 1110                  as param_id
--                 , '4. Total (1+2+3)'    as param_desc
--                 , i_year                as year
--                 , trim(to_char(sum(nvl(v.value_1,0)), 'FM999999999999990')) as value_1
--                 , trim(to_char(sum(nvl(v.value_2,0)), 'FM999999999999990d00', 'nls_numeric_characters=,.')) as value_2
--                 , trim(to_char(sum(nvl(v.value_3,0)), 'FM999999999999990')) as value_3
--                 , l_card_type           as card_type
--                 , max(v.group_priority) as group_priority
--              from (
--                    select max(g.group_desc)            as group_desc
--                         , sum(nvl(v.value_1,0))        as value_1
--                         , round(sum(nvl(v.value_2,0))) as value_2
--                         , sum(nvl(v.value_3,0))        as value_3
--                         , max(g.priority)              as group_priority
--                         , gp.id                        as group_id
--                      from qpr_group g
--                         , (select id, param_id, group_id, priority, inst_id
--                              from qpr_param_group gp , inst) gp
--                         , qpr_param p
--                         , qpr_param_value v
--                         , qpr_group_report r
--                     where r.report_name       = 'PS_MC_ISSUING'
--                       and g.id                = r.id
--                       and gp.group_id(+)      = g.id
--                       and p.id(+)             = gp.param_id
--                       and v.param_group_id(+) = gp.id
--                       and v.id_param_value(+) = gp.param_id
--                       and v.year(+)           = i_year
--                       and ceil(nvl(v.month_num(+), i_quarter*3)/3) = i_quarter
--                       and v.card_type(+)      = l_card_type
--                       and v.inst_id(+)        = gp.inst_id
--                       and g.priority is not null
--                       and nvl(gp.priority,0) != -1
--                       and gp.id in (1188, 1189, 1190)
--                     group by gp.id
--                   ) v
--             union
--            select max(v.group_id)       as group_id
--                 , max(v.group_desc)     as group_desc
--                 , 1110                  as param_id
--                 , '4. Total (1+2+3)'    as param_desc
--                 , i_year                as year
--                 , trim(to_char(sum(nvl(v.value_1,0)), 'FM999999999999990')) as value_1
--                 , trim(to_char(sum(nvl(v.value_2,0)), 'FM999999999999990d00', 'nls_numeric_characters=,.')) as value_2
--                 , trim(to_char(sum(nvl(v.value_3,0)), 'FM999999999999990')) as value_3
--                 , l_card_type           as card_type
--                 , max(v.group_priority) as group_priority
--              from (
--                    select max(g.group_desc)            as group_desc
--                         , sum(nvl(v.value_1,0))        as value_1
--                         , round(sum(nvl(v.value_2,0))) as value_2
--                         , sum(nvl(v.value_3,0))        as value_3
--                         , max(g.priority)              as group_priority
--                         , gp.id                        as group_id
--                      from qpr_group g
--                         , (select id, param_id, group_id, priority, inst_id
--                              from qpr_param_group gp , inst) gp
--                         , qpr_param p
--                         , qpr_param_value v
--                         , qpr_group_report r
--                     where r.report_name       = 'PS_MC_ISSUING'
--                       and g.id                = r.id
--                       and gp.group_id(+)      = g.id
--                       and p.id(+)             = gp.param_id
--                       and v.param_group_id(+) = gp.id
--                       and v.id_param_value(+) = gp.param_id
--                       and v.year(+)           = i_year
--                       and ceil(nvl(v.month_num(+), i_quarter*3)/3) = i_quarter
--                       and v.card_type(+)      = l_card_type
--                       and v.inst_id(+)        = gp.inst_id
--                       and g.priority is not null
--                       and nvl(gp.priority,0) != -1
--                       and gp.id in (1196, 1197, 1198)
--                     group by gp.id
--                   ) v
--             union
--            select max(v.group_id)       as group_id
--                 , max(v.group_desc)     as group_desc
--                 , 1110                  as param_id
--                 , '4. Total (1+2+3)'    as param_desc
--                 , i_year                as year
--                 , trim(to_char(sum(nvl(v.value_1,0)), 'FM999999999999990')) as value_1
--                 , trim(to_char(sum(nvl(v.value_2,0)), 'FM999999999999990d00', 'nls_numeric_characters=,.')) as value_2
--                 , trim(to_char(sum(nvl(v.value_3,0)), 'FM999999999999990')) as value_3
--                 , l_card_type           as card_type
--                 , max(v.group_priority) as group_priority
--              from (
--                    select max(g.group_desc)            as group_desc
--                         , sum(nvl(v.value_1,0))        as value_1
--                         , round(sum(nvl(v.value_2,0))) as value_2
--                         , sum(nvl(v.value_3,0))        as value_3
--                         , max(g.priority)              as group_priority
--                         , gp.id                        as group_id
--                      from qpr_group g
--                         , (select id, param_id, group_id, priority, inst_id
--                              from qpr_param_group gp , inst) gp
--                         , qpr_param p
--                         , qpr_param_value v
--                         , qpr_group_report r
--                     where r.report_name       = 'PS_MC_ISSUING'
--                       and g.id                = r.id
--                       and gp.group_id(+)      = g.id
--                       and p.id(+)             = gp.param_id
--                       and v.param_group_id(+) = gp.id
--                       and v.id_param_value(+) = gp.param_id
--                       and v.year(+)           = i_year
--                       and ceil(nvl(v.month_num(+), i_quarter*3)/3) = i_quarter
--                       and v.card_type(+)      = l_card_type
--                       and v.inst_id(+)        = gp.inst_id
--                       and g.priority is not null
--                       and nvl(gp.priority,0) != -1
--                       and gp.id in (1204, 1205, 1206)
--                     group by gp.id
--                   ) v
--             union
--            select max(v.group_id)       as group_id
--                 , max(v.group_desc)     as group_desc
--                 , 1110                  as param_id
--                 , '4. Total (1+2+3)'    as param_desc
--                 , i_year                as year
--                 , trim(to_char(sum(nvl(v.value_1,0)), 'FM999999999999990')) as value_1
--                 , trim(to_char(sum(nvl(v.value_2,0)), 'FM999999999999990d00', 'nls_numeric_characters=,.')) as value_2
--                 , trim(to_char(sum(nvl(v.value_3,0)), 'FM999999999999990')) as value_3
--                 , l_card_type           as card_type
--                 , max(v.group_priority) as group_priority
--              from (
--                    select max(g.group_desc)            as group_desc
--                         , sum(nvl(v.value_1,0))        as value_1
--                         , round(sum(nvl(v.value_2,0))) as value_2
--                         , sum(nvl(v.value_3,0))        as value_3
--                         , max(g.priority)              as group_priority
--                         , gp.id                        as group_id
--                      from qpr_group g
--                         , (select id, param_id, group_id, priority, inst_id
--                              from qpr_param_group gp , inst) gp
--                         , qpr_param p
--                         , qpr_param_value v
--                         , qpr_group_report r
--                     where r.report_name       = 'PS_MC_ISSUING'
--                       and g.id                = r.id
--                       and gp.group_id(+)      = g.id
--                       and p.id(+)             = gp.param_id
--                       and v.param_group_id(+) = gp.id
--                       and v.id_param_value(+) = gp.param_id
--                       and v.year(+)           = i_year
--                       and ceil(nvl(v.month_num(+), i_quarter*3)/3) = i_quarter
--                       and v.card_type(+)      = l_card_type
--                       and v.inst_id(+)        = gp.inst_id
--                       and g.priority is not null
--                       and nvl(gp.priority,0) != -1
--                       and gp.id in (1209, 1210, 1211)
--                     group by gp.id
--                   ) v
         ) v
        , qpr_group g
      where g.id = v.group_id
      order by v.group_priority
             , v.param_id nulls first
     );

    --if no data
    if l_detail.getclobval() = '<issuing></issuing>' then
        select
            xmlelement("issuing"
                    , xmlagg(
                        xmlelement("param"
                            , xmlelement("group_id", null)
                            , xmlelement("group_desc", null)
                            , xmlelement("param_id", null)
                            , xmlelement("param_desc", null)
                            , xmlelement("year", null)
                            , xmlelement("value_1", null)
                            , xmlelement("value_2", null)
                            , xmlelement("value_3", null)
                            , xmlelement("col_1_name", null)
                            , xmlelement("col_2_name", null)
                            , xmlelement("col_3_name", null)
                        )
                    )
                )
        into l_detail from dual ;
    end if;

    select xmlelement (
               "report"
             , l_header
             , l_detail
           ) r
      into l_result
      from dual;


    o_xml := l_result.getclobval();

    trc_log_pkg.debug (
         i_text => 'qpr_api_report_pkg.mc_issuing - ok'
    );

exception
    when no_data_found then
        select
            xmlelement("issuing", '')
        into
            l_detail
        from
            dual;

        trc_log_pkg.debug (
            i_text  => 'No data found'
        );

end;

procedure mc_issuing_maestro(
    o_xml                       out clob
    , i_card_type_id            in  com_api_type_pkg.t_tiny_id
    , i_program_categories      in  com_api_type_pkg.t_name
    , i_year                    in  com_api_type_pkg.t_tiny_id
    , i_quarter                 in  com_api_type_pkg.t_sign
    , i_inst_id                 in  com_api_type_pkg.t_inst_id
    , i_lang                    in  com_api_type_pkg.t_dict_value
)is
    l_card_type        com_api_type_pkg.t_name;
    l_lang             com_api_type_pkg.t_dict_value;
    l_header           xmltype;
    l_detail           xmltype;
    l_result           xmltype;
    l_cmid             com_api_type_pkg.t_cmid;
begin
    trc_log_pkg.debug (
            i_text          => 'qpr_api_report_pkg.mc_maestro [#1][#2][#3][#4][#5]'
            , i_env_param1  => i_lang
            , i_env_param2  => i_year
            , i_env_param3  => i_quarter
            , i_env_param4  => i_card_type_id
            , i_env_param5  => i_inst_id
    );

    l_lang := nvl( i_lang, get_user_lang );
    l_card_type := com_api_i18n_pkg.get_text('NET_CARD_TYPE','NAME', i_card_type_id, l_lang)|| ' - '||i_program_categories;

    select max(nvl(v.cmid, '0000'))
      into l_cmid
      from qpr_param_value v
         , (select id as inst_id
              from ost_institution i
              connect by prior id = parent_id
              start with id = i_inst_id
           ) inst
     where v.year     = i_year
       and ceil(nvl(v.month_num, i_quarter*3)/3) = i_quarter
       and v.inst_id  = inst.inst_id;

    -- header
    select
        xmlconcat(
            xmlelement("card_type_id", i_card_type_id)
            , xmlelement("card_type", l_card_type)
            , xmlelement("year", i_year)
            , xmlelement("quarter", i_quarter)
            , xmlelement("cmid", l_cmid)
        )
    into
        l_header
            from dual;

    select
        xmlelement("issuing"
                , xmlagg(
                    xmlelement("param"
                        , xmlelement("group_id", group_id)
                        , xmlelement("group_desc", group_desc)
                        , xmlelement("param_id", param_id)
                        , xmlelement("param_desc", param_desc)
                        , xmlelement("year", i_year)
                        -- always without precision
                        -- not null for
                        -- V. Card Feature Details
                        -- null for others
                        , xmlelement("value_1", case
                                                    when group_id in (122) then
                                                        trim(to_char(nvl(value_1, 0), 'FM999999999999990'))
                                                    else
                                                        -- here used value instead of NULL because
                                                        -- it will show any discrepancies in source data
                                                        trim(to_char(value_1, 'FM999999999999990'))
                                                end
                          )
                        -- always without precision
                        -- null for
                        -- A. Maestro Cards
                        -- B. Maestro Accounts
                        -- not null for others
                        , xmlelement("value_2", case
                                                    when group_id in (119, 120) then
                                                        -- here used value instead of NULL because
                                                        -- it will show any discrepancies in source data
                                                        trim(to_char(value_2, 'FM999999999999990'))
                                                    else
                                                        trim(to_char(nvl(value_2, 0), 'FM999999999999990'))
                                                end
                          )
                        -- always not null
                        -- without precision
                        -- A. Maestro Cards
                        -- B. Maestro Accounts
                        , xmlelement("value_3", case
                                                    when group_id in (119, 120) then
                                                        trim(to_char(nvl(value_3, 0), 'FM999999999999990'))
                                                    else
                                                        trim(to_char(nvl(round(value_3), 0), 'FM999999999999990'))
                                                end
                          )
                        , xmlelement("col_1_name", mc_rep_col_1_name)
                        , xmlelement("col_2_name", mc_rep_col_2_name)
                        , xmlelement("col_3_name", mc_rep_col_3_name)
                    )
                )
            )
    into
        l_detail
    from(
        select v.*
             , g.mc_rep_col_1_name
             , g.mc_rep_col_2_name
             , g.mc_rep_col_3_name
          from (
            with inst as
                 (select id as inst_id
                    from ost_institution i
                    connect by prior id = parent_id
                    start with id = i_inst_id
                 )
            select g.id                   as group_id
                 , g.group_desc
                 , p.id                   as param_id
                 , p.param_desc
                 , i_year                 as year
                 , sum(v.value_1)         as value_1
                 , sum(v.value_2)         as value_2
                 , sum(v.value_3)         as value_3
                 , l_card_type   as card_type
                 , g.priority    as group_priority
              from qpr_group g
                 , (select id, param_id, group_id, priority, inst_id
                      from qpr_param_group gp , inst) gp
                 , qpr_param p
                 , qpr_param_value v
                 , qpr_group_report r
             where r.report_name       = 'PS_MC_MAESTRO'
               and g.id                = r.id
               and gp.group_id(+)      = g.id
               and p.id(+)             not in (1044, 2059)
               and p.id(+)             = gp.param_id
               and v.param_group_id(+) = gp.id
               and v.id_param_value(+) = gp.param_id
               and v.year(+)           = i_year
               and ceil(nvl(v.month_num(+), i_quarter*3)/3) = i_quarter
               and v.card_type(+)      = l_card_type
               and v.inst_id(+)        = gp.inst_id
               and g.priority is not null
               and gp.id(+) not in (1086, 1092)
               and nvl(gp.priority,0) != -1
          group by g.id
                 , g.group_desc
                 , p.id
                 , p.param_desc
                 , g.priority
             union
            -- I. Maestro Purchase (Retail Sales) Activity
            -- 6. Total Maestro Purchase Activity (sum of 1+2+3+4a+4b)
            select g.id                   as group_id
                 , g.group_desc           as group_desc
                 , p.id                   as param_id
                 , p.param_desc           as param_desc
                 , i_year                 as year
                 , v.value_1              as value_1
                 , v.value_2              as value_2
                 , v.value_3              as value_3
                 , l_card_type            as card_type
                 , g.priority              as group_priority
              from (
                    select sum(v.value_1)        as value_1
                         , sum(v.value_2)        as value_2
                         , sum(v.value_3)        as value_3
                      from qpr_group g
                         , (select id, param_id, group_id, priority, inst_id
                              from qpr_param_group gp , inst) gp
                         , qpr_param p
                         , qpr_param_value v
                         , qpr_group_report r
                     where r.report_name       = 'PS_MC_MAESTRO'
                       and g.id                = r.id
                       and gp.group_id(+)      = g.id
                       and p.id(+)             = gp.param_id
                       and v.param_group_id(+) = gp.id
                       and v.id_param_value(+) = gp.param_id
                       and v.year(+)           = i_year
                       and ceil(nvl(v.month_num(+), i_quarter*3)/3) = i_quarter
                       and v.card_type(+)      = l_card_type
                       and v.inst_id(+)        = gp.inst_id
                       and g.priority is not null
                       and nvl(gp.priority,0) != -1
                       and gp.id in (1068, 1069, 1070, 1071, 1072)
                   ) v
                 , qpr_group g
                 , qpr_param p
              where g.id = 116
                and p.id = 1044
             union all
            -- II. Maestro Cash Disbursements (ATM) Activity
            -- 6. Total Maestro Cash Disbursement Activity (sum of 1+2+3+4)
            select g.id                   as group_id
                 , g.group_desc           as group_desc
                 , p.id                   as param_id
                 , p.param_desc           as param_desc
                 , i_year                 as year
                 , v.value_1              as value_1
                 , v.value_2              as value_2
                 , v.value_3              as value_3
                 , l_card_type            as card_type
                 , g.priority             as group_priority
              from (
                    select sum(v.value_1)        as value_1
                         , sum(v.value_2)        as value_2
                         , sum(v.value_3)        as value_3
                      from qpr_group g
                         , (select id, param_id, group_id, priority, inst_id
                              from qpr_param_group gp , inst) gp
                         , qpr_param p
                         , qpr_param_value v
                         , qpr_group_report r
                     where r.report_name       = 'PS_MC_MAESTRO'
                       and g.id                = r.id
                       and gp.group_id(+)      = g.id
                       and p.id(+)             = gp.param_id
                       and v.param_group_id(+) = gp.id
                       and v.id_param_value(+) = gp.param_id
                       and v.year(+)           = i_year
                       and ceil(nvl(v.month_num(+), i_quarter*3)/3) = i_quarter
                       and v.card_type(+)      = l_card_type
                       and v.inst_id(+)        = gp.inst_id
                       and g.priority is not null
                       and nvl(gp.priority,0) != -1
                       and gp.id in (1074, 1075, 1076, 1077, 1078)
                   ) v
                 , qpr_group g
                 , qpr_param p
              where g.id = 117
                and p.id = 2059
             union all
            -- IV. Detail Activity Breakout
            -- 1. Total Domestic Activity (I.1+I.2+I.3+II.1+II.2+II.3)
            select g.id                           as group_id
                 , g.group_desc                   as group_desc
                 , p.id                           as param_id
                 , p.param_desc                   as param_desc
                 , i_year                         as year
                 , v.value_1                      as value_1
                 , v.value_2                      as value_2
                 , v.value_3                      as value_3
                 , l_card_type                    as card_type
                 , g.priority                     as group_priority
              from (
                    select sum(v.value_1)        as value_1
                         , sum(v.value_2)        as value_2
                         , sum(v.value_3)        as value_3
                      from qpr_group g
                         , (select id, param_id, group_id, priority, inst_id
                              from qpr_param_group gp , inst) gp
                         , qpr_param p
                         , qpr_param_value v
                         , qpr_group_report r
                     where r.report_name       = 'PS_MC_MAESTRO'
                       and g.id                = r.id
                       and gp.group_id(+)      = g.id
                       and p.id(+)             = gp.param_id
                       and v.param_group_id(+) = gp.id
                       and v.id_param_value(+) = gp.param_id
                       and v.year(+)           = i_year
                       and ceil(nvl(v.month_num(+), i_quarter*3)/3) = i_quarter
                       and v.card_type(+)      = l_card_type
                       and v.inst_id(+)        = gp.inst_id
                       and gp.id in (1068, 1069, 1070, 1074, 1075, 1076)
                       and g.priority is not null
                       and nvl(gp.priority,0) != -1
                   ) v
                 , qpr_group g
                 , qpr_param p
              where g.id = 121
                and p.id = 1051
         ) v
        , qpr_group g
      where g.id = v.group_id
      order by v.group_priority
             , v.param_id nulls first
     );

    --if no data
    if l_detail.getclobval() = '<issuing></issuing>' then
        select
            xmlelement("issuing"
                    , xmlagg(
                        xmlelement("param"
                            , xmlelement("group_id", null)
                            , xmlelement("group_desc", null)
                            , xmlelement("param_id", null)
                            , xmlelement("param_desc", null)
                            , xmlelement("year", null)
                            , xmlelement("value_1", null)
                            , xmlelement("value_2", null)
                            , xmlelement("value_3", null)
                            , xmlelement("col_1_name", null)
                            , xmlelement("col_2_name", null)
                            , xmlelement("col_3_name", null)
                        )
                    )
                )
        into l_detail from dual ;
    end if;

    select
        xmlelement (
            "report"
            , l_header
            , l_detail
        ) r
      into l_result
      from dual;


    o_xml := l_result.getclobval();

    trc_log_pkg.debug (
         i_text => 'qpr_api_report_pkg.mc_maestro - ok'
    );

exception
    when no_data_found then
        select
            xmlelement("issuing", '')
        into
            l_detail
        from
            dual;

        trc_log_pkg.debug (
            i_text  => 'No data found'
        );
end;

procedure mc_acquiring(
    o_xml                       out clob
    , i_year                    in  com_api_type_pkg.t_tiny_id
    , i_quarter                 in  com_api_type_pkg.t_sign
    , i_inst_id                 in  com_api_type_pkg.t_inst_id
    , i_lang                    in  com_api_type_pkg.t_dict_value
)is
    l_card_type        com_api_type_pkg.t_name;
    l_header           xmltype;
    l_detail           xmltype;
    l_result           xmltype;
    l_cmid             com_api_type_pkg.t_cmid;
begin
    trc_log_pkg.debug (
            i_text          => 'qpr_api_report_pkg.mc_acquiring [#1][#2][#3][#4]'
            , i_env_param1  => i_lang
            , i_env_param2  => i_year
            , i_env_param3  => i_quarter
            , i_env_param4  => i_inst_id
    );

    l_card_type := 'MasterCard Acquiring';

    select max(nvl(v.cmid, '0000'))
      into l_cmid
      from qpr_param_value v
         , (select id as inst_id
              from ost_institution i
              connect by prior id = parent_id
              start with id = i_inst_id
           ) inst
     where v.year     = i_year
       and ceil(nvl(v.month_num, i_quarter*3)/3) = i_quarter
       and v.inst_id  = inst.inst_id;

    -- header
    select
        xmlconcat(
            xmlelement("card_type_id", 1002)
            , xmlelement("card_type", l_card_type)
            , xmlelement("year", i_year)
            , xmlelement("quarter", i_quarter)
            , xmlelement("cmid", l_cmid)
        )
    into
        l_header
            from dual;

    select
        xmlelement("acquiring"
                , xmlagg(
                    xmlelement("param"
                        , xmlelement("group_id", group_id)
                        , xmlelement("group_desc", group_desc)
                        , xmlelement("param_id", param_id)
                        , xmlelement("param_desc", param_desc)
                        , xmlelement("year", i_year)
                        -- always without precision
                        -- null for
                        -- IV. Acceptance and its children
                        -- A. Cash Disbursement Locations
                        -- B. Merchants
                        , xmlelement("value_1", case
                                                    when group_id in (129, 130) then
                                                        trim(to_char(value_1, 'FM999999999999990'))
                                                    else
                                                        trim(to_char(nvl(value_1, 0), 'FM999999999999990'))
                                                end
                          )
                        -- without precision for
                        -- IV. Acceptance and its children
                        -- A. Cash Disbursement Locations
                        -- B. Merchants
                        -- always not null
                        , xmlelement("value_2", case
                                                    when group_id in (129, 130) then
                                                        trim(to_char(nvl(value_2, 0), 'FM999999999999990'))
                                                    else
                                                        trim(to_char(nvl(round(value_2), 0), 'FM999999999999990'))
                                                end
                          )
                        , xmlelement("col_1_name", mc_rep_col_1_name)
                        , xmlelement("col_2_name", mc_rep_col_2_name)
                        , xmlelement("form", case
                                                 when group_id in (129, 130) then
                                                     'Product Code CA - Acceptance Form'
                                                 else
                                                     case when nvl(value_3, com_api_const_pkg.CREDIT) = com_api_const_pkg.CREDIT then 'Product Code CB - Acquiring Credit'
                                                     else 'Product Code CD - Acquiring Debit'
                                                     end
                                             end
                          )
                    )
                )
            )
    into
        l_detail
    from(
        select v.*
             , g.mc_rep_col_1_name
             , g.mc_rep_col_2_name
             , g.priority
          from (
            with inst as
                 (select id as inst_id
                    from ost_institution i
                    connect by prior id = parent_id
                    start with id = i_inst_id
                 )
                 , imp as
                 (select com_api_const_pkg.CREDIT impact from dual
                  union all
                  select com_api_const_pkg.DEBIT impact from dual
                 )
            -- for I. Retail Sales (Purchases)
            -- for II. Total Cash Advances
            -- for III. Refunds / Returns / Credits
            select g.id          as group_id
                 , g.group_desc
                 , p.id          as param_id
                 , p.param_desc
                 , i_year        as year
                 , sum(v.value_1) as value_1
                 , sum(v.value_2) as value_2
                 , gp.impact      as value_3
              from qpr_group g
                 , (select id, param_id, group_id, priority, inst_id, impact
                      from qpr_param_group gp, inst, imp) gp
                 , qpr_param p
                 , qpr_param_value v
                 , qpr_group_report r
             where r.report_name       = 'PS_MC_ACQUIRING'
               and g.id                = r.id
               and gp.group_id(+)      = g.id
               and p.id(+)            != 1068
               and p.id(+)             = gp.param_id
               and v.param_group_id(+) = gp.id
               and v.id_param_value(+) = gp.param_id
               and v.year(+)           = i_year
               and ceil(nvl(v.month_num(+), i_quarter*3)/3) = i_quarter
               and v.inst_id(+)        = gp.inst_id
               and v.value_3(+)        = gp.impact
               and g.id in (123, 124, 126, 127)
          group by g.id
                 , g.group_desc
                 , p.id
                 , p.param_desc
                 , gp.impact
            union all
            -- for I. Retail Sales (Purchases)
            -- for II. Total Cash Advances
            -- for III. Refunds / Returns / Credits
            -- 6. Total (A1+A2+A3+A4+A5)
            select g.id                         as group_id
                 , g.group_desc
                 , p.id                         as param_id
                 , p.param_desc                 as param_desc
                 , i_year                       as year
                 , sum(v.value_1)               as value_1
                 , sum(v.value_2)               as value_2
                 , gp.impact                    as value_3
              from qpr_group g
                 , (select id, param_id, group_id, priority, inst_id, impact
                      from qpr_param_group gp, inst, imp) gp
                 , qpr_param_value v
                 , qpr_group_report r
                 , qpr_param p
             where r.report_name       = 'PS_MC_ACQUIRING'
               and g.id                = r.id
               and gp.group_id         = g.id
               and p.id                = 1068
               and gp.param_id        != p.id
               and v.param_group_id(+) = gp.id
               and v.id_param_value(+) = gp.param_id
               and v.year(+)           = i_year
               and ceil(nvl(v.month_num(+), i_quarter*3)/3) = i_quarter
               and v.inst_id(+)        = gp.inst_id
               and v.value_3(+)        = gp.impact
               and g.id in (123, 124, 126, 127)
          group by g.id
                 , g.group_desc
                 , p.id
                 , p.param_desc
                 , gp.impact
            union all
            -- for IV. Acceptance and its children
            --   A. Cash Disbursement Locations
            --   B. Merchants
            select g.id          as group_id
                 , g.group_desc
                 , p.id          as param_id
                 , p.param_desc
                 , i_year        as year
                 , sum(v.value_1)  as value_1
                 , sum(v.value_2)  as value_2
                 , to_number(com_api_const_pkg.NONE)    as value_3
              from qpr_group g
                 , (select id, param_id, group_id, priority, inst_id
                      from qpr_param_group gp, inst) gp
                 , qpr_param p
                 , qpr_param_value v
                 , qpr_group_report r
             where r.report_name       = 'PS_MC_ACQUIRING'
               and g.id                = r.id
               and gp.group_id(+)      = g.id
               and p.id(+)            != 1068
               and p.id(+)             = gp.param_id
               and v.param_group_id(+) = gp.id
               and v.id_param_value(+) = gp.param_id
               and v.year(+)           = i_year
               and ceil(nvl(v.month_num(+), i_quarter*3)/3) = i_quarter
               and v.inst_id(+)        = gp.inst_id
               and g.id in (129, 130)
          group by g.id
                 , g.group_desc
                 , p.id
                 , p.param_desc
         ) v
         , qpr_group g
      where g.id = v.group_id
      order by decode(v.value_3, com_api_const_pkg.CREDIT, 0, com_api_const_pkg.DEBIT, 1, 2)
             , g.priority
             , v.param_id nulls first
     );

    --if no data
    if l_detail.getclobval() = '<acquiring></acquiring>' then
        select
            xmlelement("acquiring"
                    , xmlagg(
                        xmlelement("param"
                            , xmlelement("group_id", null)
                            , xmlelement("group_desc", null)
                            , xmlelement("param_id", null)
                            , xmlelement("param_desc", null)
                            , xmlelement("year", null)
                            , xmlelement("value_1", null)
                            , xmlelement("value_2", null)
                            , xmlelement("col_1_name", null)
                            , xmlelement("col_2_name", null)
                            , xmlelement("form", null)
                        )
                    )
                )
        into l_detail from dual ;
    end if;

    select
        xmlelement (
            "report"
            , l_header
            , l_detail
        ) r
      into l_result
      from dual;


    o_xml := l_result.getclobval();

    trc_log_pkg.debug (
         i_text => 'qpr_api_report_pkg.mc_acquiring - ok'
    );

exception
    when no_data_found then
        select
            xmlelement("acquiring", '')
        into
            l_detail
        from
            dual;

        trc_log_pkg.debug (
            i_text  => 'No data found'
        );
end;

procedure mc_acquiring_maestro(
    o_xml                       out clob
    , i_year                    in  com_api_type_pkg.t_tiny_id
    , i_quarter                 in  com_api_type_pkg.t_sign
    , i_inst_id                 in  com_api_type_pkg.t_inst_id
    , i_lang                    in  com_api_type_pkg.t_dict_value
)is
    l_card_type        com_api_type_pkg.t_name;
    l_header           xmltype;
    l_detail           xmltype;
    l_result           xmltype;
    l_cmid             com_api_type_pkg.t_cmid;
begin
    trc_log_pkg.debug (
            i_text          => 'qpr_api_report_pkg.mc_acquiring_maestro [#1][#2][#3][#4]'
            , i_env_param1  => i_lang
            , i_env_param2  => i_year
            , i_env_param3  => i_quarter
            , i_env_param4  => i_inst_id
    );

    l_card_type := 'Maestro Acquiring';

    select max(nvl(cmid, '0000'))
      into l_cmid
      from qpr_param_value v
         , (select id as inst_id
              from ost_institution i
              connect by prior id = parent_id
              start with id = i_inst_id
           ) inst
     where v.year     = i_year
       and ceil(nvl(v.month_num, i_quarter*3)/3) = i_quarter
       and v.inst_id  = inst.inst_id;

    -- header
    select
        xmlconcat(
            xmlelement("card_type_id", 1005)
            , xmlelement("card_type", l_card_type)
            , xmlelement("year", i_year)
            , xmlelement("quarter", i_quarter)
            , xmlelement("cmid", l_cmid)
        )
    into
        l_header
            from dual;

    select
        xmlelement("acquiring"
                , xmlagg(
                    xmlelement("param"
                        , xmlelement("group_id", group_id)
                        , xmlelement("group_desc", group_desc)
                        , xmlelement("param_id", param_id)
                        , xmlelement("param_desc", param_desc)
                        , xmlelement("year", i_year)
                        -- always without precision
                        -- null for
                        -- III. Maestro Acceptance
                        , xmlelement("value_1", case
                                                    when group_id in (133) then
                                                        trim(to_char(value_1, 'FM999999999999990'))
                                                    else
                                                        trim(to_char(nvl(value_1, 0), 'FM999999999999990'))
                                                end
                          )
                        -- without precision for
                        -- III. Maestro Acceptance
                        -- always not null
                        , xmlelement("value_2", case
                                                    when group_id in (133) then
                                                        trim(to_char(nvl(value_2, 0), 'FM999999999999990'))
                                                    else
                                                        trim(to_char(nvl(round(value_2), 0), 'FM999999999999990'))
                                                end
                          )
                        , xmlelement("col_1_name", mc_rep_col_1_name)
                        , xmlelement("col_2_name", mc_rep_col_2_name)
                    )
                )
            )
    into
        l_detail
    from(
        select v.*
             , g.mc_rep_col_1_name
             , g.mc_rep_col_2_name
          from (
            with inst as
                 (select id as inst_id
                    from ost_institution i
                    connect by prior id = parent_id
                    start with id = i_inst_id
                 )
            select g.id          as group_id
                 , g.group_desc
                 , p.id          as param_id
                 , p.param_desc
                 , i_year        as year
                 , sum(v.value_1) as value_1
                 , sum(v.value_2) as value_2
              from qpr_group g
                 , (select id, param_id, group_id, priority, inst_id
                      from qpr_param_group gp , inst) gp
                 , qpr_param p
                 , qpr_param_value v
                 , qpr_group_report r
             where r.report_name       = 'PS_MC_ACQ_MAESTRO'
               and g.id                = r.id
               and gp.group_id(+)      = g.id
               and p.id(+)             not in (2060, 2061)
               and p.id(+)             = gp.param_id
               and v.param_group_id(+) = gp.id
               and v.id_param_value(+) = gp.param_id
               and v.year(+)           = i_year
               and ceil(nvl(v.month_num(+), i_quarter*3)/3) = i_quarter
               and v.inst_id(+)        = gp.inst_id
               and gp.id(+)           != 1164
            group by
                   g.id
                 , g.group_desc
                 , p.id
                 , p.param_desc
             union all
            -- IV. Detail Acquiring Activity Breakout
            -- 1. Total Domestic Activity (I.1+I.2+I.3+II.1+II.2+II.3)
            select g.id          as group_id
                 , g.group_desc  as group_desc
                 , p.id          as param_id
                 , p.param_desc  as param_desc
                 , i_year        as year
                 , v.value_1     as value_1
                 , v.value_2 as value_2
              from (
                    select sum(v.value_1) as value_1
                         , sum(v.value_2) as value_2
                      from qpr_group g
                         , (select id, param_id, group_id, priority, inst_id
                              from qpr_param_group gp , inst) gp
                         , qpr_param p
                         , qpr_param_value v
                         , qpr_group_report r
                     where r.report_name       = 'PS_MC_ACQ_MAESTRO'
                       and g.id                = r.id
                       and gp.group_id(+)      = g.id
                       and p.id(+)             = gp.param_id
                       and v.param_group_id(+) = gp.id
                       and v.id_param_value(+) = gp.param_id
                       and v.year(+)           = i_year
                       and ceil(nvl(v.month_num(+), i_quarter*3)/3) = i_quarter
                       and v.inst_id(+)        = gp.inst_id
                       and gp.id in (1143, 1144, 1145, 1149, 1150, 1151)
                   ) v
                 , qpr_group g
                 , qpr_param p
              where g.id = 134
                and p.id = 1092
            union all
            -- I. Maestro Acquiring Purchase (Retail Sales) Activity
            -- 6. Total Maestro Purchase Activity (sum of 1+2+3+4+5)
            select g.id                         as group_id
                 , g.group_desc
                 , p.id                         as param_id
                 , p.param_desc                 as param_desc
                 , i_year                       as year
                 , sum(v.value_1)               as value_1
                 , sum(v.value_2)               as value_2
              from qpr_group g
                 , (select id, param_id, group_id, priority, inst_id
                      from qpr_param_group gp , inst) gp
                 , qpr_param p
                 , qpr_param_value v
                 , qpr_group_report r
             where r.report_name       = 'PS_MC_ACQ_MAESTRO'
               and g.id                = r.id
               and gp.group_id(+)      = g.id
               and v.param_group_id(+) = gp.id
               and v.id_param_value(+) = gp.param_id
               and v.year(+)           = i_year
               and ceil(nvl(v.month_num(+), i_quarter*3)/3) = i_quarter
               and v.inst_id(+)        = gp.inst_id
               and g.id                = 131
               and p.id                = 2060
          group by g.id
                 , g.group_desc
                 , p.id
                 , p.param_desc
            union all
            -- II. Maestro Acquiring Cash Disbursements (ATM) Activity
            -- 6. Total Maestro Cash Disbursement Activity (sum of 1+2+3+4+5)
            select g.id                         as group_id
                 , g.group_desc
                 , p.id                         as param_id
                 , p.param_desc                 as param_desc
                 , i_year                       as year
                 , sum(v.value_1)               as value_1
                 , sum(v.value_2)               as value_2
              from qpr_group g
                 , (select id, param_id, group_id, priority, inst_id
                      from qpr_param_group gp , inst) gp
                 , qpr_param p
                 , qpr_param_value v
                 , qpr_group_report r
             where r.report_name       = 'PS_MC_ACQ_MAESTRO'
               and g.id                = r.id
               and gp.group_id(+)      = g.id
               and v.param_group_id(+) = gp.id
               and v.id_param_value(+) = gp.param_id
               and v.year(+)           = i_year
               and ceil(nvl(v.month_num(+), i_quarter*3)/3) = i_quarter
               and v.inst_id(+)        = gp.inst_id
               and g.id                = 132
               and p.id                = 2061
          group by g.id
                 , g.group_desc
                 , p.id
                 , p.param_desc
         ) v
         , qpr_group g
      where g.id = v.group_id
      order by g.priority
             , v.param_desc nulls first
     );

    --if no data
    if l_detail.getclobval() = '<acquiring></acquiring>' then
        select
            xmlelement("acquiring"
                    , xmlagg(
                        xmlelement("param"
                            , xmlelement("group_id", null)
                            , xmlelement("group_desc", null)
                            , xmlelement("param_id", null)
                            , xmlelement("param_desc", null)
                            , xmlelement("year", null)
                            , xmlelement("value_1", null)
                            , xmlelement("value_2", null)
                            , xmlelement("col_1_name", null)
                            , xmlelement("col_2_name", null)
                        )
                    )
                )
        into l_detail from dual ;
    end if;

    select
        xmlelement (
            "report"
            , l_header
            , l_detail
        ) r
      into l_result
      from dual;


    o_xml := l_result.getclobval();

    trc_log_pkg.debug (
         i_text => 'qpr_api_report_pkg.mc_acquiring_maestro - ok'
    );

exception
    when no_data_found then
        select
            xmlelement("acquiring", '')
        into
            l_detail
        from
            dual;

        trc_log_pkg.debug (
            i_text  => 'No data found'
        );
end;

procedure mc_acquiring_cirrus(
    o_xml                       out clob
    , i_year                    in  com_api_type_pkg.t_tiny_id
    , i_quarter                 in  com_api_type_pkg.t_sign
    , i_inst_id                 in  com_api_type_pkg.t_inst_id
    , i_lang                    in  com_api_type_pkg.t_dict_value
)is
    l_header           xmltype;
    l_detail           xmltype;
    l_result           xmltype;
    l_cmid             com_api_type_pkg.t_cmid;
begin
    trc_log_pkg.debug (
            i_text          => 'qpr_api_report_pkg.mc_acquiring_cirrus [#1][#2][#3][#4]'
            , i_env_param1  => i_lang
            , i_env_param2  => i_year
            , i_env_param3  => i_quarter
            , i_env_param4  => i_inst_id
    );

    select max(nvl(cmid, '0000'))
      into l_cmid
      from qpr_param_value v
         , (select id as inst_id
              from ost_institution i
              connect by prior id = parent_id
              start with id = i_inst_id
           ) inst
     where v.year     = i_year
       and ceil(nvl(month_num, i_quarter*3)/3) = i_quarter
       and v.inst_id  = inst.inst_id;

    -- header
    select
        xmlconcat(
            xmlelement("card_type_id", 1005)
            , xmlelement("card_type", 'Cirrus Acquiring')
            , xmlelement("year", i_year)
            , xmlelement("quarter", i_quarter)
            , xmlelement("cmid", l_cmid)
        )
    into
        l_header
            from dual;

    select
        xmlelement("acquiring"
                , xmlagg(
                    xmlelement("param"
                        , xmlelement("group_id", group_id)
                        , xmlelement("group_desc", group_desc)
                        , xmlelement("param_id", param_id)
                        , xmlelement("param_desc", param_desc)
                        , xmlelement("year", i_year)
                        , xmlelement("value_1", value_1)
                        , xmlelement("value_2", value_2)
                        , xmlelement("col_1_name", mc_rep_col_1_name)
                        , xmlelement("col_2_name", mc_rep_col_2_name)
                    )
                )
            )
    into
        l_detail
    from(
        select v.*
             , g.mc_rep_col_1_name
             , g.mc_rep_col_2_name
          from (
            with inst as
                 (select id as inst_id
                    from ost_institution i
                    connect by prior id = parent_id
                    start with id = i_inst_id
                 )
            select g.id          as group_id
                 , g.group_desc
                 , p.id          as param_id
                 , p.param_desc
                 , i_year        as year
                 , trim(to_char(sum(nvl(v.value_1,0)), 'FM999999999999990')) as value_1
                 , trim(to_char(round(sum(nvl(v.value_2,0))), 'FM999999999999990')) as value_2
              from qpr_group g
                 , (select id, param_id, group_id, priority, inst_id
                      from qpr_param_group gp , inst) gp
                 , qpr_param p
                 , qpr_param_value v
                 , qpr_group_report r
             where r.report_name       = 'PS_MC_CIRRUS_ACQ'
               and g.id                = r.id
               and gp.group_id(+)      = g.id
               and p.id(+)             = gp.param_id
               and v.param_group_id(+) = gp.id
               and v.id_param_value(+) = gp.param_id
               and v.year(+)           = i_year
               and ceil(nvl(v.month_num(+), i_quarter*3)/3) = i_quarter
               and v.inst_id(+)        = gp.inst_id
            group by
                   g.id
                 , g.group_desc
                 , p.id
                 , p.param_desc
         ) v
         , qpr_group g
      where g.id = v.group_id
      order by g.priority
             , v.param_id nulls first
     );

    --if no data
    if l_detail.getclobval() = '<acquiring></acquiring>' then
        select
            xmlelement("acquiring"
                    , xmlagg(
                        xmlelement("param"
                            , xmlelement("group_id", null)
                            , xmlelement("group_desc", null)
                            , xmlelement("param_id", null)
                            , xmlelement("param_desc", null)
                            , xmlelement("year", null)
                            , xmlelement("value_1", null)
                            , xmlelement("value_2", null)
                            , xmlelement("col_1_name", null)
                            , xmlelement("col_2_name", null)
                        )
                    )
                )
        into l_detail from dual ;
    end if;

    select
        xmlelement (
            "report"
            , l_header
            , l_detail
        ) r
      into l_result
      from dual;


    o_xml := l_result.getclobval();

    trc_log_pkg.debug (
         i_text => 'qpr_api_report_pkg.mc_acquiring_cirrus - ok'
    );

exception
    when no_data_found then
        select
            xmlelement("acquiring", '')
        into
            l_detail
        from
            dual;

        trc_log_pkg.debug (
            i_text  => 'No data found'
        );
end;

procedure mc_machine_readable(
    o_xml                       out clob
    , i_year                    in  com_api_type_pkg.t_tiny_id
    , i_quarter                 in  com_api_type_pkg.t_sign
    , i_inst_id                 in  com_api_type_pkg.t_inst_id
    , i_lang                    in  com_api_type_pkg.t_dict_value
)
is
    l_lang             com_api_type_pkg.t_dict_value;
    l_header           xmltype;
    l_detail           xmltype;
    l_result           xmltype;
    l_cmid             com_api_type_pkg.t_cmid;
    l_user_name        com_api_type_pkg.t_name;
    l_phone_number     com_api_type_pkg.t_name;
    l_email            com_api_type_pkg.t_name;
    l_person_id        com_api_type_pkg.t_medium_id;
    l_contact_id       com_api_type_pkg.t_medium_id;
    l_card_type_id     com_api_type_pkg.t_tiny_id;
    l_current_date     com_api_type_pkg.t_date_long;
    l_send_date        com_api_type_pkg.t_date_long;
    l_curr_code        com_api_type_pkg.t_curr_code;
    l_cmid_maestro     com_api_type_pkg.t_cmid;
begin
    trc_log_pkg.debug (
            i_text          => 'qpr_api_report_pkg.mc_machine_readable [#1][#2][#3][#4]'
            , i_env_param1  => i_lang
            , i_env_param2  => i_year
            , i_env_param3  => i_quarter
            , i_env_param4  => i_inst_id
    );

    l_lang := nvl( i_lang, get_user_lang );

    select max(nvl(v.cmid, '00000'))
      into l_cmid
      from qpr_param_value v
         , (select id as inst_id
              from ost_institution i
             where i.id not in (select distinct parent_id from ost_institution where parent_id is not null)
            connect by prior id = parent_id
            start with id = i_inst_id
           ) inst
     where v.year     = i_year
       and ceil(nvl(v.month_num, i_quarter*3)/3) = i_quarter
       and v.inst_id  = inst.inst_id
       and v.card_type_id = mcw_api_const_pkg.QR_MASTER_CARD_TYPE;

    select max(nvl(v.cmid, '00000'))
      into l_cmid_maestro
      from qpr_param_value v
         , (select id as inst_id
              from ost_institution i
             where i.id not in (select distinct parent_id from ost_institution where parent_id is not null)
            connect by prior id = parent_id
            start with id = i_inst_id
           ) inst
     where v.year     = i_year
       and ceil(nvl(v.month_num, i_quarter*3)/3) = i_quarter
       and v.inst_id  = inst.inst_id
       and v.card_type_id = mcw_api_const_pkg.QR_MAESTRO_CARD_TYPE;

    select max(nvl(v.curr_code, '000'))
      into l_curr_code
      from qpr_param_value v
         , (select id as inst_id
              from ost_institution i
             where i.id not in (select distinct parent_id from ost_institution where parent_id is not null)
            connect by prior id = parent_id
            start with id = i_inst_id
           ) inst
     where v.year     = i_year
       and ceil(nvl(v.month_num, i_quarter*3)/3) = i_quarter
       and v.inst_id  = inst.inst_id;

    l_current_date := to_char(get_sysdate, 'mm/dd/yyyy');
    l_send_date := to_char(get_sysdate, 'mm/dd/yyyy');
    l_card_type_id := mcw_api_const_pkg.QR_MASTER_CARD_TYPE;

    select max(p.id)
      into l_person_id
      from acm_user u
         , com_person p
         , acm_user_role ur
         , acm_role r
         , acm_user_inst ui
     where p.id       = u.person_id
       and ur.user_id = u.id
       and r.id       = ur.role_id
       and r.name     = 'MC_MRQR_CONTACT_PERSON'
       and ui.user_id = u.id
       and ui.inst_id = i_inst_id;

    if l_person_id is null then
        l_person_id := acm_api_user_pkg.get_person_id(
                           i_user_name => get_user_name);
    end if;

    l_user_name := com_ui_person_pkg.get_person_name(l_person_id, l_lang);

    begin
        select contact_id
          into l_contact_id
          from com_contact_object co
         where co.object_id = l_person_id
           and co.entity_type = com_api_const_pkg.ENTITY_TYPE_PERSON
           and co.contact_type = com_api_const_pkg.CONTACT_TYPE_PRIMARY;

        l_phone_number := com_api_contact_pkg.get_contact_string(
                              i_contact_id        => l_contact_id
                            , i_commun_method     => com_api_const_pkg.COMMUNICATION_METHOD_PHONE
                            , i_start_date        => get_sysdate
                          );
        if l_phone_number is null then
            l_phone_number := com_api_contact_pkg.get_contact_string(
                                  i_contact_id        => l_contact_id
                                , i_commun_method     => com_api_const_pkg.COMMUNICATION_METHOD_MOBILE
                                , i_start_date        => get_sysdate
                              );
        end if;
        l_email := com_api_contact_pkg.get_contact_string(
                              i_contact_id        => l_contact_id
                            , i_commun_method     => com_api_const_pkg.COMMUNICATION_METHOD_EMAIL
                            , i_start_date        => get_sysdate
                          );
    exception
        when no_data_found then
            l_phone_number := null;
            l_email := null;
    end;
    -- header
    select
        xmlconcat(
            xmlelement("year", i_year)
            , xmlelement("quarter", i_quarter)
            , xmlelement("cmid", substr(l_cmid, -5))
            , xmlelement("cmid_maestro", substr(l_cmid_maestro, -5))
            , xmlelement("user_name", l_user_name)
            , xmlelement("card_type_id", l_card_type_id)
            , xmlelement("current_date", l_current_date)
            , xmlelement("send_date", l_send_date)
            , xmlelement("currency_flag", decode(l_curr_code, com_api_currency_pkg.EURO, 2
                                                            , com_api_currency_pkg.USDOLLAR, 1
                                                            , 0))
            , xmlelement("phone_number", l_phone_number)
            , xmlelement("email", l_email)
        )
      into l_header
      from dual;

    select
        xmlelement("machine_readable"
                , xmlagg(
                    xmlelement("param"
                        , xmlelement("group_id", group_id)
                        , xmlelement("param_id", param_id)
                        , xmlelement("card_type_id", card_type_id)
                        , xmlelement("card_type_feature", card_type_feature)
                        , xmlelement("value_1", trim(to_char(nvl(value_1, 0), 'FM999999999999990')))
                        , xmlelement("value_2", trim(to_char(nvl(round(value_2), 0), 'FM999999999999990')))
                        , xmlelement("value_3", trim(to_char(nvl(round(value_3), 0), 'FM999999999999990')))
                        , xmlelement("impact",  trim(to_char(nvl(impact, 0), 'FM999999999999990')))
                    )
                )
            )
    into
        l_detail
    from(
        select v.group_id
             , v.param_id
             , case
                   when v.param_id in (1030, 2057)
                   then v.val_1
                   else v.value_1
               end as value_1
             , v.value_2
             , v.value_3
             , v.card_type_id
             , v.card_type_feature
             , v.group_priority
             , v.impact
          from (
            with inst as
                 (select id as inst_id
                    from ost_institution i
                    connect by prior id = parent_id
                    start with id = i_inst_id
                 )
             select v.group_id
                  , v.param_id
                  , sum(
                        case when v.param_id in (1008, 1009, 1011, 2056, 2058)
                             then 0
                             else v.value_1
                        end
                       )                 as value_1
                  , sum(
                        case when v.param_id in (1008, 1009, 1011, 2056, 2058, 1030, 1031, 1054, 1055)
                             then 0
                             else v.value_2
                        end
                       )                 as value_2
                  , sum(
                        case when v.param_id in (1030, 1031, 1054, 1055)
                             then 0
                             else v.value_3
                        end
                       )                 as value_3
                  , sum(
                        case when v.param_id in (1030, 2057)
                             then v.val_1
                             else 0
                        end
                       )                 as val_1
                  , v.card_type_id
                  , v.card_type_feature
                  , v.group_priority
                  , v.impact
               from (
                    select g.id                 as group_id
                         , p.id                 as param_id
                         , v.value_1
                         , v.value_2
                         , v.value_3
                         , min(case when p.id in (1030, 2057)
                                    then v.value_1
                                    else 9999999999999
                                end) over (partition by v.card_type_id order by v.value_1) as val_1
                         , v.card_type_id       as card_type_id
                         , v.card_type_feature  as card_type_feature
                         , g.priority           as group_priority
                         , null                 as impact
                      from qpr_group g
                         , (select id, param_id, group_id, priority, inst_id
                              from qpr_param_group gp, inst) gp
                         , qpr_param p
                         , qpr_param_value v
                         , qpr_group_report r
                     where r.report_name       = 'PS_MC_ISSUING'
                       and g.id                = r.id
                       and gp.group_id(+)      = g.id
                       and p.id(+)             not in (1006)
                       and p.id(+)             = gp.param_id
                       and v.param_group_id(+) = gp.id
                       and v.id_param_value(+) = gp.param_id
                       and v.year(+)           = i_year
                       and ceil(nvl(v.month_num(+), i_quarter*3)/3) = i_quarter
                       and v.inst_id(+)        = gp.inst_id
                       and g.priority is not null
                       and nvl(gp.priority,0) != -1
                       and (gp.param_id not in (1012, 2056, 2058) and v.card_type_feature = net_api_const_pkg.CARD_FEATURE_STATUS_CREDIT
                            or v.card_type_feature = net_api_const_pkg.CARD_FEATURE_STATUS_DEBIT)
                       and (gp.param_id not in (1109, 1113, 1114, 1115) and v.card_type_feature = net_api_const_pkg.CARD_FEATURE_STATUS_DEBIT
                            or v.card_type_feature = net_api_const_pkg.CARD_FEATURE_STATUS_CREDIT)
                    ) v
          group by v.group_id
                 , v.param_id
                 , v.card_type_id
                 , v.card_type_feature
                 , v.group_priority
                 , v.impact
             union all
            -- A. Purchases
            -- 6. Total (1+2+3+4+5)
            select g.id                   as group_id
                 , p.id                   as param_id
                 , v.value_1              as value_1
                 , v.value_2              as value_2
                 , v.value_3              as value_3
                 , null                   as val_1
                 , v.card_type_id         as card_type_id
                 , v.card_type_feature    as card_type_feature
                 , g.priority             as group_priority
                 , null                   as impact
              from (
                    select sum(v.value_1)        as value_1
                         , sum(v.value_2)        as value_2
                         , sum(v.value_3)        as value_3
                         , v.card_type_id        as card_type_id
                         , v.card_type_feature   as card_type_feature
                      from qpr_group g
                         , (select id, param_id, group_id, priority, inst_id
                              from qpr_param_group gp , inst) gp
                         , qpr_param p
                         , qpr_param_value v
                         , qpr_group_report r
                     where r.report_name       = 'PS_MC_ISSUING'
                       and g.id                = r.id
                       and gp.group_id(+)      = g.id
                       and p.id(+)             = gp.param_id
                       and v.param_group_id(+) = gp.id
                       and v.id_param_value(+) = gp.param_id
                       and v.year(+)           = i_year
                       and ceil(nvl(v.month_num(+), i_quarter*3)/3) = i_quarter
                       and v.inst_id(+)        = gp.inst_id
                       and g.priority is not null
                       and nvl(gp.priority,0) != -1
                       and gp.id in (1000, 1001, 1002, 1003, 1004)
                  group by v.card_type_id
                         , v.card_type_feature
                   ) v
                 , qpr_group g
                 , qpr_param p
             where g.id = 101
               and p.id = 1006
             union all
            -- B. Total Cash Advances
            -- 6. Total (1+2+3+4+5)
            select g.id                   as group_id
                 , p.id                   as param_id
                 , v.value_1              as value_1
                 , v.value_2              as value_2
                 , v.value_3              as value_3
                 , null                   as val_1
                 , v.card_type_id         as card_type_id
                 , v.card_type_feature    as card_type_feature
                 , g.priority             as group_priority
                 , null                   as impact
              from (
                    select sum(v.value_1)        as value_1
                         , sum(v.value_2)        as value_2
                         , sum(v.value_3)        as value_3
                         , v.card_type_id        as card_type_id
                         , v.card_type_feature   as card_type_feature
                      from qpr_group g
                         , (select id, param_id, group_id, priority, inst_id
                              from qpr_param_group gp , inst) gp
                         , qpr_param p
                         , qpr_param_value v
                         , qpr_group_report r
                     where r.report_name       = 'PS_MC_ISSUING'
                       and g.id                = r.id
                       and gp.group_id(+)      = g.id
                       and p.id(+)             = gp.param_id
                       and v.param_group_id(+) = gp.id
                       and v.id_param_value(+) = gp.param_id
                       and v.year(+)           = i_year
                       and ceil(nvl(v.month_num(+), i_quarter*3)/3) = i_quarter
                       and v.inst_id(+)        = gp.inst_id
                       and g.priority is not null
                       and nvl(gp.priority,0) != -1
                       and gp.id in (1007, 1008, 1009, 1010, 1011)
                  group by v.card_type_id
                         , v.card_type_feature
                   ) v
                 , qpr_group g
                 , qpr_param p
             where g.id = 102
               and p.id = 1006
             union all
            -- C. Refunds / Returns / Credits
            -- 6. Total (1+2+3+4+5)
            select g.id                   as group_id
                 , p.id                   as param_id
                 , v.value_1              as value_1
                 , v.value_2              as value_2
                 , v.value_3              as value_3
                 , null                   as val_1
                 , v.card_type_id         as card_type_id
                 , v.card_type_feature    as card_type_feature
                 , g.priority             as group_priority
                 , null                   as impact
              from (
                    select sum(v.value_1)        as value_1
                         , sum(v.value_2)        as value_2
                         , sum(v.value_3)        as value_3
                         , v.card_type_id        as card_type_id
                         , v.card_type_feature   as card_type_feature
                      from qpr_group g
                         , (select id, param_id, group_id, priority, inst_id
                              from qpr_param_group gp , inst) gp
                         , qpr_param p
                         , qpr_param_value v
                         , qpr_group_report r
                     where r.report_name       = 'PS_MC_ISSUING'
                       and g.id                = r.id
                       and gp.group_id(+)      = g.id
                       and p.id(+)             = gp.param_id
                       and v.param_group_id(+) = gp.id
                       and v.id_param_value(+) = gp.param_id
                       and v.year(+)           = i_year
                       and ceil(nvl(v.month_num(+), i_quarter*3)/3) = i_quarter
                       and v.inst_id(+)        = gp.inst_id
                       and g.priority is not null
                       and nvl(gp.priority,0) != -1
                       and gp.id in (1028, 1029, 1030, 1031, 1032)
                  group by v.card_type_id
                         , v.card_type_feature
                   ) v
                 , qpr_group g
                 , qpr_param p
             where g.id = 105
               and p.id = 1006
              -- Maestro Cards
             union all
            select g.id                   as group_id
                 , p.id                   as param_id
                 , sum(
                       case when p.id in (1008, 1009, 1011, 2056, 2058)
                            then 0
                            else v.value_1
                       end
                      )                   as value_1
                 , sum(
                       case when p.id in (1008, 1009, 1011, 2056, 2058, 1030, 1031, 1054, 1055)
                            then 0
                            else v.value_2
                       end
                      )                   as value_2
                 , sum(
                       case when p.id in (1030, 1031, 1054, 1055)
                            then 0
                            else v.value_3
                       end
                      )                   as value_3
                 , null                   as val_1
                 , v.card_type_id         as card_type_id
                 , v.card_type_feature    as card_type_feature
                 , g.priority             as group_priority
                 , null                   as impact
              from qpr_group g
                 , (select id, param_id, group_id, priority, inst_id
                      from qpr_param_group gp , inst) gp
                 , qpr_param p
                 , qpr_param_value v
                 , qpr_group_report r
             where r.report_name       = 'PS_MC_MAESTRO'
               and g.id                = r.id
               and gp.group_id(+)      = g.id
               and p.id(+)             not in (1044, 2059)
               and p.id(+)             = gp.param_id
               and v.param_group_id(+) = gp.id
               and v.id_param_value(+) = gp.param_id
               and v.year(+)           = i_year
               and ceil(nvl(v.month_num(+), i_quarter*3)/3) = i_quarter
               and v.inst_id(+)        = gp.inst_id
               and g.priority is not null
               and gp.id(+) not in (1086, 1092)
               and nvl(gp.priority,0) != -1
               and p.id               != 1045
          group by g.id
                 , p.id
                 , g.priority
                 , v.card_type_id
                 , v.card_type_feature
             union all
            -- I. Maestro Purchase (Retail Sales) Activity
            -- 6. Total Maestro Purchase Activity (sum of 1+2+3+4a+4b)
            select g.id                   as group_id
                 , p.id                   as param_id
                 , v.value_1              as value_1
                 , v.value_2              as value_2
                 , v.value_3              as value_3
                 , null                   as val_1
                 , v.card_type_id         as card_type_id
                 , v.card_type_feature    as card_type_feature
                 , g.priority             as group_priority
                 , null                   as impact
              from (
                    select sum(v.value_1)        as value_1
                         , sum(v.value_2)        as value_2
                         , sum(v.value_3)        as value_3
                         , v.card_type_id        as card_type_id
                         , v.card_type_feature   as card_type_feature
                      from qpr_group g
                         , (select id, param_id, group_id, priority, inst_id
                              from qpr_param_group gp , inst) gp
                         , qpr_param p
                         , qpr_param_value v
                         , qpr_group_report r
                     where r.report_name       = 'PS_MC_MAESTRO'
                       and g.id                = r.id
                       and gp.group_id(+)      = g.id
                       and p.id(+)             = gp.param_id
                       and v.param_group_id(+) = gp.id
                       and v.id_param_value(+) = gp.param_id
                       and v.year(+)           = i_year
                       and ceil(nvl(v.month_num(+), i_quarter*3)/3) = i_quarter
                       and v.inst_id(+)        = gp.inst_id
                       and g.priority is not null
                       and nvl(gp.priority,0) != -1
                       and gp.id in (1068, 1069, 1070, 1071, 1072)
                  group by v.card_type_id
                         , v.card_type_feature
                   ) v
                 , qpr_group g
                 , qpr_param p
             where g.id = 116
               and p.id = 1044
             union all
            -- II. Maestro Cash Disbursements (ATM) Activity
            -- 6. Total Maestro Cash Disbursement Activity (sum of 1+2+3+4)
            select g.id                   as group_id
                 , p.id                   as param_id
                 , v.value_1              as value_1
                 , v.value_2              as value_2
                 , v.value_3              as value_3
                 , null                   as val_1
                 , v.card_type_id         as card_type_id
                 , v.card_type_feature    as card_type_feature
                 , g.priority             as group_priority
                 , null                   as impact
              from (
                    select sum(v.value_1)        as value_1
                         , sum(v.value_2)        as value_2
                         , sum(v.value_3)        as value_3
                         , v.card_type_id        as card_type_id
                         , v.card_type_feature   as card_type_feature
                      from qpr_group g
                         , (select id, param_id, group_id, priority, inst_id
                              from qpr_param_group gp , inst) gp
                         , qpr_param p
                         , qpr_param_value v
                         , qpr_group_report r
                     where r.report_name       = 'PS_MC_MAESTRO'
                       and g.id                = r.id
                       and gp.group_id(+)      = g.id
                       and p.id(+)             = gp.param_id
                       and v.param_group_id(+) = gp.id
                       and v.id_param_value(+) = gp.param_id
                       and v.year(+)           = i_year
                       and ceil(nvl(v.month_num(+), i_quarter*3)/3) = i_quarter
                       and v.inst_id(+)        = gp.inst_id
                       and g.priority is not null
                       and nvl(gp.priority,0) != -1
                       and gp.id in (1074, 1075, 1076, 1077, 1078)
                  group by v.card_type_id
                         , v.card_type_feature
                   ) v
                 , qpr_group g
                 , qpr_param p
             where g.id = 117
               and p.id = 2059
             union all
            -- III. Maestro Accounts and Cards
            -- 5. Total (sum of 1+2+3+4)
            select g.id                   as group_id
                 , p.id                   as param_id
                 , v.value_1              as value_1
                 , v.value_2              as value_2
                 , v.value_3              as value_3
                 , null                   as val_1
                 , v.card_type_id         as card_type_id
                 , v.card_type_feature    as card_type_feature
                 , g.priority             as group_priority
                 , null                   as impact
              from (
                    select sum(v.value_1)        as value_1
                         , sum(v.value_2)        as value_2
                         , sum(v.value_3)        as value_3
                         , v.card_type_id        as card_type_id
                         , v.card_type_feature   as card_type_feature
                      from qpr_group g
                         , (select id, param_id, group_id, priority, inst_id
                              from qpr_param_group gp , inst) gp
                         , qpr_param p
                         , qpr_param_value v
                         , qpr_group_report r
                     where r.report_name       = 'PS_MC_MAESTRO'
                       and g.id                = r.id
                       and gp.group_id(+)      = g.id
                       and p.id(+)             = gp.param_id
                       and v.param_group_id(+) = gp.id
                       and v.id_param_value(+) = gp.param_id
                       and v.year(+)           = i_year
                       and ceil(nvl(v.month_num(+), i_quarter*3)/3) = i_quarter
                       and v.inst_id(+)        = gp.inst_id
                       and g.priority is not null
                       and nvl(gp.priority,0) != -1
                       and gp.id in (1080, 1081, 1082, 1083)
                  group by v.card_type_id
                         , v.card_type_feature
                   ) v
                 , qpr_group g
                 , qpr_param p
             where g.id = 119
               and p.id = 1049
             union all
            -- IV. Detail Activity Breakout
            -- 1. Total Domestic Activity (I.1+I.2+I.3+II.1+II.2+II.3)
            select g.id                           as group_id
                 , p.id                           as param_id
                 , v.value_1                      as value_1
                 , v.value_2                      as value_2
                 , v.value_3                      as value_3
                 , null                           as val_1
                 , v.card_type_id                 as card_type_id
                 , v.card_type_feature            as card_type_feature
                 , g.priority                     as group_priority
                 , null                           as impact
              from (
                    select sum(v.value_1)        as value_1
                         , sum(v.value_2)        as value_2
                         , sum(v.value_3)        as value_3
                         , v.card_type_id        as card_type_id
                         , v.card_type_feature   as card_type_feature
                      from qpr_group g
                         , (select id, param_id, group_id, priority, inst_id
                              from qpr_param_group gp , inst) gp
                         , qpr_param p
                         , qpr_param_value v
                         , qpr_group_report r
                     where r.report_name       = 'PS_MC_MAESTRO'
                       and g.id                = r.id
                       and gp.group_id(+)      = g.id
                       and p.id(+)             = gp.param_id
                       and v.param_group_id(+) = gp.id
                       and v.id_param_value(+) = gp.param_id
                       and v.year(+)           = i_year
                       and ceil(nvl(v.month_num(+), i_quarter*3)/3) = i_quarter
                       and v.inst_id(+)        = gp.inst_id
                       and gp.id in (1068, 1069, 1070, 1074, 1075, 1076)
                       and g.priority is not null
                       and nvl(gp.priority,0) != -1
                  group by v.card_type_id
                         , v.card_type_feature
                   ) v
                 , qpr_group g
                 , qpr_param p
             where g.id = 121
               and p.id = 1051
             union all
            -- IV. Detail Activity Breakout
            -- 3. Domestic Activity on Cards Bearing Maestro (or Maestro+Cirrus) Logo Only
            select g.id                           as group_id
                 , p.id                           as param_id
                 , v.value_1                      as value_1
                 , v.value_2                      as value_2
                 , v.value_3                      as value_3
                 , null                           as val_1
                 , v.card_type_id                 as card_type_id
                 , v.card_type_feature            as card_type_feature
                 , g.priority                     as group_priority
                 , null                           as impact
              from (
                    select sum(v.value_1)        as value_1
                         , sum(v.value_2)        as value_2
                         , sum(v.value_3)        as value_3
                         , v.card_type_id        as card_type_id
                         , v.card_type_feature   as card_type_feature
                      from qpr_group g
                         , (select id, param_id, group_id, priority, inst_id
                              from qpr_param_group gp , inst) gp
                         , qpr_param p
                         , qpr_param_value v
                         , qpr_group_report r
                     where r.report_name       = 'PS_MC_MAESTRO'
                       and g.id                = r.id
                       and gp.group_id(+)      = g.id
                       and p.id(+)             = gp.param_id
                       and v.param_group_id(+) = gp.id
                       and v.id_param_value(+) = gp.param_id
                       and v.year(+)           = i_year
                       and ceil(nvl(v.month_num(+), i_quarter*3)/3) = i_quarter
                       and v.inst_id(+)        = gp.inst_id
                       and gp.id in (1068, 1069, 1070, 1074, 1075, 1076)
                       and g.priority is not null
                       and nvl(gp.priority,0) != -1
                  group by v.card_type_id
                         , v.card_type_feature
                   ) v
                 , qpr_group g
                 , qpr_param p
             where g.id = 121
               and p.id = 1053
              -- Acquiring Maestro
             union all
            select g.id                           as group_id
                 , p.id                           as param_id
                 , sum(v.value_1)                 as value_1
                 , sum(v.value_2)                 as value_2
                 , sum(v.value_3)                 as value_3
                 , null                           as val_1
                 , v.card_type_id                 as card_type_id
                 , nvl(v.card_type_feature,'ACQUIRING') as card_type_feature
                 , g.priority                     as group_priority
                 , null                           as impact
              from qpr_group g
                 , (select id, param_id, group_id, priority, inst_id
                      from qpr_param_group gp , inst) gp
                 , qpr_param p
                 , qpr_param_value v
                 , qpr_group_report r
             where r.report_name       = 'PS_MC_ACQ_MAESTRO'
               and g.id                = r.id
               and gp.group_id(+)      = g.id
               and p.id(+)             not in (2060, 2061)
               and p.id(+)             = gp.param_id
               and v.param_group_id(+) = gp.id
               and v.id_param_value(+) = gp.param_id
               and v.year(+)           = i_year
               and ceil(nvl(v.month_num(+), i_quarter*3)/3) = i_quarter
               and v.inst_id(+)        = gp.inst_id
               and gp.id(+)           != 1164
             group by
                   g.id
                 , p.id
                 , v.card_type_id
                 , nvl(v.card_type_feature,'ACQUIRING')
                 , g.priority
             union all
            -- IV. Detail Acquiring Activity Breakout
            -- 1. Total Domestic Activity (I.1+I.2+I.3+II.1+II.2+II.3)
            select g.id                           as group_id
                 , p.id                           as param_id
                 , v.value_1                      as value_1
                 , v.value_2                      as value_2
                 , v.value_3                      as value_3
                 , null                           as val_1
                 , v.card_type_id                 as card_type_id
                 , v.card_type_feature            as card_type_feature
                 , g.priority                     as group_priority
                 , null                           as impact
              from (
                    select sum(v.value_1)        as value_1
                         , sum(v.value_2)        as value_2
                         , sum(v.value_3)        as value_3
                         , v.card_type_id        as card_type_id
                         , nvl(v.card_type_feature,'ACQUIRING') as card_type_feature
                      from qpr_group g
                         , (select id, param_id, group_id, priority, inst_id
                              from qpr_param_group gp , inst) gp
                         , qpr_param p
                         , qpr_param_value v
                         , qpr_group_report r
                     where r.report_name       = 'PS_MC_ACQ_MAESTRO'
                       and g.id                = r.id
                       and gp.group_id(+)      = g.id
                       and p.id(+)             = gp.param_id
                       and v.param_group_id(+) = gp.id
                       and v.id_param_value(+) = gp.param_id
                       and v.year(+)           = i_year
                       and ceil(nvl(v.month_num(+), i_quarter*3)/3) = i_quarter
                       and v.inst_id(+)        = gp.inst_id
                       and gp.id in (1143, 1144, 1145, 1149, 1150, 1151)
                  group by v.card_type_id
                         , nvl(v.card_type_feature,'ACQUIRING')
                   ) v
                 , qpr_group g
                 , qpr_param p
             where g.id = 134
               and p.id = 1092
             union all
            -- IV. Detail Acquiring Activity Breakout
            -- 3. Domestic Activity on Cards Bearing Maestro (or Maestro+Cirrus) Logo Only
            select g.id                           as group_id
                 , p.id                           as param_id
                 , v.value_1                      as value_1
                 , v.value_2                      as value_2
                 , v.value_3                      as value_3
                 , null                           as val_1
                 , v.card_type_id                 as card_type_id
                 , v.card_type_feature            as card_type_feature
                 , g.priority                     as group_priority
                 , null                           as impact
              from (
                    select sum(v.value_1)        as value_1
                         , sum(v.value_2)        as value_2
                         , sum(v.value_3)        as value_3
                         , v.card_type_id        as card_type_id
                         , nvl(v.card_type_feature,'ACQUIRING')   as card_type_feature
                      from qpr_group g
                         , (select id, param_id, group_id, priority, inst_id
                              from qpr_param_group gp , inst) gp
                         , qpr_param p
                         , qpr_param_value v
                         , qpr_group_report r
                     where r.report_name       = 'PS_MC_ACQ_MAESTRO'
                       and g.id                = r.id
                       and gp.group_id(+)      = g.id
                       and p.id(+)             = gp.param_id
                       and v.param_group_id(+) = gp.id
                       and v.id_param_value(+) = gp.param_id
                       and v.year(+)           = i_year
                       and ceil(nvl(v.month_num(+), i_quarter*3)/3) = i_quarter
                       and v.inst_id(+)        = gp.inst_id
                       and gp.id in (1143, 1144, 1145, 1149, 1150, 1151)
                  group by v.card_type_id
                         , nvl(v.card_type_feature,'ACQUIRING')
                   ) v
                 , qpr_group g
                 , qpr_param p
              where g.id = 134
                and p.id = 1094
            union all
            -- I. Maestro Acquiring Purchase (Retail Sales) Activity
            -- 6. Total Maestro Purchase Activity (sum of 1+2+3+4+5)
            select g.id                           as group_id
                 , p.id                           as param_id
                 , sum(v.value_1)                 as value_1
                 , sum(v.value_2)                 as value_2
                 , sum(v.value_3)                 as value_3
                 , null                           as val_1
                 , v.card_type_id                 as card_type_id
                 , nvl(v.card_type_feature,'ACQUIRING')            as card_type_feature
                 , g.priority                     as group_priority
                 , null                           as impact
              from qpr_group g
                 , (select id, param_id, group_id, priority, inst_id
                      from qpr_param_group gp , inst) gp
                 , qpr_param p
                 , qpr_param_value v
                 , qpr_group_report r
             where r.report_name       = 'PS_MC_ACQ_MAESTRO'
               and g.id                = r.id
               and gp.group_id(+)      = g.id
               and v.param_group_id(+) = gp.id
               and v.id_param_value(+) = gp.param_id
               and v.year(+)           = i_year
               and ceil(nvl(v.month_num(+), i_quarter*3)/3) = i_quarter
               and v.inst_id(+)        = gp.inst_id
               and g.id                = 131
               and p.id                = 2060
          group by g.id
                 , p.id
                 , v.card_type_id
                 , nvl(v.card_type_feature,'ACQUIRING')
                 , g.priority
             union all
            -- II. Maestro Acquiring Cash Disbursements (ATM) Activity
            -- 6. Total Maestro Cash Disbursement Activity (sum of 1+2+3+4+5)
            select g.id                           as group_id
                 , p.id                           as param_id
                 , sum(v.value_1)                 as value_1
                 , sum(v.value_2)                 as value_2
                 , sum(v.value_3)                 as value_3
                 , null                           as val_1
                 , v.card_type_id                 as card_type_id
                 , nvl(v.card_type_feature,'ACQUIRING')            as card_type_feature
                 , g.priority                     as group_priority
                 , null                           as impact
              from qpr_group g
                 , (select id, param_id, group_id, priority, inst_id
                      from qpr_param_group gp , inst) gp
                 , qpr_param p
                 , qpr_param_value v
                 , qpr_group_report r
             where r.report_name       = 'PS_MC_ACQ_MAESTRO'
               and g.id                = r.id
               and gp.group_id(+)      = g.id
               and v.param_group_id(+) = gp.id
               and v.id_param_value(+) = gp.param_id
               and v.year(+)           = i_year
               and ceil(nvl(v.month_num(+), i_quarter*3)/3) = i_quarter
               and v.inst_id(+)        = gp.inst_id
               and g.id                = 132
               and p.id                = 2061
          group by g.id
                 , p.id
                 , v.card_type_id
                 , nvl(v.card_type_feature,'ACQUIRING')
                 , g.priority
             -- MasterCard Acquiring
             -- Credit/Debit parameters
             union all
            select g.id                           as group_id
                 , p.id                           as param_id
                 , sum(v.value_1)                 as value_1
                 , sum(v.value_2)                 as value_2
                 , null                           as value_3
                 , null                           as val_1
                 , v.card_type_id                 as card_type_id
                 , nvl(v.card_type_feature,'ACQUIRING')            as card_type_feature
                 , g.priority                     as group_priority
                 , v.value_3                      as impact
              from qpr_group g
                 , (select id, param_id, group_id, priority, inst_id
                      from qpr_param_group gp, inst) gp
                 , qpr_param p
                 , qpr_param_value v
                 , qpr_group_report r
             where r.report_name       = 'PS_MC_ACQUIRING'
               and g.id                = r.id
               and gp.group_id(+)      = g.id
               and p.id(+)            != 1068
               and p.id(+)             = gp.param_id
               and v.param_group_id(+) = gp.id
               and v.id_param_value(+) = gp.param_id
               and v.year(+)           = i_year
               and ceil(nvl(v.month_num(+), i_quarter*3)/3) = i_quarter
               and v.inst_id(+)        = gp.inst_id
               and v.value_3 in (com_api_const_pkg.CREDIT, com_api_const_pkg.DEBIT)
               and gp.group_id in (123, 125, 126, 127)
               and gp.param_id in (1063, 1065, 1066, 1067)
          group by g.id
                 , p.id
                 , v.card_type_id
                 , nvl(v.card_type_feature,'ACQUIRING')
                 , g.priority
                 , v.value_3
             -- MasterCard Acquiring
             -- Acceptance parameters
             union all
            select g.id                           as group_id
                 , p.id                           as param_id
                 , sum(v.value_1)                 as value_1
                 , sum(v.value_2)                 as value_2
                 , sum(v.value_3)                 as value_3
                 , null                           as val_1
                 , v.card_type_id                 as card_type_id
                 , nvl(v.card_type_feature,'ACQUIRING')            as card_type_feature
                 , g.priority                     as group_priority
                 , null                           as impact
              from qpr_group g
                 , (select id, param_id, group_id, priority, inst_id
                      from qpr_param_group gp, inst) gp
                 , qpr_param p
                 , qpr_param_value v
                 , qpr_group_report r
             where r.report_name       = 'PS_MC_ACQUIRING'
               and g.id                = r.id
               and gp.group_id(+)      = g.id
               and p.id(+)            != 1068
               and p.id(+)             = gp.param_id
               and v.param_group_id(+) = gp.id
               and v.id_param_value(+) = gp.param_id
               and v.year(+)           = i_year
               and ceil(nvl(v.month_num(+), i_quarter*3)/3) = i_quarter
               and v.inst_id(+)        = gp.inst_id
               and gp.param_id(+) not in (1063, 1065, 1066, 1067)
          group by g.id
                 , p.id
                 , v.card_type_id
                 , nvl(v.card_type_feature,'ACQUIRING')
                 , g.priority
                 , v.value_3
             union all
            -- for I. Retail Sales (Purchases)
            -- for II. Total Cash Advances
            -- for III. Refunds / Returns / Credits
            -- 6. Total (A1+A2+A3+A4+A5)
            select g.id                           as group_id
                 , p.id                           as param_id
                 , sum(v.value_1)                 as value_1
                 , sum(v.value_2)                 as value_2
                 , sum(v.value_3)                 as value_3
                 , null                           as val_1
                 , v.card_type_id                 as card_type_id
                 , nvl(v.card_type_feature, 'ACQUIRING')            as card_type_feature
                 , g.priority                     as group_priority
                 , null                           as impact
              from qpr_group g
                 , (select id, param_id, group_id, priority, inst_id
                      from qpr_param_group gp , inst) gp
                 , qpr_param_value v
                 , qpr_group_report r
                 , qpr_param p
             where r.report_name       = 'PS_MC_ACQUIRING'
               and g.id                = r.id
               and gp.group_id         = g.id
               and p.id                = 1068
               and gp.param_id        != p.id
               and v.param_group_id(+) = gp.id
               and v.id_param_value(+) = gp.param_id
               and v.year(+)           = i_year
               and ceil(nvl(v.month_num(+), i_quarter*3)/3) = i_quarter
               and v.inst_id(+)        = gp.inst_id
               and g.id in (123, 124, 127)
          group by g.id
                 , p.id
                 , v.card_type_id
                 , nvl(v.card_type_feature, 'ACQUIRING')
                 , g.priority
         ) v
        , qpr_group g
      where g.id = v.group_id
      order by v.card_type_id
             , v.card_type_feature
             , v.group_priority
             , v.param_id nulls first
     );

    --if no data
    if l_detail.getclobval() = '<machine_readable></machine_readable>' then
        select
            xmlelement("machine_readable"
                    , xmlagg(
                        xmlelement("param"
                            , xmlelement("group_id", null)
                            , xmlelement("param_id", null)
                            , xmlelement("card_type_id", null)
                            , xmlelement("card_type_feature", null)
                            , xmlelement("value_1", null)
                            , xmlelement("value_2", null)
                            , xmlelement("value_3", null)
                        )
                    )
                )
        into l_detail from dual ;
    end if;

    select xmlelement (
               "report"
             , l_header
             , l_detail
           ) r
      into l_result
      from dual;

    o_xml := l_result.getclobval();

    trc_log_pkg.debug (
         i_text => 'qpr_api_report_pkg.mc_machine_readable - ok'
    );

exception
    when no_data_found then
        select xmlelement("machine_readable", '')
          into l_detail
          from dual;

        trc_log_pkg.debug (
            i_text  => 'No data found'
        );

end mc_machine_readable;

----------------------------------------------------------
--VISA quarter reports

procedure vs_mrc_inform (
            o_xml              out clob
            , i_lang           in  com_api_type_pkg.t_dict_value
            , i_year           in  com_api_type_pkg.t_tiny_id
            , i_quarter        in  com_api_type_pkg.t_sign
            , i_inst_id        in  com_api_type_pkg.t_inst_id
            )
is
    l_header           xmltype;
    l_detail           xmltype;
    l_result           xmltype;
    l_cmid             com_api_type_pkg.t_cmid;
    l_logo_path        xmltype;

begin

    trc_log_pkg.debug (
            i_text          => 'qpr_api_report_pkg.vs_mrc_inform [#1][#2][#3][#4]'
            , i_env_param1  => i_lang
            , i_env_param2  => i_year
            , i_env_param3  => i_quarter
            , i_env_param4  => i_inst_id
    );

    select max(nvl(v.cmid, '0000'))
      into l_cmid
      from qpr_param_value v
         , (select id as inst_id
              from ost_institution i
        connect by prior id = parent_id
        start with id = i_inst_id
           ) inst
     where v.year     = i_year
       and ceil(nvl(v.month_num, i_quarter*3)/3) = i_quarter
       and v.inst_id  = inst.inst_id;

    -- header
    l_logo_path := rpt_api_template_pkg.logo_path_xml;
    select xmlelement ( "header"
               , l_logo_path
               , xmlelement( "p_year"    , i_year    )
               , xmlelement( "p_quarter" , i_quarter )
           )
    into l_header
    from ( select i_year
                , i_quarter
           from dual
         );

    -- details
    select
           xmlelement("table"
                     , xmlagg(
                            xmlelement( "record"
                                 , xmlelement( "report_name", report_name)
                                 , xmlelement( "group_name", group_name)
                                 , xmlelement( "param_name", param_name)
                                 , xmlelement( "cnt1", cnt1)
                                 , xmlelement( "amount1", amount1)
                                 , xmlelement( "month1", month1)
                                 , xmlelement( "cnt2", cnt2)
                                 , xmlelement( "amount2", amount2)
                                 , xmlelement( "month2", month2)
                                 , xmlelement( "cnt3", cnt3)
                                 , xmlelement( "amount3", amount3)
                                 , xmlelement( "month3", month3)
                            )
                        )
           )
    into
           l_detail
    from (
            with inst as
                 (select id as inst_id
                    from ost_institution i
                    connect by prior id = parent_id
                    start with id = i_inst_id
                 )
            select qgr.report_name
                 , qg.group_name
                 , qp.param_name
                 , sum(nvl(qpv1.value_1, 0)) as cnt1
                 , trim(to_char(sum(nvl(qpv1.value_2,0)), 'FM999999999999990')) as amount1
                 , to_date(to_char(nvl(qpv1.year, i_year))||lpad(to_char(nvl(qpv1.month_num, i_quarter * 3 - 2)),2,'0'),'yyyymm') month1
                 , sum(nvl(qpv2.value_1, 0)) as cnt2
                 , trim(to_char(sum(nvl(qpv2.value_2,0)), 'FM999999999999990')) as amount2
                 , to_date(to_char(nvl(qpv2.year, i_year))||lpad(to_char(nvl(qpv2.month_num, i_quarter * 3 - 1)),2,'0'),'yyyymm') month2
                 , sum(nvl(qpv3.value_1, 0)) as cnt3
                 , trim(to_char(sum(nvl(qpv3.value_2,0)), 'FM999999999999990')) as amount3
                 , to_date(to_char(nvl(qpv3.year, i_year))||lpad(to_char(nvl(qpv3.month_num, i_quarter * 3)),2,'0'),'yyyymm') month3
                 , qg.priority
                 , qp.id param_id
              from qpr_group_report qgr
                 , qpr_group qg
                 , (select id, param_id, group_id, priority, inst_id
                      from qpr_param_group gp , inst) qpg
                 , qpr_param qp
                 , qpr_param_value qpv1
                 , qpr_param_value qpv2
                 , qpr_param_value qpv3
             where qgr.report_name        = 'PS_VISA_MRC_ACQUIRING'
               and qg.id                  = qgr.id
               and qpg.group_id           = qg.id
               and qpg.param_id           = qp.id
               and qpv1.param_group_id(+) = qpg.id
               and qpv1.id_param_value(+) = qpg.param_id
               and qpv1.year(+)           = i_year
               and qpv1.month_num(+)      = i_quarter * 3 - 2
               and qpv1.inst_id(+)        = qpg.inst_id
               and qpv1.cmid(+)           = l_cmid
               and qpv2.param_group_id(+) = qpg.id
               and qpv2.id_param_value(+) = qpg.param_id
               and qpv2.year(+)           = i_year
               and qpv2.month_num(+)      = i_quarter * 3 - 1
               and qpv2.inst_id(+)        = qpg.inst_id
               and qpv2.cmid(+)           = l_cmid
               and qpv3.param_group_id(+) = qpg.id
               and qpv3.id_param_value(+) = qpg.param_id
               and qpv3.year(+)           = i_year
               and qpv3.month_num(+)      = i_quarter * 3
               and qpv3.inst_id(+)        = qpg.inst_id
               and qpv3.cmid(+)           = l_cmid
               and nvl(qpg.priority,0)   != -1
             group by qgr.report_name
                    , qg.group_name
                    , qp.param_name
                    , to_date(to_char(nvl(qpv1.year, i_year))||lpad(to_char(nvl(qpv1.month_num, i_quarter * 3 - 2)),2,'0'),'yyyymm')
                    , to_date(to_char(nvl(qpv2.year, i_year))||lpad(to_char(nvl(qpv2.month_num, i_quarter * 3 - 1)),2,'0'),'yyyymm')
                    , to_date(to_char(nvl(qpv3.year, i_year))||lpad(to_char(nvl(qpv3.month_num, i_quarter * 3)),2,'0'),'yyyymm')
                    , qg.priority
                    , qp.id
             order by qgr.report_name
                    , qg.priority
                    , qp.id
           );

    --if no data
    if l_detail.getclobval() = '<table></table>' then
        select xmlelement("table"
                       , xmlagg(
                            xmlelement("record"
                                 , xmlelement( "report_name", null)
                                 , xmlelement( "group_name", null)
                                 , xmlelement( "param_name", null)
                                 , xmlelement( "cnt1", null)
                                 , xmlelement( "amount1", null)
                                 , xmlelement( "month1", null)
                                 , xmlelement( "cnt2", null)
                                 , xmlelement( "amount2", null)
                                 , xmlelement( "month2", null)
                                 , xmlelement( "cnt3", null)
                                 , xmlelement( "amount3", null)
                                 , xmlelement( "month3", null)
                            )
                         )
              )
        into l_detail from dual ;
    end if;

    select xmlelement ( "report"
             , l_header
             , l_detail
           )
    into l_result from dual;

    o_xml := l_result.getclobval();

    trc_log_pkg.debug ( i_text => 'qpr_api_report_pkg.vs_mrc_inform - ok' );

exception when others then
    trc_log_pkg.debug ( i_text => sqlerrm );
    raise ;
END vs_mrc_inform;

procedure vs_mrc_mcc (
            o_xml              out clob
            , i_lang           in  com_api_type_pkg.t_dict_value
            , i_year           in  com_api_type_pkg.t_tiny_id
            , i_quarter        in  com_api_type_pkg.t_sign
            , i_inst_id        in  com_api_type_pkg.t_inst_id
            )
is
    l_header           xmltype;
    l_detail           xmltype;
    l_result           xmltype;
    l_curr_name        com_api_type_pkg.t_curr_name;
    l_logo_path        xmltype;

begin

    trc_log_pkg.debug (
            i_text          => 'qpr_api_report_pkg.vs_mrc_mcc [#1][#2][#3][#4]'
            , i_env_param1  => i_lang
            , i_env_param2  => i_year
            , i_env_param3  => i_quarter
            , i_env_param4  => i_inst_id
    );

    select max(c.name)
      into l_curr_name
      from qpr_param_value qpv, com_currency c
         , (select id as inst_id
              from ost_institution i
              connect by prior id = parent_id
              start with id = i_inst_id
           ) inst
     where qpv.inst_id   = inst.inst_id
       and qpv.year      = i_year
       and ceil(nvl(qpv.month_num, i_quarter * 3)/ 3) = i_quarter
       and qpv.curr_code = c.code(+);

    -- header
    l_logo_path := rpt_api_template_pkg.logo_path_xml;
    select xmlelement ( "header"
               , l_logo_path
               , xmlelement( "p_year"    , i_year    )
               , xmlelement( "p_quarter" , i_quarter )
               , xmlelement( "curr_name" , l_curr_name)
           )
    into l_header
    from ( select i_year
                , i_quarter
           from dual
         );

    -- details
    select
           xmlelement("table"
                     , xmlagg(
                            xmlelement( "record"
                                 , xmlelement( "report_name", report_name)
                                 , xmlelement( "group_name", group_name)
                                 , xmlelement( "param_name", param_name)
                                 , xmlelement( "cnt", cnt)
                                 , xmlelement( "amount", amount)
                            )
                        )
           )
    into
           l_detail
    from (
            with inst as
                 (select id as inst_id
                    from ost_institution i
                    connect by prior id = parent_id
                    start with id = i_inst_id
                 )
            select qgr.report_name
                 , qg.group_name
                 , qp.param_name
                 , sum(nvl(qpv.value_1, 0)) as cnt
                 , trim(to_char(sum(nvl(qpv.value_2,0)), 'FM999999999999990')) as amount
                 , qg.priority
                 , qp.id as param_id
              from qpr_group_report qgr
                 , qpr_group qg
                 , (select id, param_id, group_id, priority, inst_id
                      from qpr_param_group gp , inst) qpg
                 , qpr_param qp
                 , qpr_param_value qpv
             where qgr.report_name       = 'PS_RU_VISA_MRC_MCC'
               and qg.id                 = qgr.id
               and qpg.group_id(+)       = qg.id
               and qp.id(+)              = qpg.param_id
               and qpv.param_group_id(+) = qpg.id
               and qpv.id_param_value(+) = qpg.param_id
               and qpv.year(+)           = i_year
               and ceil(nvl(qpv.month_num(+), i_quarter * 3)/ 3) = i_quarter
               and qpv.inst_id(+)        = qpg.inst_id
               and nvl(qpg.priority,0)  != -1
             group by qgr.report_name
                    , qg.group_name
                    , qp.param_name
                    , qg.priority
                    , qp.id
             order by qgr.report_name
                    , qg.priority
                    , qp.id
           );

    --if no data
    if l_detail.getclobval() = '<table></table>' then
        select xmlelement("table"
                       , xmlagg(
                            xmlelement("record"
                                 , xmlelement( "report_name", null)
                                 , xmlelement( "group_name", null)
                                 , xmlelement( "param_name", null)
                                 , xmlelement( "cnt", null)
                                 , xmlelement( "amount", null)
                                 , xmlelement( "curr_name", null)
                            )
                         )
              )
        into l_detail from dual ;
    end if;

    select xmlelement ( "report"
             , l_header
             , l_detail
           )
    into l_result from dual;

    o_xml := l_result.getclobval();

    trc_log_pkg.debug ( i_text => 'qpr_api_report_pkg.vs_mrc_mcc - ok' );

exception when others then
    trc_log_pkg.debug ( i_text => sqlerrm );
    raise ;
end vs_mrc_mcc;

procedure vs_cash_acquiring (
            o_xml              out clob
            , i_lang           in  com_api_type_pkg.t_dict_value
            , i_year           in  com_api_type_pkg.t_tiny_id
            , i_quarter        in  com_api_type_pkg.t_sign
            , i_inst_id        in  com_api_type_pkg.t_inst_id
            )
is
    l_header           xmltype;
    l_detail           xmltype;
    l_result           xmltype;
    l_logo_path        xmltype;

begin

    trc_log_pkg.debug (
            i_text          => 'qpr_api_report_pkg.vs_cash_acquiring [#1][#2][#3][#4]'
            , i_env_param1  => i_lang
            , i_env_param2  => i_year
            , i_env_param3  => i_quarter
            , i_env_param4  => i_inst_id
    );

    -- header
    l_logo_path := rpt_api_template_pkg.logo_path_xml;
    select xmlelement ( "header"
               , l_logo_path
               , xmlelement( "p_year"    , i_year    )
               , xmlelement( "p_quarter" , i_quarter )
           )
    into l_header
    from ( select i_year
                , i_quarter
           from dual
         );

    -- details
    select
           xmlelement("table"
                     , xmlagg(
                            xmlelement( "record"
                                 , xmlelement( "report_name", report_name)
                                 , xmlelement( "group_name", group_name)
                                 , xmlelement( "param_name", param_name)
                                 , xmlelement( "param_desc", param_desc)
                                 , xmlelement( "cnt1", cnt1)
                                 , xmlelement( "amount1", amount1)
                                 , xmlelement( "month1", month1)
                                 , xmlelement( "cnt2", cnt2)
                                 , xmlelement( "amount2", amount2)
                                 , xmlelement( "month2", month2)
                                 , xmlelement( "cnt3", cnt3)
                                 , xmlelement( "amount3", amount3)
                                 , xmlelement( "month3", month3)
                            )
                        )
           )
    into
           l_detail
    from (
            with inst as
                 (select id as inst_id
                    from ost_institution i
                    connect by prior id = parent_id
                    start with id = i_inst_id
                 )
            select qgr.report_name
                 , qg.group_name
                 , qp.param_name
                 , qp.param_desc
                 , sum(nvl(qpv1.value_1, 0)) as cnt1
                 , trim(to_char(sum(nvl(qpv1.value_2,0)), 'FM999999999999990')) as amount1
                 , to_date(to_char(nvl(qpv1.year, i_year))||lpad(to_char(nvl(qpv1.month_num, i_quarter * 3 - 2)),2,'0'),'yyyymm') month1
                 , sum(nvl(qpv2.value_1, 0)) as cnt2
                 , trim(to_char(sum(nvl(qpv2.value_2,0)), 'FM999999999999990')) as amount2
                 , to_date(to_char(nvl(qpv2.year, i_year))||lpad(to_char(nvl(qpv2.month_num, i_quarter * 3 - 1)),2,'0'),'yyyymm') month2
                 , sum(nvl(qpv3.value_1, 0)) as cnt3
                 , trim(to_char(sum(nvl(qpv3.value_2,0)), 'FM999999999999990')) as amount3
                 , to_date(to_char(nvl(qpv3.year, i_year))||lpad(to_char(nvl(qpv3.month_num, i_quarter * 3)),2,'0'),'yyyymm') month3
                 , qg.priority
                 , qp.id param_id
              from qpr_group_report qgr
                 , qpr_group qg
                 , (select id, param_id, group_id, priority, inst_id
                      from qpr_param_group gp , inst) qpg
                 , qpr_param qp
                 , qpr_param_value qpv1
                 , qpr_param_value qpv2
                 , qpr_param_value qpv3
             where qgr.report_name        = 'PS_VISA_CASH_ACQUIRING'
               and qg.id                  = qgr.id
               and qpg.group_id           = qg.id
               and qp.id(+)               = qpg.param_id
               and qpv1.param_group_id(+) = qpg.id
               and qpv1.id_param_value(+) = qpg.param_id
               and qpv1.year(+)           = i_year
               and qpv1.month_num(+)      = i_quarter * 3 - 2
               and qpv1.inst_id(+)        = qpg.inst_id
               and qpv2.param_group_id(+) = qpg.id
               and qpv2.id_param_value(+) = qpg.param_id
               and qpv2.year(+)           = i_year
               and qpv2.month_num(+)      = i_quarter * 3 - 1
               and qpv2.inst_id(+)        = qpg.inst_id
               and qpv3.param_group_id(+) = qpg.id
               and qpv3.id_param_value(+) = qpg.param_id
               and qpv3.year(+)           = i_year
               and qpv3.month_num(+)      = i_quarter * 3
               and qpv3.inst_id(+)        = qpg.inst_id
               and nvl(qpg.priority,0)   != -1
             group by qgr.report_name
                    , qg.group_name
                    , qp.param_name
                    , qp.param_desc
                    , to_date(to_char(nvl(qpv1.year, i_year))||lpad(to_char(nvl(qpv1.month_num, i_quarter * 3 - 2)),2,'0'),'yyyymm')
                    , to_date(to_char(nvl(qpv2.year, i_year))||lpad(to_char(nvl(qpv2.month_num, i_quarter * 3 - 1)),2,'0'),'yyyymm')
                    , to_date(to_char(nvl(qpv3.year, i_year))||lpad(to_char(nvl(qpv3.month_num, i_quarter * 3)),2,'0'),'yyyymm')
                    , qg.priority
                    , qp.id
             order by qgr.report_name
                    , qg.priority
                    , qp.id
           );

    --if no data
    if l_detail.getclobval() = '<table></table>' then
        select xmlelement("table"
                       , xmlagg(
                            xmlelement("record"
                                 , xmlelement( "report_name", null)
                                 , xmlelement( "group_name", null)
                                 , xmlelement( "param_name", null)
                                 , xmlelement( "param_desc", null)
                                 , xmlelement( "cnt1", null)
                                 , xmlelement( "amount1", null)
                                 , xmlelement( "month1", null)
                                 , xmlelement( "cnt2", null)
                                 , xmlelement( "amount2", null)
                                 , xmlelement( "month2", null)
                                 , xmlelement( "cnt3", null)
                                 , xmlelement( "amount3", null)
                                 , xmlelement( "month3", null)
                            )
                         )
              )
        into l_detail from dual ;
    end if;

    select xmlelement ( "report"
             , l_header
             , l_detail
           )
    into l_result from dual;

    o_xml := l_result.getclobval();

    trc_log_pkg.debug ( i_text => 'qpr_api_report_pkg.vs_cash_acquiring - ok' );

exception when others then
    trc_log_pkg.debug ( i_text => sqlerrm );
    raise ;
end vs_cash_acquiring;

procedure vs_co_brand (
            o_xml              out clob
            , i_lang           in  com_api_type_pkg.t_dict_value
            , i_year           in  com_api_type_pkg.t_tiny_id
            , i_quarter        in  com_api_type_pkg.t_sign
            , i_inst_id        in  com_api_type_pkg.t_inst_id
            )
is
    l_header           xmltype;
    l_detail           xmltype;
    l_result           xmltype;
    l_logo_path        xmltype;

begin

    trc_log_pkg.debug (
            i_text          => 'qpr_api_report_pkg.vs_co_brand [#1][#2][#3][#4]'
            , i_env_param1  => i_lang
            , i_env_param2  => i_year
            , i_env_param3  => i_quarter
            , i_env_param4  => i_inst_id
    );

    -- header
    l_logo_path    := rpt_api_template_pkg.logo_path_xml;
    select xmlelement ( "header"
               , l_logo_path
               , xmlelement( "p_year"    , i_year    )
               , xmlelement( "p_quarter" , i_quarter )
           )
    into l_header
    from ( select i_year
                , i_quarter
           from dual
         );

    -- details
    select
           xmlelement("table"
                     , xmlagg(
                            xmlelement( "record"
                                 , xmlelement( "report_name", report_name)
                                 , xmlelement( "group_name", group_name)
                                 , xmlelement( "param_name", param_name)
                                 , xmlelement( "partner_name", partner_name)
                                 , xmlelement( "card_type", card_type)
                                 , xmlelement( "bin", bin)
                                 , xmlelement( "cards_count", cards_count)
                                 , xmlelement( "cnt", cnt)
                                 , xmlelement( "amount", amount)
                            )
                        )
           )
    into
           l_detail
    from (
            with inst as
                 (select id as inst_id
                    from ost_institution i
                    connect by prior id = parent_id
                    start with id = i_inst_id
                 )
            select qgr.report_name
                 , qg.group_name
                 , qp.param_name
                 , qpv.card_type            as partner_name
                 , com_api_i18n_pkg.get_text(
                        i_table_name  => 'net_card_type'
                      , i_column_name => 'name'
                      , i_object_id   => b.card_type_id
                    )                       as card_type
                 , b.bin
                 , sum(nvl(qpv.value_1,0))  as cards_count
                 , sum(nvl(qpv.value_2,0))  as cnt
                 , trim(to_char(sum(nvl(qpv.value_3,0)), 'FM999999999999990')) as amount
                 , qg.priority
                 , qp.id                    as param_id
              from qpr_group_report qgr
                 , qpr_group qg
                 , (select id, param_id, group_id, priority, inst_id
                      from qpr_param_group gp , inst) qpg
                 , qpr_param qp
                 , qpr_param_value qpv
                 , iss_bin b
             where qgr.report_name       = 'PS_VISA_CO_BRAND'
               and qg.id                 = qgr.id
               and qpg.group_id(+)       = qg.id
               and qp.id(+)              = qpg.param_id
               and qpv.param_group_id(+) = qpg.id
               and qpv.id_param_value(+) = qpg.param_id
               and qpv.year(+)           = i_year
               and ceil(nvl(qpv.month_num(+), i_quarter * 3)/ 3) = i_quarter
               and qpv.inst_id(+)        = qpg.inst_id
               and b.bin                 = qpv.bin
               and nvl(qpg.priority,0) != -1
             group by qgr.report_name
                    , qg.group_name
                    , qp.param_name
                    , qpv.card_type
                    , com_api_i18n_pkg.get_text(
                           i_table_name  => 'net_card_type'
                         , i_column_name => 'name'
                         , i_object_id   => b.card_type_id
                       )
                    , b.bin
                    , qg.priority
                    , qp.id
             order by qgr.report_name
                    , qg.priority
                    , qp.id
                    , qpv.card_type
                    , b.bin
           );

    --if no data
    if l_detail.getclobval() = '<table></table>' then
        select xmlelement("table"
                       , xmlagg(
                            xmlelement("record"
                                 , xmlelement( "report_name", null)
                                 , xmlelement( "group_name", null)
                                 , xmlelement( "param_name", null)
                                 , xmlelement( "partner_name", null)
                                 , xmlelement( "card_type", null)
                                 , xmlelement( "bin", null)
                                 , xmlelement( "cards_count", null)
                                 , xmlelement( "cnt", null)
                                 , xmlelement( "amount", null)
                            )
                         )
              )
        into l_detail from dual ;
    end if;

    select xmlelement ( "report"
             , l_header
             , l_detail
           )
    into l_result from dual;

    o_xml := l_result.getclobval();

    trc_log_pkg.debug ( i_text => 'qpr_api_report_pkg.vs_co_brand - ok' );

exception when others then
    trc_log_pkg.debug ( i_text => sqlerrm );
    raise ;
END vs_co_brand;

procedure vs_issuing (
            o_xml              out clob
            , i_lang           in  com_api_type_pkg.t_dict_value
            , i_year           in  com_api_type_pkg.t_tiny_id
            , i_quarter        in  com_api_type_pkg.t_sign
            , i_card_type_id   in  com_api_type_pkg.t_tiny_id
            , i_inst_id        in  com_api_type_pkg.t_inst_id
            )
is
    l_header           xmltype;
    l_detail           xmltype;
    l_result           xmltype;
    l_card_type        com_api_type_pkg.t_name;
    l_lang             com_api_type_pkg.t_dict_value;
    l_logo_path        xmltype;
begin

    trc_log_pkg.debug (
            i_text          => 'qpr_api_report_pkg.vs_issuing [#1][#2][#3][#4][#5]'
            , i_env_param1  => i_lang
            , i_env_param2  => i_year
            , i_env_param3  => i_quarter
            , i_env_param4  => i_card_type_id
            , i_env_param5  => i_inst_id
    );

    l_lang := nvl( i_lang, get_user_lang );
    l_card_type := com_api_i18n_pkg.get_text('NET_CARD_TYPE','NAME', i_card_type_id, l_lang);
    -- header
    l_logo_path := rpt_api_template_pkg.logo_path_xml;
    select xmlelement ( "header"
               , l_logo_path
               , xmlelement("card_type_id", i_card_type_id)
               , xmlelement("card_type", l_card_type)
               , xmlelement( "p_year", i_year)
               , xmlelement( "p_quarter", i_quarter)
           )
      into l_header
      from dual;

    -- details
    select
           xmlelement("table"
                     , xmlagg(
                            xmlelement( "record"
                                 , xmlelement( "report_name", report_name)
                                 , xmlelement( "group_name", group_name)
                                 , xmlelement( "param_name", param_name)
                                 , xmlelement( "cnt1", cnt1)
                                 , xmlelement( "amount1", amount1)
                                 , xmlelement( "month1", month1)
                                 , xmlelement( "cnt2", cnt2)
                                 , xmlelement( "amount2", amount2)
                                 , xmlelement( "month2", month2)
                                 , xmlelement( "cnt3", cnt3)
                                 , xmlelement( "amount3", amount3)
                                 , xmlelement( "month3", month3)
                            )
                        )
           )
    into
           l_detail
    from (
            with inst as
                 (select id as inst_id
                    from ost_institution i
                    connect by prior id = parent_id
                    start with id = i_inst_id
                 )
            select qgr.report_name
                 , qg.group_name
                 , qp.param_name
                 , sum(nvl(qpv1.value_1, 0)) as cnt1
                 , trim(to_char(sum(nvl(qpv1.value_2,0)), 'FM999999999999990')) as amount1
                 , to_date(to_char(nvl(qpv1.year, i_year))||lpad(to_char(nvl(qpv1.month_num, i_quarter * 3 - 2)),2,'0'),'yyyymm') month1
                 , sum(nvl(qpv2.value_1, 0)) as cnt2
                 , trim(to_char(sum(nvl(qpv2.value_2,0)), 'FM999999999999990')) as amount2
                 , to_date(to_char(nvl(qpv2.year, i_year))||lpad(to_char(nvl(qpv2.month_num, i_quarter * 3 - 1)),2,'0'),'yyyymm') month2
                 , sum(nvl(qpv3.value_1, 0)) as cnt3
                 , trim(to_char(sum(nvl(qpv3.value_2,0)), 'FM999999999999990')) as amount3
                 , to_date(to_char(nvl(qpv3.year, i_year))||lpad(to_char(nvl(qpv3.month_num, i_quarter * 3)),2,'0'),'yyyymm') month3
                 , qg.priority
                 , qp.id param_id
              from qpr_group_report qgr
                 , qpr_group qg
                 , (select id, param_id, group_id, priority, inst_id
                      from qpr_param_group gp , inst) qpg
                 , qpr_param qp
                 , qpr_param_value qpv1
                 , qpr_param_value qpv2
                 , qpr_param_value qpv3
             where qgr.report_name          = 'PS_VISA_ISSUING'
               and qg.id                    = qgr.id
               and qpg.group_id             = qg.id
               and qp.id(+)                 = qpg.param_id
               and qpv1.param_group_id(+)   = qpg.id
               and qpv1.id_param_value(+)   = qpg.param_id
               and qpv1.year(+)             = i_year
               and qpv1.month_num(+)        = i_quarter * 3 - 2
               and upper(qpv1.card_type(+)) = upper(l_card_type)
               and qpv1.inst_id(+)          = qpg.inst_id
               and qpv2.param_group_id(+)   = qpg.id
               and qpv2.id_param_value(+)   = qpg.param_id
               and qpv2.year(+)             = i_year
               and qpv2.month_num(+)        = i_quarter * 3 - 1
               and upper(qpv2.card_type(+)) = upper(l_card_type)
               and qpv2.inst_id(+)          = qpg.inst_id
               and qpv3.param_group_id(+)   = qpg.id
               and qpv3.id_param_value(+)   = qpg.param_id
               and qpv3.year(+)             = i_year
               and qpv3.month_num(+)        = i_quarter * 3
               and upper(qpv3.card_type(+)) = upper(l_card_type)
               and qpv3.inst_id(+)          = qpg.inst_id
               and nvl(qpg.priority,0)     != -1
             group by qgr.report_name
                    , qg.group_name
                    , qp.param_name
                    , to_date(to_char(nvl(qpv1.year, i_year))||lpad(to_char(nvl(qpv1.month_num, i_quarter * 3 - 2)),2,'0'),'yyyymm')
                    , to_date(to_char(nvl(qpv2.year, i_year))||lpad(to_char(nvl(qpv2.month_num, i_quarter * 3 - 1)),2,'0'),'yyyymm')
                    , to_date(to_char(nvl(qpv3.year, i_year))||lpad(to_char(nvl(qpv3.month_num, i_quarter * 3)),2,'0'),'yyyymm')
                    , qg.priority
                    , qp.id
             order by qgr.report_name
                    , qg.priority
                    , qp.id
           );

    --if no data
    if l_detail.getclobval() = '<table></table>' then
        select xmlelement("table"
                       , xmlagg(
                            xmlelement("record"
                                 , xmlelement( "report_name", null)
                                 , xmlelement( "group_name", null)
                                 , xmlelement( "param_name", null)
                                 , xmlelement( "cnt1", null)
                                 , xmlelement( "amount1", null)
                                 , xmlelement( "month1", null)
                                 , xmlelement( "cnt2", null)
                                 , xmlelement( "amount2", null)
                                 , xmlelement( "month2", null)
                                 , xmlelement( "cnt3", null)
                                 , xmlelement( "amount3", null)
                                 , xmlelement( "month3", null)
                            )
                         )
              )
        into l_detail from dual ;
    end if;

    select xmlelement ( "report"
             , l_header
             , l_detail
           )
    into l_result from dual;

    o_xml := l_result.getclobval();

    trc_log_pkg.debug ( i_text => 'qpr_api_report_pkg.vs_issuing - ok' );

exception when others then
    trc_log_pkg.debug ( i_text => sqlerrm );
    raise ;
END vs_issuing;

procedure vs_acquiring_v_pay (
            o_xml              out clob
            , i_lang           in  com_api_type_pkg.t_dict_value
            , i_year           in  com_api_type_pkg.t_tiny_id
            , i_quarter        in  com_api_type_pkg.t_sign
            , i_inst_id        in  com_api_type_pkg.t_inst_id
            )
is
    l_header           xmltype;
    l_detail           xmltype;
    l_result           xmltype;
    l_lang             com_api_type_pkg.t_dict_value;
    l_cmid             com_api_type_pkg.t_cmid;
begin

    trc_log_pkg.debug (
            i_text          => 'qpr_api_report_pkg.vs_acquiring_v_pay [#1][#2][#3][#4]'
            , i_env_param1  => i_lang
            , i_env_param2  => i_year
            , i_env_param3  => i_quarter
            , i_env_param4  => i_inst_id
    );

    l_lang := nvl( i_lang, get_user_lang );

    select max(nvl(v.cmid, '0000'))
      into l_cmid
      from qpr_param_value v
         , (select id as inst_id
              from ost_institution i
              connect by prior id = parent_id
              start with id = i_inst_id
           ) inst
     where v.year     = i_year
       and ceil(nvl(v.month_num, i_quarter*3)/3) = i_quarter
       and v.inst_id  = inst.inst_id;

    -- header
    select
        xmlconcat(
            xmlelement("year", i_year)
            , xmlelement("quarter", i_quarter)
        )
    into
        l_header
    from dual;

    -- details
    select
        xmlelement("acquiring"
            , xmlagg(
                xmlelement("param"
                    , xmlelement("group_id", group_id)
                    , xmlelement("group_desc", group_desc)
                    , xmlelement("param_id", param_id)
                    , xmlelement("param_desc", param_desc)
                    , xmlelement("year", i_year)
                    , xmlelement("month", to_char(dt, 'MONTH yyyy'))
                    -- always without precision
                    , xmlelement("value_1", trim(to_char(nvl(value_1, 0), 'FM999999999999990')))
                    -- without precision
                    , xmlelement("value_2", trim(to_char(nvl(round(value_2), 0), 'FM999999999999990')))
                )
            )
        )
    into
           l_detail
    from (
        select v.*
             , case when v.month is not null then to_date('01' || lpad(v.month, 2, '0') || v.year, 'ddmmyyyy') end dt
          from (
            with inst as
                 (select id as inst_id
                    from ost_institution i
                    connect by prior id = parent_id
                    start with id = i_inst_id
                 )
            , mn as
                 (select i_quarter * 3 - level + 1 month_num
                    from dual
                 connect by level < 4
                 )

            -- 232 V PAY Acquirer Data
            select g.id           as group_id
                 , g.group_desc
                 , p.id           as param_id
                 , p.param_desc
                 , i_year         as year
                 , gp.month_num   as month
                 , sum(v.value_1) as value_1
                 , sum(v.value_2) as value_2
              from qpr_group_report r
                 , qpr_group g
                 , (select id, param_id, group_id, priority, inst_id, month_num from qpr_param_group gp, inst, mn) gp
                 , qpr_param p
                 , qpr_param_value v
             where r.report_name       = 'PS_V_PAY_ACQUIRING'
               and g.id                = r.id
               and gp.group_id         = g.id
               and p.id               != 2155
               and p.id(+)             = gp.param_id
               and v.param_group_id(+) = gp.id
               and v.id_param_value(+) = gp.param_id
               and v.year(+)           = i_year
               and v.month_num(+) = gp.month_num
               and v.inst_id(+)        = gp.inst_id
               and nvl(gp.priority,0) != -1
               and v.cmid(+)           = l_cmid
               and g.id = 232
           group by
               g.id
               , g.group_desc
               , p.id
               , p.param_desc
               , gp.month_num

            union all

            -- Net totals for V PAY Acquirer Data
            select g.id           as group_id
                 , g.group_desc
                 , p.id           as param_id
                 , p.param_desc   as param_desc
                 , i_year         as year
                 , gp.month_num   as month
                 , sum(v.value_1) as value_1
                 , sum(v.value_2) as value_2
              from qpr_group g
                 , (select id, param_id, group_id, priority, inst_id, month_num
                      from qpr_param_group gp, inst, mn) gp
                 , qpr_param_value v
                 , qpr_group_report r
                 , qpr_param p
             where r.report_name       = 'PS_V_PAY_ACQUIRING'
               and g.id                = r.id
               and gp.group_id         = g.id
               and p.id                = 2155
               and gp.param_id        != p.id
               and v.param_group_id(+) = gp.id
               and v.id_param_value(+) = gp.param_id
               and v.year(+)           = i_year
               and v.month_num(+)      = gp.month_num
               and v.inst_id(+)        = gp.inst_id
               and v.cmid(+)           = l_cmid
               and g.id in (232)
          group by g.id
                 , g.group_desc
                 , p.id
                 , p.param_desc
                 , gp.month_num

            union all

            -- 224 V PAY Acquired Electronic Commerce Transaction Data
            -- 225 Member And Merchant Data
            select g.id            as group_id
                 , g.group_desc
                 , p.id            as param_id
                 , p.param_desc
                 , i_year          as year
                 , to_number(null) as month
                 , sum(v.value_1)  as value_1
                 , sum(v.value_2)  as value_2
              from qpr_group_report r
                 , qpr_group g
                 , (select id, param_id, group_id, priority, inst_id from qpr_param_group gp, inst) gp
                 , qpr_param p
                 , qpr_param_value v
             where r.report_name       = 'PS_V_PAY_ACQUIRING'
               and g.id                = r.id
               and gp.group_id         = g.id
               and p.id(+)             = gp.param_id
               and v.param_group_id(+) = gp.id
               and v.id_param_value(+) = gp.param_id
               and v.year(+)           = i_year
               and ceil(nvl(v.month_num(+), i_quarter*3)/3) = i_quarter
               and v.inst_id(+)        = gp.inst_id
               and nvl(gp.priority,0)  != -1
               and v.cmid(+)           = l_cmid
               and g.id in (224, 225)
           group by
               g.id
               , g.group_desc
               , p.id
               , p.param_desc
         ) v
         , qpr_group g
      where g.id = v.group_id
      order by g.priority
             , v.month
             , v.param_id nulls first
    );

    --if no data
    if l_detail.getclobval() = '<acquiring></acquiring>' then
        select
            xmlelement("acquiring"
                    , xmlagg(
                        xmlelement("param"
                            , xmlelement("group_id", null)
                            , xmlelement("group_desc", null)
                            , xmlelement("param_id", null)
                            , xmlelement("param_desc", null)
                            , xmlelement("year", null)
                            , xmlelement("month", null)
                            , xmlelement("value_1", null)
                            , xmlelement("value_2", null)
                        )
                    )
                )
        into l_detail from dual ;
    end if;

    select xmlelement ( "report"
             , l_header
             , l_detail
           )
    into l_result from dual;

    o_xml := l_result.getclobval();

    trc_log_pkg.debug ( i_text => 'qpr_api_report_pkg.vs_acquiring_v_pay - ok' );

exception when others then
    trc_log_pkg.debug ( i_text => sqlerrm );
    raise ;
END vs_acquiring_v_pay;

procedure vs_acquiring_contactless (
            o_xml              out clob
            , i_lang           in  com_api_type_pkg.t_dict_value
            , i_year           in  com_api_type_pkg.t_tiny_id
            , i_quarter        in  com_api_type_pkg.t_sign
            , i_inst_id        in  com_api_type_pkg.t_inst_id
            )
is
    l_header           xmltype;
    l_detail           xmltype;
    l_result           xmltype;
    l_lang             com_api_type_pkg.t_dict_value;
begin

    trc_log_pkg.debug (
            i_text          => 'qpr_api_report_pkg.vs_acquiring_contactless [#1][#2][#3][#4]'
            , i_env_param1  => i_lang
            , i_env_param2  => i_year
            , i_env_param3  => i_quarter
            , i_env_param4  => i_inst_id
    );

    l_lang := nvl( i_lang, get_user_lang );
    -- header
    select xmlelement ( "header",
               xmlelement( "p_year", i_year)
               , xmlelement( "p_quarter", i_quarter)
           )
      into l_header
      from dual;

    -- details
    select
           xmlelement("table"
                     , xmlagg(
                            xmlelement( "record"
                                 , xmlelement( "report_name", report_name)
                                 , xmlelement( "group_name", group_name)
                                 , xmlelement( "param_name", param_name)
                                 , xmlelement( "cnt1", cnt1)
                                 , xmlelement( "amount1", amount1)
                                 , xmlelement( "month1", month1)
                                 , xmlelement( "cnt2", cnt2)
                                 , xmlelement( "amount2", amount2)
                                 , xmlelement( "month2", month2)
                            )
                        )
           )
    into
           l_detail
    from (
            with inst as
                 (select id as inst_id
                    from ost_institution i
                    connect by prior id = parent_id
                    start with id = i_inst_id
                 )
            select qgr.report_name
                 , nvl(qg.group_desc, qg.group_name) as group_name
                 , nvl(qp.param_desc, qp.param_name) as param_name
                 , sum(nvl(qpvd.value_1, 0)) as cnt1
                 , trim(to_char(sum(nvl(qpvd.value_2,0)), 'FM999999999999990')) as amount1
                 , to_date(to_char(nvl(qpvd.year, i_year))||lpad(to_char(nvl(qpvd.month_num, i_quarter * 3 - 2)),2,'0'),'yyyymm') month1
                 , sum(nvl(qpvc.value_1, 0)) as cnt2
                 , trim(to_char(sum(nvl(qpvc.value_2,0)), 'FM999999999999990')) as amount2
                 , to_date(to_char(nvl(qpvc.year, i_year))||lpad(to_char(nvl(qpvc.month_num, i_quarter * 3 - 2)),2,'0'),'yyyymm') month2
                 , qg.priority
                 , qp.id param_id
              from qpr_group_report qgr
                 , qpr_group qg
                 , (select id, param_id, group_id, priority, inst_id
                      from qpr_param_group gp , inst) qpg
                 , qpr_param qp
                 , qpr_param_value qpvd
                 , qpr_param_value qpvc
             where qgr.report_name          = 'PS_VISA_ACQUIRING_CONTACTLESS'
               and qg.id                    = qgr.id
               and qpg.group_id             = qg.id
               and qp.id(+)                 = qpg.param_id
               and qpvd.param_group_id(+)   = qpg.id
               and qpvd.id_param_value(+)   = qpg.param_id
               and qpvd.year(+)             = i_year
               and qpvd.month_num(+)        = i_quarter * 3 - 2
               and qpvd.inst_id(+)          = qpg.inst_id
               and nvl(qpvd.value_3,0)      = 0
               and qpvc.param_group_id(+)   = qpg.id
               and qpvc.id_param_value(+)   = qpg.param_id
               and qpvc.year(+)             = i_year
               and qpvc.month_num(+)        = i_quarter * 3 - 2
               and qpvc.inst_id(+)          = qpg.inst_id
               and nvl(qpvc.value_3,1)      = 1
               and nvl(qpg.priority,0)     != -1
             group by qgr.report_name
                    , nvl(qg.group_desc, qg.group_name)
                    , nvl(qp.param_desc, qp.param_name)
                    , to_date(to_char(nvl(qpvd.year, i_year))||lpad(to_char(nvl(qpvd.month_num, i_quarter * 3 - 2)),2,'0'),'yyyymm')
                    , to_date(to_char(nvl(qpvc.year, i_year))||lpad(to_char(nvl(qpvc.month_num, i_quarter * 3 - 2)),2,'0'),'yyyymm')
                    , qg.priority
                    , qp.id
             order by qgr.report_name
                    , qg.priority
                    , qp.id
           );

    --if no data
    if l_detail.getclobval() = '<table></table>' then
        select xmlelement("table"
                       , xmlagg(
                            xmlelement("record"
                                 , xmlelement( "report_name", null)
                                 , xmlelement( "group_name", null)
                                 , xmlelement( "param_name", null)
                                 , xmlelement( "cnt1", null)
                                 , xmlelement( "amount1", null)
                                 , xmlelement( "month1", null)
                                 , xmlelement( "cnt2", null)
                                 , xmlelement( "amount2", null)
                                 , xmlelement( "month2", null)
                            )
                         )
              )
        into l_detail from dual ;
    end if;

    select xmlelement ( "report"
             , l_header
             , l_detail
           )
    into l_result from dual;

    o_xml := l_result.getclobval();

    trc_log_pkg.debug ( i_text => 'qpr_api_report_pkg.vs_acquiring_contactless - ok' );

exception when others then
    trc_log_pkg.debug ( i_text => sqlerrm );
    raise ;
END vs_acquiring_contactless;

procedure vs_acquiring (
            o_xml              out clob
            , i_lang           in  com_api_type_pkg.t_dict_value
            , i_year           in  com_api_type_pkg.t_tiny_id
            , i_quarter        in  com_api_type_pkg.t_sign
            , i_inst_id        in  com_api_type_pkg.t_inst_id
            )
is
    l_header           xmltype;
    l_detail           xmltype;
    l_result           xmltype;
    l_lang             com_api_type_pkg.t_dict_value;
    l_cmid             com_api_type_pkg.t_cmid;
begin

    trc_log_pkg.debug (
            i_text          => 'qpr_api_report_pkg.vs_acquiring [#1][#2][#3][#4]'
            , i_env_param1  => i_lang
            , i_env_param2  => i_year
            , i_env_param3  => i_quarter
            , i_env_param4  => i_inst_id
    );

    l_lang := nvl( i_lang, get_user_lang );

    select max(nvl(v.cmid, '0000'))
      into l_cmid
      from qpr_param_value v
         , (select id as inst_id
              from ost_institution i
              connect by prior id = parent_id
              start with id = i_inst_id
           ) inst
     where v.year     = i_year
       and ceil(nvl(v.month_num, i_quarter*3)/3) = i_quarter
       and v.inst_id  = inst.inst_id;

     -- header
    select
        xmlconcat(
            xmlelement("year", i_year)
            , xmlelement("quarter", i_quarter)
        )
    into
        l_header
    from dual;

    -- details
    select
        xmlelement("acquiring"
            , xmlagg(
                xmlelement("param"
                    , xmlelement("group_id", group_id)
                    , xmlelement("group_desc", group_desc)
                    , xmlelement("param_id", param_id)
                    , xmlelement("param_desc", param_desc)
                    , xmlelement("year", i_year)
                    , xmlelement("month", to_char(dt, 'MONTH yyyy'))
                    -- always without precision
                    , xmlelement("value_1", trim(to_char(nvl(value_1, 0), 'FM999999999999990')))
                    -- without precision
                    , xmlelement("value_2", trim(to_char(nvl(round(value_2), 0), 'FM999999999999990')))
                    -- always without precision
                    , xmlelement("value_3", trim(to_char(nvl(value_3, 0), 'FM999999999999990')))
                    -- without precision
                    , xmlelement("value_4", trim(to_char(nvl(round(value_4), 0), 'FM999999999999990')))

                    -- always without precision
                    , xmlelement("value_5", trim(to_char(nvl(value_5, 0), 'FM999999999999990')))
                    -- without precision
                    , xmlelement("value_6", trim(to_char(nvl(round(value_6), 0), 'FM999999999999990')))
                    -- always without precision
                    , xmlelement("value_7", trim(to_char(nvl(value_7, 0), 'FM999999999999990')))
                    -- without precision
                    , xmlelement("value_8", trim(to_char(nvl(round(value_8), 0), 'FM999999999999990')))

                    -- always without precision
                    , xmlelement("value_9", trim(to_char(nvl(value_9, 0), 'FM999999999999990')))
                    -- without precision
                    , xmlelement("value_10", trim(to_char(nvl(round(value_10), 0), 'FM999999999999990')))
                    -- always without precision
                    , xmlelement("value_11", trim(to_char(nvl(value_11, 0), 'FM999999999999990')))
                    -- without precision
                    , xmlelement("value_12", trim(to_char(nvl(round(value_12), 0), 'FM999999999999990')))

                    -- always without precision
                    , xmlelement("value_13", trim(to_char(nvl(value_13, 0), 'FM999999999999990')))
                    -- without precision
                    , xmlelement("value_14", trim(to_char(nvl(round(value_14), 0), 'FM999999999999990')))
                    -- always without precision
                    , xmlelement("value_15", trim(to_char(nvl(value_15, 0), 'FM999999999999990')))
                    -- without precision
                    , xmlelement("value_16", trim(to_char(nvl(round(value_16), 0), 'FM999999999999990')))
                )
            )
        )
    into
           l_detail
    from (
        select v.*
             , case when v.month is not null then to_date('01' || lpad(v.month, 2, '0') || v.year, 'ddmmyyyy') end dt
          from (
            with inst as
                 (select id as inst_id
                    from ost_institution i
                    connect by prior id = parent_id
                    start with id = i_inst_id
                 )
            , mn as
                 (select i_quarter * 3 - level + 1 month_num
                    from dual
                 connect by level < 4
                 )
           select
                group_id
                , group_desc
                , param_id
                , param_desc
                , year
                , month
                , max(case when region = 'Total' then value_1 end) as value_1
                , max(case when region = 'Total' then value_2 end) as value_2
                , max(case when region = 'Total' then value_3 end) as value_3
                , max(case when region = 'Total' then value_4 end) as value_4

                , max(case when region = 'On Us' then value_1 end) as value_5
                , max(case when region = 'On Us' then value_2 end) as value_6
                , max(case when region = 'On Us' then value_3 end) as value_7
                , max(case when region = 'On Us' then value_4 end) as value_8

                , max(case when region = 'Intra' then value_1 end) as value_9
                , max(case when region = 'Intra' then value_2 end) as value_10
                , max(case when region = 'Intra' then value_3 end) as value_11
                , max(case when region = 'Intra' then value_4 end) as value_12

                , max(case when region = 'Inter' then value_1 end) as value_13
                , max(case when region = 'Inter' then value_2 end) as value_14
                , max(case when region = 'Inter' then value_3 end) as value_15
                , max(case when region = 'Inter' then value_4 end) as value_16

            from (
             -- Acquirer Data
            select g.id          as group_id
                 , g.group_desc
                 , p.id          as param_id
                 , p.param_desc
                 , i_year as year
                 , gp.month_num  as month
                 , sum(nvl(decode(nvl(v1.value_3, 0), 0, v1.value_1), 0)) as value_1  -- debit
                 , sum(nvl(decode(nvl(v1.value_3, 0), 0, v1.value_2), 0)) as value_2

                 , sum(nvl(decode(nvl(v1.value_3, 0), 1, v1.value_1), 0)) as value_3  -- credit
                 , sum(nvl(decode(nvl(v1.value_3, 0), 1, v1.value_2), 0)) as value_4

                 , case grouping(gp.region)
                       when 0
                       then gp.region
                       else 'Total'
                   end region
              from qpr_group_report r
                 , qpr_group g
                 , (select id, param_id, group_id, priority, inst.inst_id, mn.month_num, r.region
                      from qpr_param_group gp, inst, mn, (select 'On Us' region from dual union all select 'Intra' from dual union all select 'Inter' from dual) r
                 ) gp
                 , qpr_param p
                 , qpr_param_value v1
             where r.report_name          = 'PS_VISA_ACQUIRING'
               and g.id                    = r.id
               and gp.group_id             = g.id
               and p.id                   != 2106
               and p.id(+)                 = gp.param_id
               and v1.param_group_id(+)   = gp.id
               and v1.id_param_value(+)   = gp.param_id
               and v1.year(+)             = i_year
               and v1.month_num(+) = gp.month_num
               and v1.inst_id(+)          = gp.inst_id
               and v1.cmid(+)             = l_cmid
               and v1.bin(+)              = gp.region
               and nvl(gp.priority,0)     != -1
               and g.id = 229
           group by
               g.id
               , g.group_desc
               , p.id
               , p.param_desc
               , gp.month_num
               , rollup(gp.region)

           union all

            -- Net totals for Acquirer Data
            select g.id                         as group_id
                 , g.group_desc
                 , p.id                         as param_id
                 , p.param_desc
                 , i_year                       as year
                 , gp.month_num  as month
                 , sum(case
                           when gp.param_id in (2102, 2103)
                           then -1
                           else 1
                       end * nvl(decode(nvl(v1.value_3, 0), 0, v1.value_1), 0)) as value_1  -- debit
                 , sum(case
                           when gp.param_id in (2102, 2103)
                           then -1
                           else 1
                       end * nvl(decode(nvl(v1.value_3, 0), 0, v1.value_2), 0)) as value_2

                 , sum(case
                           when gp.param_id in (2102, 2103)
                           then -1
                           else 1
                       end * nvl(decode(nvl(v1.value_3, 0), 1, v1.value_1), 0)) as value_3  -- credit
                 , sum(case
                           when gp.param_id in (2102, 2103)
                           then -1
                           else 1
                       end * nvl(decode(nvl(v1.value_3, 0), 1, v1.value_2), 0)) as value_4
                 , case grouping(gp.region)
                       when 0
                       then gp.region
                       else 'Total'
                   end region
              from qpr_group_report r
                 , qpr_group g
                 , (select id, param_id, group_id, priority, inst.inst_id, mn.month_num, r.region
                      from qpr_param_group gp, inst, mn, (select 'On Us' region from dual union all select 'Intra' from dual union all select 'Inter' from dual) r
                 ) gp
                 , qpr_param p
                 , qpr_param_value v1
             where r.report_name       = 'PS_VISA_ACQUIRING'
               and g.id                = r.id
               and gp.group_id         = g.id
               and p.id                   = 2106
               and p.id                  != gp.param_id
               and v1.param_group_id(+)   = gp.id
               and v1.id_param_value(+)   = gp.param_id
               and v1.year(+)             = i_year
               and v1.month_num(+)        = gp.month_num
               and v1.inst_id(+)          = gp.inst_id
               and v1.cmid(+)             = l_cmid
               and v1.bin(+)              = gp.region
               and nvl(gp.priority,0)    != -1
               and g.id = 229
           group by
               g.id
                 , g.group_desc
                 , p.id
                 , p.param_desc
                 , gp.month_num
                 , rollup(gp.region)
          )
          group by
            group_id
            , group_desc
            , param_id
            , param_desc
            , year
            , month
          union all

            -- Merchant Data
            -- Merchant Category Groups
            select g.id            as group_id
                 , g.group_desc    as group_desc
                 , p.id            as param_id
                 , nvl(p.param_desc, p.param_name) as param_desc
                 , i_year          as year
                 , to_number(null) as month
                 , sum(v.value_1)  as value_1
                 , sum(v.value_2)  as value_2
                 , to_number(null) as value_3
                 , to_number(null) as value_4
                 , to_number(null) as value_5
                 , to_number(null) as value_6
                 , to_number(null) as value_7
                 , to_number(null) as value_8

                 , to_number(null) as value_9
                 , to_number(null) as value_10
                 , to_number(null) as value_11
                 , to_number(null) as value_12

                 , to_number(null) as value_13
                 , to_number(null) as value_14
                 , to_number(null) as value_15
                 , to_number(null) as value_16
                 --, to_char(null) as region
              from qpr_group_report r
                 , qpr_group g
                 , (select id, param_id, group_id, priority, inst_id from qpr_param_group gp, inst) gp
                 , qpr_param p
                 , qpr_param_value v
             where r.report_name           in ('PS_VISA_MRC_MCC')
               and g.id                    = r.id
               and gp.group_id             = g.id
               and p.id(+)                 = gp.param_id
               and v.param_group_id(+)   = gp.id
               and v.id_param_value(+)   = gp.param_id
               and v.year(+)             = i_year
               and ceil(nvl(v.month_num(+), i_quarter*3)/3) = i_quarter
               and v.inst_id(+)          = gp.inst_id
               and v.cmid(+)             = l_cmid
               and nvl(gp.priority,0)     != -1
               and g.id in (205, 206)
           group by
               g.id
               , g.group_desc
               , p.id
               , nvl(p.param_desc, p.param_name)

          union all

          -- Total for Merchant Category Groups
            select g.id                         as group_id
                 , g.group_desc
                 , p.id                         as param_id
                 , p.param_desc                 as param_desc
                 , i_year                       as year
                 , to_number(null) as month
                 , sum(v.value_1)               as value_1
                 , sum(v.value_2)               as value_2
                 , to_number(null) as value_3
                 , to_number(null) as value_4
                 , to_number(null) as value_5
                 , to_number(null) as value_6
                 , to_number(null) as value_7
                 , to_number(null) as value_8

                 , to_number(null) as value_9
                 , to_number(null) as value_10
                 , to_number(null) as value_11
                 , to_number(null) as value_12

                 , to_number(null) as value_13
                 , to_number(null) as value_14
                 , to_number(null) as value_15
                 , to_number(null) as value_16
                 --, to_char(null) as region
              from qpr_group g
                 , (select id, param_id, group_id, priority, inst_id
                      from qpr_param_group gp, inst) gp
                 , qpr_param_value v
                 , qpr_group_report r
                 , qpr_param p
             where r.report_name       = 'PS_VISA_MRC_MCC'
               and g.id                = r.id
               and gp.group_id         = g.id
               and p.id                = 2110
               and gp.param_id        != p.id
               and v.param_group_id(+) = gp.id
               and v.id_param_value(+) = gp.param_id
               and v.year(+)           = i_year
               and ceil(nvl(v.month_num(+), i_quarter*3)/3) = i_quarter
               and v.inst_id(+)        = gp.inst_id
               and v.cmid(+)           = l_cmid
               and nvl(gp.priority,0) != -1
               and g.id in (206)
          group by g.id
                 , g.group_desc
                 , p.id
                 , p.param_desc

          union all

            -- Contactless
            select g.id          as group_id
                 , g.group_desc
                 , p.id          as param_id
                 , p.param_desc
                 , i_year        as year
                 , to_number(null) as month
                 , sum(v1.value_1) as value_1
                 , sum(v1.value_2) as value_2
                 , sum(v2.value_1) as value_3
                 , sum(v2.value_2) as value_4
                 , to_number(null) as value_5
                 , to_number(null) as value_6
                 , to_number(null) as value_7
                 , to_number(null) as value_8

                 , to_number(null) as value_9
                 , to_number(null) as value_10
                 , to_number(null) as value_11
                 , to_number(null) as value_12

                 , to_number(null) as value_13
                 , to_number(null) as value_14
                 , to_number(null) as value_15
                 , to_number(null) as value_16
                -- , to_char(null) as region
              from qpr_group_report r
                 , qpr_group g
                 , (select id, param_id, group_id, priority, inst_id from qpr_param_group gp, inst) gp
                 , qpr_param p
                 , qpr_param_value v1
                 , qpr_param_value v2
             where r.report_name           in ('PS_VISA_ACQUIRING_CONTACTLESS')
               and g.id                    = r.id
               and gp.group_id             = g.id
               and p.id(+)                 = gp.param_id
               and v1.param_group_id(+)   = gp.id
               and v1.id_param_value(+)   = gp.param_id
               and v1.year(+)             = i_year
               and ceil(nvl(v1.month_num(+), i_quarter*3)/3) = i_quarter
               and v1.inst_id(+)          = gp.inst_id
               and nvl(v1.value_3(+),0)      = 0
               and v1.cmid(+)             = l_cmid

               and v2.param_group_id(+)   = gp.id
               and v2.id_param_value(+)   = gp.param_id
               and v2.year(+)             = i_year
               and ceil(nvl(v2.month_num(+), i_quarter*3)/3) = i_quarter
               and v2.inst_id(+)          = gp.inst_id
               and nvl(v2.value_3(+),1)      = 1
               and v2.cmid(+)             = l_cmid

               and nvl(gp.priority,0)     != -1
               and g.id in (226)
           group by
               g.id
               , g.group_desc
               , p.id
               , p.param_desc

           union all

            -- 227 Acquired Electronic Commerce Transactions
            -- 228 Acquired International ATM Transactions
            -- 230 MOTO (Mail and Telephone Order)
            -- 231 Acquired Recurring Transaction
            select g.id          as group_id
                 , g.group_desc
                 , p.id          as param_id
                 , p.param_desc
                 , i_year        as year
                 , to_number(null) as month
                 , sum(v.value_1) as value_1
                 , sum(v.value_2) as value_2
                 , to_number(null) as value_3
                 , to_number(null) as value_4
                 , to_number(null) as value_5
                 , to_number(null) as value_6
                 , to_number(null) as value_7
                 , to_number(null) as value_8

                 , to_number(null) as value_9
                 , to_number(null) as value_10
                 , to_number(null) as value_11
                 , to_number(null) as value_12

                 , to_number(null) as value_13
                 , to_number(null) as value_14
                 , to_number(null) as value_15
                 , to_number(null) as value_16
                 --, to_char(null) as region
              from qpr_group_report r
                 , qpr_group g
                 , (select id, param_id, group_id, priority, inst_id from qpr_param_group gp, inst) gp
                 , qpr_param p
                 , qpr_param_value v
             where r.report_name           in ('PS_MOTO_RECURRING', 'PS_VISA_ACQUIRING_ECOMMERCE', 'PS_VISA_ACQUIRING_ATM')
               and g.id                    = r.id
               and gp.group_id             = g.id
               and p.id(+)                 = gp.param_id
               and v.param_group_id(+)   = gp.id
               and v.id_param_value(+)   = gp.param_id
               and v.year(+)             = i_year
               and ceil(nvl(v.month_num(+), i_quarter*3)/3) = i_quarter
               and v.inst_id(+)          = gp.inst_id
               and v.cmid(+)             = l_cmid
               and nvl(gp.priority,0)     != -1
               and g.id in (227, 228, 230, 231)
           group by
               g.id
               , g.group_desc
               , p.id
               , p.param_desc

         ) v
         , qpr_group g
         , qpr_param_group gp
      where g.id = v.group_id
        and gp.group_id = g.id
        and v.param_id(+) = gp.param_id
      order by g.priority
             , v.month
             , gp.priority
             , v.param_id nulls first
           );

    --if no data
    if l_detail.getclobval() = '<acquiring></acquiring>' then
        select
            xmlelement("acquiring"
                , xmlagg(
                    xmlelement("param"
                        , xmlelement("group_id", null)
                        , xmlelement("group_desc", null)
                        , xmlelement("param_id", null)
                        , xmlelement("param_desc", null)
                        , xmlelement("year", null)
                        , xmlelement("month", null)
                        , xmlelement("value_1", null)
                        , xmlelement("value_2", null)
                        , xmlelement("value_3", null)
                        , xmlelement("value_4", null)
                        , xmlelement("value_5", null)
                        , xmlelement("value_6", null)
                    )
                )
            )
        into l_detail from dual ;
    end if;

    select xmlelement ( "report"
             , l_header
             , l_detail
           )
    into l_result from dual;

    o_xml := l_result.getclobval();

    trc_log_pkg.debug ( i_text => 'qpr_api_report_pkg.vs_acquiring_v_pay - ok' );

exception when others then
    trc_log_pkg.debug ( i_text => sqlerrm );
    raise ;
END vs_acquiring;

procedure vs_acquiring_ecommerce (
            o_xml              out clob
            , i_lang           in  com_api_type_pkg.t_dict_value
            , i_year           in  com_api_type_pkg.t_tiny_id
            , i_quarter        in  com_api_type_pkg.t_sign
            , i_inst_id        in  com_api_type_pkg.t_inst_id
            )
is
    l_header           xmltype;
    l_detail           xmltype;
    l_result           xmltype;
    l_lang             com_api_type_pkg.t_dict_value;
begin

    trc_log_pkg.debug (
            i_text          => 'qpr_api_report_pkg.vs_acquiring_ecommerce [#1][#2][#3][#4]'
            , i_env_param1  => i_lang
            , i_env_param2  => i_year
            , i_env_param3  => i_quarter
            , i_env_param4  => i_inst_id
    );

    l_lang := nvl( i_lang, get_user_lang );
    -- header
    select xmlelement ( "header",
               xmlelement( "p_year", i_year)
               , xmlelement( "p_quarter", i_quarter)
           )
      into l_header
      from dual;

    -- details
    select
           xmlelement("table"
                     , xmlagg(
                            xmlelement( "record"
                                 , xmlelement( "report_name", report_name)
                                 , xmlelement( "group_name", group_name)
                                 , xmlelement( "param_name", param_name)
                                 , xmlelement( "cnt1", cnt1)
                                 , xmlelement( "amount1", amount1)
                                 , xmlelement( "month1", month1)
                            )
                        )
           )
    into
           l_detail
    from (
            with inst as
                 (select id as inst_id
                    from ost_institution i
                    connect by prior id = parent_id
                    start with id = i_inst_id
                 )
            select qgr.report_name
                 , nvl(qg.group_desc, qg.group_name) as group_name
                 , nvl(qp.param_desc, qp.param_name) as param_name
                 , sum(nvl(qpv.value_1, 0)) as cnt1
                 , trim(to_char(sum(nvl(qpv.value_2,0)), 'FM999999999999990')) as amount1
                 , to_date(to_char(nvl(qpv.year, i_year))||lpad(to_char(nvl(qpv.month_num, i_quarter * 3 - 2)),2,'0'),'yyyymm') month1
                 , qg.priority
                 , qp.id param_id
              from qpr_group_report qgr
                 , qpr_group qg
                 , (select id, param_id, group_id, priority, inst_id
                      from qpr_param_group gp , inst) qpg
                 , qpr_param qp
                 , qpr_param_value qpv
             where qgr.report_name          in ('PS_MOTO_RECURRING', 'PS_VISA_ACQUIRING_ECOMMERCE', 'PS_VISA_ACQUIRING_ATM')
               and qg.id                    = qgr.id
               and qpg.group_id             = qg.id
               and qp.id(+)                 = qpg.param_id
               and qpv.param_group_id(+)   = qpg.id
               and qpv.id_param_value(+)   = qpg.param_id
               and qpv.year(+)             = i_year
               and qpv.month_num(+)        = i_quarter * 3 - 2
               and qpv.inst_id(+)          = qpg.inst_id
               and nvl(qpg.priority,0)     != -1
             group by qgr.report_name
                    , nvl(qg.group_desc, qg.group_name)
                    , nvl(qp.param_desc, qp.param_name)
                    , to_date(to_char(nvl(qpv.year, i_year))||lpad(to_char(nvl(qpv.month_num, i_quarter * 3 - 2)),2,'0'),'yyyymm')
                    , qg.priority
                    , qp.id
             order by qgr.report_name
                    , qg.priority
                    , qp.id
           );

    --if no data
    if l_detail.getclobval() = '<table></table>' then
        select xmlelement("table"
                       , xmlagg(
                            xmlelement("record"
                                 , xmlelement( "report_name", null)
                                 , xmlelement( "group_name", null)
                                 , xmlelement( "param_name", null)
                                 , xmlelement( "cnt1", null)
                                 , xmlelement( "amount1", null)
                                 , xmlelement( "month1", null)
                            )
                         )
              )
        into l_detail from dual ;
    end if;

    select xmlelement ( "report"
             , l_header
             , l_detail
           )
    into l_result from dual;

    o_xml := l_result.getclobval();

    trc_log_pkg.debug ( i_text => 'qpr_api_report_pkg.vs_acquiring_ecommerce - ok' );

exception when others then
    trc_log_pkg.debug ( i_text => sqlerrm );
    raise ;
END vs_acquiring_ecommerce;

procedure vs_acquiring_vmt(
    o_xml              out clob
  , i_lang           in    com_api_type_pkg.t_dict_value
  , i_year           in    com_api_type_pkg.t_tiny_id
  , i_quarter        in    com_api_type_pkg.t_sign
  , i_inst_id        in    com_api_type_pkg.t_inst_id
)
is
    l_header           xmltype;
    l_detail           xmltype;
    l_result           xmltype;
    l_logo_path        xmltype;

begin

    trc_log_pkg.debug(
        i_text          => 'qpr_api_report_pkg.vs_acquiring_vmt [#1][#2][#3][#4]'
      , i_env_param1  => i_lang
      , i_env_param2  => i_year
      , i_env_param3  => i_quarter
      , i_env_param4  => i_inst_id
);

    -- header
    l_logo_path := rpt_api_template_pkg.logo_path_xml;
    select xmlelement ( "header"
               , l_logo_path
               , xmlelement("p_year"    , i_year   )
               , xmlelement("p_quarter" , i_quarter)
           )
    into l_header
    from (select i_year
               , i_quarter
            from dual
         );

    -- details
    select xmlelement("table"
             , xmlagg(
                   xmlelement("record"
                     , xmlelement("report_name", report_name)
                     , xmlelement("group_name",  group_name)
                     , xmlelement("param_name",  param_name)
                     , xmlelement("param_desc",  param_desc)
                     , xmlelement("cnt1",        cnt1)
                     , xmlelement("amount1",     amount1)
                     , xmlelement("month1",      month1)
                     , xmlelement("cnt2",        cnt2)
                     , xmlelement("amount2",     amount2)
                     , xmlelement("month2",      month2)
                     , xmlelement("cnt3",        cnt3)
                     , xmlelement("amount3",     amount3)
                     , xmlelement("month3",      month3)
                    )
                )
           )
      into l_detail
      from( with inst as
                 (select id as inst_id
                    from ost_institution i
                    connect by prior id = parent_id
                    start with id = i_inst_id
                 )
            select qgr.report_name
                 , qg.group_name
                 , qp.param_name
                 , qp.param_desc
                 , sum(nvl(qpv1.value_1, 0))                                                                                      cnt1
                 , trim(to_char(sum(nvl(qpv1.value_2,0)), 'FM999999999999990'))                                                   amount1
                 , to_date(to_char(nvl(qpv1.year, i_year))||lpad(to_char(nvl(qpv1.month_num, i_quarter * 3 - 2)),2,'0'),'yyyymm') month1
                 , sum(nvl(qpv2.value_1, 0))                                                                                      cnt2
                 , trim(to_char(sum(nvl(qpv2.value_2,0)), 'FM999999999999990'))                                                   amount2
                 , to_date(to_char(nvl(qpv2.year, i_year))||lpad(to_char(nvl(qpv2.month_num, i_quarter * 3 - 1)),2,'0'),'yyyymm') month2
                 , sum(nvl(qpv3.value_1, 0))                                                                                      cnt3
                 , trim(to_char(sum(nvl(qpv3.value_2,0)), 'FM999999999999990'))                                                   amount3
                 , to_date(to_char(nvl(qpv3.year, i_year))||lpad(to_char(nvl(qpv3.month_num, i_quarter * 3)),2,'0'),'yyyymm')     month3
                 , qg.priority
                 , qp.id param_id
              from qpr_group_report qgr
                 , qpr_group qg
                 , (select id, param_id, group_id, priority, inst_id
                      from qpr_param_group gp , inst) qpg
                 , qpr_param qp
                 , qpr_param_value qpv1
                 , qpr_param_value qpv2
                 , qpr_param_value qpv3
             where qgr.report_name        = 'PS_VISA_ACQUIRING_VMT'
               and qg.id                  = qgr.id
               and qpg.group_id           = qg.id
               and qp.id(+)               = qpg.param_id
               and qpv1.param_group_id(+) = qpg.id
               and qpv1.id_param_value(+) = qpg.param_id
               and qpv1.year(+)           = i_year
               and qpv1.month_num(+)      = i_quarter * 3 - 2
               and qpv1.inst_id(+)        = qpg.inst_id
               and qpv2.param_group_id(+) = qpg.id
               and qpv2.id_param_value(+) = qpg.param_id
               and qpv2.year(+)           = i_year
               and qpv2.month_num(+)      = i_quarter * 3 - 1
               and qpv2.inst_id(+)        = qpg.inst_id
               and qpv3.param_group_id(+) = qpg.id
               and qpv3.id_param_value(+) = qpg.param_id
               and qpv3.year(+)           = i_year
               and qpv3.month_num(+)      = i_quarter * 3
               and qpv3.inst_id(+)        = qpg.inst_id
               and nvl(qpg.priority,0)   != -1
             group by qgr.report_name
                    , qg.group_name
                    , qp.param_name
                    , qp.param_desc
                    , to_date(to_char(nvl(qpv1.year, i_year))||lpad(to_char(nvl(qpv1.month_num, i_quarter * 3 - 2)),2,'0'),'yyyymm')
                    , to_date(to_char(nvl(qpv2.year, i_year))||lpad(to_char(nvl(qpv2.month_num, i_quarter * 3 - 1)),2,'0'),'yyyymm')
                    , to_date(to_char(nvl(qpv3.year, i_year))||lpad(to_char(nvl(qpv3.month_num, i_quarter * 3)),2,'0'),'yyyymm')
                    , qg.priority
                    , qp.id
             order by qgr.report_name
                    , qg.priority
                    , qp.id
           );

    --if no data
    if l_detail.getclobval() = '<table></table>' then
        select xmlelement("table"
                 , xmlagg(
                       xmlelement("record"
                         , xmlelement("report_name", null)
                         , xmlelement("group_name",  null)
                         , xmlelement("param_name",  null)
                         , xmlelement("param_desc",  null)
                         , xmlelement("cnt1",        null)
                         , xmlelement("amount1",     null)
                         , xmlelement("month1",      null)
                         , xmlelement("cnt2",        null)
                         , xmlelement("amount2",     null)
                         , xmlelement("month2",      null)
                         , xmlelement("cnt3",        null)
                         , xmlelement("amount3",     null)
                         , xmlelement("month3",      null)
                       )
                   )
               )
        into l_detail from dual;
    end if;

    select xmlelement(
               "report"
             , l_header
             , l_detail
           )
      into l_result
      from dual;

    o_xml := l_result.getclobval();

    trc_log_pkg.debug(i_text => 'qpr_api_report_pkg.vs_acquiring_vmt - ok');

exception when others then
    trc_log_pkg.debug(i_text => sqlerrm);
    raise;
end vs_acquiring_vmt;

procedure vs_cemea(
    o_xml              out clob
    , i_lang           in  com_api_type_pkg.t_dict_value
    , i_year           in  com_api_type_pkg.t_tiny_id
    , i_quarter        in  com_api_type_pkg.t_sign
    , i_inst_id        in  com_api_type_pkg.t_inst_id)
is
    l_header           xmltype;
    l_detail           xmltype;
    l_result           xmltype;
    l_bid              com_api_type_pkg.t_name := '1000XXXX';
    l_country_code     com_api_type_pkg.t_country_code;
    l_period_name      com_api_type_pkg.t_name;
begin
    trc_log_pkg.debug(
        i_text        => 'qpr_api_report_pkg.vs_cemea [#1][#2][#3][#4]'
      , i_env_param1  => i_lang
      , i_env_param2  => i_year
      , i_env_param3  => i_quarter
      , i_env_param4  => i_inst_id
    );

    select max(nvl(v.cmid, '0'))
      into l_bid
      from qpr_param_value v
         , (select id as inst_id
              from ost_institution i
             where i.id not in (select distinct parent_id from ost_institution where parent_id is not null)
            connect by prior id = parent_id
            start with id = i_inst_id
           ) inst
     where v.year     = i_year
       and ceil(nvl(v.month_num, i_quarter*3)/3) = i_quarter
       and v.inst_id  = inst.inst_id
       and v.id_param_value in (2340, 2344, 2347)
       and (v.card_type_id not in (mcw_api_const_pkg.QR_MASTER_CARD_TYPE
                                 , mcw_api_const_pkg.QR_MAESTRO_CARD_TYPE)
            or v.card_type_id is null);

    l_country_code := com_api_country_pkg.get_country_code(
                          i_entity_type  => ost_api_const_pkg.ENTITY_TYPE_INSTITUTION
                        , i_object_id    => i_inst_id
                      );

    if l_country_code is null then
        trc_log_pkg.warn(
            i_text        => 'Country code in address book is not configured for institution [#1]'
            , i_env_param1  => i_inst_id
        );
    end if;

    l_period_name := 'Q'||i_quarter||'-'||to_char(to_date('01'||lpad(i_quarter*3, 2, '0')||i_year, 'dd/mm/yyyy'), 'MON')||'-'||i_year;

    -- header
    select xmlelement ( "header",
                 xmlelement( "bid", l_bid )
               , xmlelement( "country_code", l_country_code )
               , xmlelement( "period", l_period_name)
           )
    into l_header
    from dual;

    -- details
    select xmlelement("table"
                     , xmlagg(
                            xmlelement("record"
                              , xmlelement( "sheet", sheet)
                              , xmlelement( "report_name", report_name)
                              , xmlelement( "group_name", group_name)
                              , xmlelement( "param_name", param_name)
                              , xmlelement( "param_value", param_value)
                              , xmlelement( "param_value_2", param_value_2)
                              , xmlelement( "param_value_3", param_value_3)
                              , xmlelement( "param_value_4", param_value_4)
                              , xmlelement( "param_value_5", param_value_5)
                              , xmlelement( "param_value_6", param_value_6)
                              , xmlelement( "param_value_7", param_value_7)
                              , xmlelement( "param_value_8", param_value_8)
                              , xmlelement( "param_value_9", param_value_9)
                              , xmlelement( "param_value_10", param_value_10)
                              , xmlelement( "col_header_1", to_char(col_header_1))
                              , xmlelement( "col_header_2", to_char(col_header_2))
                              , xmlelement( "col_header_3", to_char(col_header_3))
                              , xmlelement( "col_header_4", to_char(col_header_4))
                              , xmlelement( "col_header_5", to_char(col_header_5))
                              , xmlelement( "col_header_6", to_char(col_header_6))
                              , xmlelement( "col_header_7", to_char(col_header_7))
                              , xmlelement( "col_header_8", to_char(col_header_8))
                              , xmlelement( "col_header_9", to_char(col_header_9))
                              , xmlelement( "col_header_10", to_char(col_header_10))
                            )
                          order by sheet
                                 , group_priority
                                 , param_priority
                        )
           )
      into l_detail
      from(with
           inst as (
              select rownum as rn, id as inst_id
                from ost_institution i
             connect by prior id = parent_id
               start with id     = i_inst_id
           )
         , affiliate as (
              select rownum as rn, id as inst_id
                from ost_institution i
                where i.id not in (select distinct parent_id from ost_institution where parent_id is not null)
             connect by prior id = parent_id
               start with id     = i_inst_id
           )
         , b as(
              select rownum as rn, t.bin
                from (select distinct qpv.bin
                        from qpr_group_report qgr
                           , qpr_group qg
                           , (select id
                                   , param_id
                                   , group_id
                                   , priority
                                   , inst_id
                                from qpr_param_group gp
                                   , inst) qpg
                           , qpr_param qp
                           , qpr_param_value qpv
                       where qgr.report_name       in ('PS_CEMEA_VISA_BIN_PROGRAM')
                         and qg.id                 = qgr.id
                         and qpg.group_id(+)       = qg.id
                         and qp.id(+)              = qpg.param_id
                         and qpv.param_group_id(+) = qpg.id
                         and qpv.id_param_value(+) = qpg.param_id
                         and qpv.year(+)           = i_year
                         and ceil(nvl(qpv.month_num(+), i_quarter * 3)/ 3) = i_quarter
                         and qpv.inst_id(+)        = qpg.inst_id
                         and nvl(qpg.priority,0)  != -1
                         and qpv.bin is not null
                         ) t
          ),
          bid as(
              select rownum as rn
                   , t.cmid
                   , com_api_country_pkg.get_country_code(
                         i_entity_type  => ost_api_const_pkg.ENTITY_TYPE_INSTITUTION
                       , i_object_id    => i_inst_id
                     ) as country
                from (select distinct qpv.cmid
                        from qpr_group_report qgr
                           , qpr_group qg
                           , (select id, param_id, group_id, priority, inst_id
                                from qpr_param_group gp, affiliate) qpg
                           , qpr_param qp
                           , qpr_param_value qpv
                       where qgr.report_name       in ('PS_CEMEA_VISA_ASSOCIATE')
                         and qg.id                 = qgr.id
                         and qpg.group_id(+)       = qg.id
                         and qp.id(+)              = qpg.param_id
                         and qpv.param_group_id(+) = qpg.id
                         and qpv.id_param_value(+) = qpg.param_id
                         and qpv.year(+)           = i_year
                         and ceil(nvl(qpv.month_num(+), i_quarter * 3)/ 3) = i_quarter
                         and qpv.inst_id(+)        = qpg.inst_id
                         and nvl(qpg.priority,0)  != -1
                         and qpv.cmid             is not null
                       order by qpv.cmid) t
          )
          select distinct 2 as sheet
               , qgr.report_name
               , qg.group_name
               , qp.param_name
               , sum(case when upper(qpv.card_type) = upper('VISA Business') then nvl(qpv.value_1, 0) else 0 end)
                     over (partition by qgr.report_name, qg.group_name, qp.param_name, qg.priority, qpg.priority, qp.id) as param_value
               , sum(case when upper(qpv.card_type) = upper('VISA Classic') then nvl(qpv.value_1, 0) else 0 end)
                     over (partition by qgr.report_name, qg.group_name, qp.param_name, qg.priority, qpg.priority, qp.id) as param_value_2
               , sum(case when upper(qpv.card_type) = upper('VISA Electron') then nvl(qpv.value_1, 0) else 0 end)
                     over (partition by qgr.report_name, qg.group_name, qp.param_name, qg.priority, qpg.priority, qp.id) as param_value_3
               , sum(case when upper(qpv.card_type) = upper('VISA Gold') then nvl(qpv.value_1, 0) else 0 end)
                     over (partition by qgr.report_name, qg.group_name, qp.param_name, qg.priority, qpg.priority, qp.id) as param_value_4
               , sum(case when upper(qpv.card_type) = upper('VISA Platinum') then nvl(qpv.value_1, 0) else 0 end)
                     over (partition by qgr.report_name, qg.group_name, qp.param_name, qg.priority, qpg.priority, qp.id) as param_value_5
               , null as param_value_6
               , null as param_value_7
               , null as param_value_8
               , null as param_value_9
               , null as param_value_10
               , null as col_header_1
               , null as col_header_2
               , null as col_header_3
               , null as col_header_4
               , null as col_header_5
               , null as col_header_6
               , null as col_header_7
               , null as col_header_8
               , null as col_header_9
               , null as col_header_10
               , qg.priority              as group_priority
               , qpg.priority             as param_priority
               , qp.id as param_id
            from qpr_group_report qgr
               , qpr_group qg
               , (select id, param_id, group_id, priority, inst_id
                    from qpr_param_group gp, inst) qpg
               , qpr_param qp
               , qpr_param_value qpv
           where qgr.report_name       in ('PS_CEMEA_VISA_ISSUING_CR')
             and qg.id                 = qgr.id
             and qpg.group_id(+)       = qg.id
             and qp.id(+)              = qpg.param_id
             and qpv.param_group_id(+) = qpg.id
             and qpv.id_param_value(+) = qpg.param_id
             and qpv.year(+)           = i_year
             and ceil(nvl(qpv.month_num(+), i_quarter * 3)/ 3) = i_quarter
             and qpv.inst_id(+)        = qpg.inst_id
             and nvl(qpg.priority,0)  != -1
             and nvl(qpv.value_3(+),0) = 1--CREDIT
           union all
          select distinct 3 as sheet
               , qgr.report_name
               , qg.group_name
               , qp.param_name
               , sum(case when upper(qpv.card_type) = upper('VISA Business') then nvl(qpv.value_1, 0) else 0 end)
                     over (partition by qgr.report_name, qg.group_name, qp.param_name, qg.priority, qpg.priority, qp.id) as param_value
               , sum(case when upper(qpv.card_type) = upper('VISA Classic') then nvl(qpv.value_1, 0) else 0 end)
                     over (partition by qgr.report_name, qg.group_name, qp.param_name, qg.priority, qpg.priority, qp.id) as param_value_2
               , sum(case when upper(qpv.card_type) = upper('VISA Electron') then nvl(qpv.value_1, 0) else 0 end)
                     over (partition by qgr.report_name, qg.group_name, qp.param_name, qg.priority, qpg.priority, qp.id) as param_value_3
               , sum(case when upper(qpv.card_type) = upper('VISA Gold') then nvl(qpv.value_1, 0) else 0 end)
                     over (partition by qgr.report_name, qg.group_name, qp.param_name, qg.priority, qpg.priority, qp.id) as param_value_4
               , sum(case when upper(qpv.card_type) = upper('VISA Platinum') then nvl(qpv.value_1, 0) else 0 end)
                     over (partition by qgr.report_name, qg.group_name, qp.param_name, qg.priority, qpg.priority, qp.id) as param_value_5
               , null as param_value_6
               , null as param_value_7
               , null as param_value_8
               , null as param_value_9
               , null as param_value_10
               , null as col_header_1
               , null as col_header_2
               , null as col_header_3
               , null as col_header_4
               , null as col_header_5
               , null as col_header_6
               , null as col_header_7
               , null as col_header_8
               , null as col_header_9
               , null as col_header_10
               , qg.priority              as group_priority
               , qpg.priority             as param_priority
               , qp.id as param_id
            from qpr_group_report qgr
               , qpr_group qg
               , (select id, param_id, group_id, priority, inst_id
                    from qpr_param_group gp, inst) qpg
               , qpr_param qp
               , qpr_param_value qpv
           where qgr.report_name       in ('PS_CEMEA_VISA_ISSUING_DB')
             and qg.id                 = qgr.id
             and qpg.group_id(+)       = qg.id
             and qp.id(+)              = qpg.param_id
             and qpv.param_group_id(+) = qpg.id
             and qpv.id_param_value(+) = qpg.param_id
             and qpv.year(+)           = i_year
             and ceil(nvl(qpv.month_num(+), i_quarter * 3)/ 3) = i_quarter
             and qpv.inst_id(+)        = qpg.inst_id
             and nvl(qpg.priority,0)  != -1
             and nvl(qpv.value_3(+),0) = 0--DEBIT
           union all
          select distinct 4 as sheet
               , qgr.report_name
               , qg.group_name
               , qp.param_name
               , sum(nvl(qpv.value_1, 0))
                     over (partition by qgr.report_name, qg.group_name, qp.param_name, qg.priority, qpg.priority, qp.id) as param_value
               , null as param_value_2
               , null as param_value_3
               , null as param_value_4
               , null as param_value_5
               , null as param_value_6
               , null as param_value_7
               , null as param_value_8
               , null as param_value_9
               , null as param_value_10
               , null as col_header_1
               , null as col_header_2
               , null as col_header_3
               , null as col_header_4
               , null as col_header_5
               , null as col_header_6
               , null as col_header_7
               , null as col_header_8
               , null as col_header_9
               , null as col_header_10
               , qg.priority              as group_priority
               , qpg.priority             as param_priority
               , qp.id as param_id
            from qpr_group_report qgr
               , qpr_group qg
               , (select id, param_id, group_id, priority, inst_id
                    from qpr_param_group gp, inst) qpg
               , qpr_param qp
               , qpr_param_value qpv
           where qgr.report_name       in ('PS_CEMEA_VISA_ISSUING_PR')
             and qg.id                 = qgr.id
             and qpg.group_id(+)       = qg.id
             and qp.id(+)              = qpg.param_id
             and qpv.param_group_id(+) = qpg.id
             and qpv.id_param_value(+) = qpg.param_id
             and qpv.year(+)           = i_year
             and ceil(nvl(qpv.month_num(+), i_quarter * 3)/ 3) = i_quarter
             and qpv.inst_id(+)        = qpg.inst_id
             and nvl(qpg.priority,0)  != -1
             and nvl(qpv.value_3(+),0) = 2--PREPAID
           union all
          select 5 as sheet
               , qgr.report_name
               , qg.group_name
               , qp.param_name
               , sum(nvl(qpv.value_1, 0)) as param_value
               , null as param_value_2
               , null as param_value_3
               , null as param_value_4
               , null as param_value_5
               , null as param_value_6
               , null as param_value_7
               , null as param_value_8
               , null as param_value_9
               , null as param_value_10
               , null as col_header_1
               , null as col_header_2
               , null as col_header_3
               , null as col_header_4
               , null as col_header_5
               , null as col_header_6
               , null as col_header_7
               , null as col_header_8
               , null as col_header_9
               , null as col_header_10
               , qg.priority              as group_priority
               , qpg.priority             as param_priority
               , qp.id as param_id
            from qpr_group_report qgr
               , qpr_group qg
               , (select id, param_id, group_id, priority, inst_id
                    from qpr_param_group gp, inst) qpg
               , qpr_param qp
               , qpr_param_value qpv
           where qgr.report_name       in ('PS_CEMEA_VISA_ACQUIRING')
             and qg.id                 = qgr.id
             and qpg.group_id(+)       = qg.id
             and qp.id(+)              = qpg.param_id
             and qpv.param_group_id(+) = qpg.id
             and qpv.id_param_value(+) = qpg.param_id
             and qpv.year(+)           = i_year
             and ceil(nvl(qpv.month_num(+), i_quarter * 3)/ 3) = i_quarter
             and qpv.inst_id(+)        = qpg.inst_id
             and nvl(qpg.priority,0)  != -1
           group by qgr.report_name
                  , qg.group_name
                  , qp.param_name
                  , qg.priority
                  , qpg.priority
                  , qp.id
           union all
          select 6 as sheet
               , qgr.report_name
               , qg.group_name
               , qp.param_name
               , sum(case when qpv.cmid = (select cmid from bid where rn = 1) then nvl(qpv.value_1, 0) else 0 end) as param_value
               , sum(case when qpv.cmid = (select cmid from bid where rn = 2) then nvl(qpv.value_1, 0) else 0 end) as param_value_2
               , sum(case when qpv.cmid = (select cmid from bid where rn = 3) then nvl(qpv.value_1, 0) else 0 end) as param_value_3
               , sum(case when qpv.cmid = (select cmid from bid where rn = 4) then nvl(qpv.value_1, 0) else 0 end) as param_value_4
               , sum(case when qpv.cmid = (select cmid from bid where rn = 5) then nvl(qpv.value_1, 0) else 0 end) as param_value_5
               , sum(case when qpv.cmid = (select cmid from bid where rn = 6) then nvl(qpv.value_1, 0) else 0 end) as param_value_6
               , sum(case when qpv.cmid = (select cmid from bid where rn = 7) then nvl(qpv.value_1, 0) else 0 end) as param_value_7
               , sum(case when qpv.cmid = (select cmid from bid where rn = 8) then nvl(qpv.value_1, 0) else 0 end) as param_value_8
               , sum(case when qpv.cmid = (select cmid from bid where rn = 9) then nvl(qpv.value_1, 0) else 0 end) as param_value_9
               , sum(case when qpv.cmid = (select cmid from bid where rn = 10) then nvl(qpv.value_1, 0) else 0 end) as param_value_10
               , nvl((select cmid||'-'||country from bid where rn = 1), 0) as col_header_1
               , nvl((select cmid||'-'||country from bid where rn = 2), 0) as col_header_2
               , nvl((select cmid||'-'||country from bid where rn = 3), 0) as col_header_3
               , nvl((select cmid||'-'||country from bid where rn = 4), 0) as col_header_4
               , nvl((select cmid||'-'||country from bid where rn = 5), 0) as col_header_5
               , nvl((select cmid||'-'||country from bid where rn = 6), 0) as col_header_6
               , nvl((select cmid||'-'||country from bid where rn = 7), 0) as col_header_7
               , nvl((select cmid||'-'||country from bid where rn = 8), 0) as col_header_8
               , nvl((select cmid||'-'||country from bid where rn = 9), 0) as col_header_9
               , nvl((select cmid||'-'||country from bid where rn = 10), 0) as col_header_10
               , qg.priority              as group_priority
               , qpg.priority             as param_priority
               , qp.id as param_id
            from qpr_group_report qgr
               , qpr_group qg
               , (select id, param_id, group_id, priority, inst_id
                    from qpr_param_group gp, affiliate) qpg
               , qpr_param qp
               , qpr_param_value qpv
           where qgr.report_name       in ('PS_CEMEA_VISA_ASSOCIATE')
             and qg.id                 = qgr.id
             and qpg.group_id(+)       = qg.id
             and qp.id(+)              = qpg.param_id
             and qpv.param_group_id(+) = qpg.id
             and qpv.id_param_value(+) = qpg.param_id
             and qpv.year(+)           = i_year
             and ceil(nvl(qpv.month_num(+), i_quarter * 3)/ 3) = i_quarter
             and qpv.inst_id(+)        = qpg.inst_id
             and nvl(qpg.priority,0)  != -1
           group by qgr.report_name
                  , qg.group_name
                  , qp.param_name
                  , qg.priority
                  , qpg.priority
                  , qp.id
           union all
          select distinct 7 as sheet
               , qgr.report_name
               , qg.group_name
               , qp.param_name
               , sum(case when qpv.bin = (select bin from b where rn = 1) then nvl(qpv.value_1, 0) else 0 end)
                     over (partition by qgr.report_name, qg.group_name, qp.param_name, qg.priority, qpg.priority, qp.id) as param_value
               , sum(case when qpv.bin = (select bin from b where rn = 2) then nvl(qpv.value_1, 0) else 0 end)
                     over (partition by qgr.report_name, qg.group_name, qp.param_name, qg.priority, qpg.priority, qp.id) as param_value_2
               , sum(case when qpv.bin = (select bin from b where rn = 3) then nvl(qpv.value_1, 0) else 0 end)
                     over (partition by qgr.report_name, qg.group_name, qp.param_name, qg.priority, qpg.priority, qp.id) as param_value_3
               , sum(case when qpv.bin = (select bin from b where rn = 4) then nvl(qpv.value_1, 0) else 0 end)
                     over (partition by qgr.report_name, qg.group_name, qp.param_name, qg.priority, qpg.priority, qp.id) as param_value_4
               , sum(case when qpv.bin = (select bin from b where rn = 5) then nvl(qpv.value_1, 0) else 0 end)
                     over (partition by qgr.report_name, qg.group_name, qp.param_name, qg.priority, qpg.priority, qp.id) as param_value_5
               , sum(case when qpv.bin = (select bin from b where rn = 6) then nvl(qpv.value_1, 0) else 0 end)
                     over (partition by qgr.report_name, qg.group_name, qp.param_name, qg.priority, qpg.priority, qp.id) as param_value_6
               , sum(case when qpv.bin = (select bin from b where rn = 7) then nvl(qpv.value_1, 0) else 0 end)
                     over (partition by qgr.report_name, qg.group_name, qp.param_name, qg.priority, qpg.priority, qp.id) as param_value_7
               , sum(case when qpv.bin = (select bin from b where rn = 8) then nvl(qpv.value_1, 0) else 0 end)
                     over (partition by qgr.report_name, qg.group_name, qp.param_name, qg.priority, qpg.priority, qp.id) as param_value_8
               , sum(case when qpv.bin = (select bin from b where rn = 9) then nvl(qpv.value_1, 0) else 0 end)
                     over (partition by qgr.report_name, qg.group_name, qp.param_name, qg.priority, qpg.priority, qp.id) as param_value_9
               , sum(case when qpv.bin = (select bin from b where rn = 10) then nvl(qpv.value_1, 0) else 0 end)
                     over (partition by qgr.report_name, qg.group_name, qp.param_name, qg.priority, qpg.priority, qp.id) as param_value_10
               , nvl((select bin from b where rn = 1), 0) as col_header_1
               , nvl((select bin from b where rn = 2), 0) as col_header_2
               , nvl((select bin from b where rn = 3), 0) as col_header_3
               , nvl((select bin from b where rn = 4), 0) as col_header_4
               , nvl((select bin from b where rn = 5), 0) as col_header_5
               , nvl((select bin from b where rn = 6), 0) as col_header_6
               , nvl((select bin from b where rn = 7), 0) as col_header_7
               , nvl((select bin from b where rn = 8), 0) as col_header_8
               , nvl((select bin from b where rn = 9), 0) as col_header_9
               , nvl((select bin from b where rn = 10), 0) as col_header_10
               , qg.priority              as group_priority
               , qpg.priority             as param_priority
               , qp.id as param_id
            from qpr_group_report qgr
               , qpr_group qg
               , (select id, param_id, group_id, priority, inst_id
                    from qpr_param_group gp, inst) qpg
               , qpr_param qp
               , qpr_param_value qpv
           where qgr.report_name       in ('PS_CEMEA_VISA_BIN_PROGRAM')
             and qg.id                 = qgr.id
             and qpg.group_id(+)       = qg.id
             and qp.id(+)              = qpg.param_id
             and qpv.param_group_id(+) = qpg.id
             and qpv.id_param_value(+) = qpg.param_id
             and qpv.year(+)           = i_year
             and ceil(nvl(qpv.month_num(+), i_quarter * 3)/ 3) = i_quarter
             and qpv.inst_id(+)        = qpg.inst_id
             and nvl(qpg.priority,0)  != -1
           union all
          select 8 as sheet
               , qgr.report_name
               , qg.group_name
               , qp.param_name
               , sum(nvl(qpv.value_1, 0)) as param_value
               , null as param_value_2
               , null as param_value_3
               , null as param_value_4
               , null as param_value_5
               , null as param_value_6
               , null as param_value_7
               , null as param_value_8
               , null as param_value_9
               , null as param_value_10
               , null as col_header_1
               , null as col_header_2
               , null as col_header_3
               , null as col_header_4
               , null as col_header_5
               , null as col_header_6
               , null as col_header_7
               , null as col_header_8
               , null as col_header_9
               , null as col_header_10
               , qg.priority              as group_priority
               , qpg.priority             as param_priority
               , qp.id as param_id
            from qpr_group_report qgr
               , qpr_group qg
               , (select id, param_id, group_id, priority, inst_id
                    from qpr_param_group gp, inst) qpg
               , qpr_param qp
               , qpr_param_value qpv
           where qgr.report_name       in ('PS_CEMEA_VISA_PLUS')
             and qg.id                 = qgr.id
             and qpg.group_id(+)       = qg.id
             and qp.id(+)              = qpg.param_id
             and qpv.param_group_id(+) = qpg.id
             and qpv.id_param_value(+) = qpg.param_id
             and qpv.year(+)           = i_year
             and ceil(nvl(qpv.month_num(+), i_quarter * 3)/ 3) = i_quarter
             and qpv.inst_id(+)        = qpg.inst_id
             and nvl(qpg.priority,0)  != -1
           group by qgr.report_name
                  , qg.group_name
                  , qp.param_name
                  , qg.priority
                  , qpg.priority
                  , qp.id
         );

    --if no data
    if l_detail.getclobval() = '<table></table>' then
        select xmlelement("table"
                       , xmlagg(
                            xmlelement("record"
                                 , xmlelement( "sheet", null)
                                 , xmlelement( "report_name", null)
                                 , xmlelement( "group_name", null)
                                 , xmlelement( "param_name", null)
                                 , xmlelement( "param_value", null)
                            )
                         )
              )
        into l_detail from dual ;
    end if;

    select xmlelement ( "report"
             , l_header
             , l_detail
           )
    into l_result from dual;

    o_xml := l_result.getclobval();

    trc_log_pkg.debug ( i_text => 'qpr_api_report_pkg.vs_cemea - ok' );

exception when others then
    trc_log_pkg.debug ( i_text => sqlerrm );
    raise ;
end vs_cemea;

procedure vs_acquiring_cross_border(
    o_xml            out clob
  , i_lang           in  com_api_type_pkg.t_dict_value
  , i_year           in  com_api_type_pkg.t_tiny_id
  , i_quarter        in  com_api_type_pkg.t_sign
  , i_inst_id        in  com_api_type_pkg.t_inst_id)
is
    l_header           xmltype;
    l_detail           xmltype;
    l_result           xmltype;
    l_lang             com_api_type_pkg.t_dict_value;
    l_inst_id          com_api_type_pkg.t_inst_id;
begin
    trc_log_pkg.debug(
        i_text        => 'qpr_api_report_pkg.vs_acquiring_cross_border [#1][#2][#3][#4]'
      , i_env_param1  => i_lang
      , i_env_param2  => i_year
      , i_env_param3  => i_quarter
      , i_env_param4  => i_inst_id
    );

    l_lang    := nvl(i_lang, get_user_lang);
    l_inst_id := nvl(i_inst_id, 0);

    -- header
    select xmlelement( "header",
               xmlelement( "inst_name", com_api_i18n_pkg.get_text('OST_INSTITUTION','NAME', l_inst_id, l_lang))
           )
      into l_header
      from dual;

    -- details
    select xmlelement("table"
             , xmlagg(
                    xmlelement("record"
                      , xmlelement( "merchant_country", merchant_country)
                      , xmlelement( "country", country)
                      , xmlelement( "rn", rn)
                      , xmlelement( "group_name", group_name)
                      , xmlelement( "group_id", group_id)
                      , xmlelement( "param_name", param_name)
                      , xmlelement( "param_value_1", param_value_1)
                      , xmlelement( "param_value_2", param_value_2)
                    )
                  order by country
                         , group_priority
                         , param_priority
                )
           )
      into l_detail
      from(with
           inst as (
               select rownum as rn
                    , id as inst_id
                 from ost_institution i
              connect by prior id = parent_id
                start with id     = i_inst_id
           ),
           country_codes as (
               select c.country
                    , row_number() over (partition by 1 order by c.country) as rn
                 from(
               select distinct nvl(value_3, '000') as country
                 from qpr_param_value qpv
                where inst_id in (select id
                                    from ost_institution i
                                 connect by prior id = parent_id
                                   start with id     = i_inst_id)
                  and qpv.param_group_id in (2871, 2872, 2873, 2874, 2875)) c
           ),
           rep as (
               select qpv.value_3 as country_code
                    , qgr.report_name
                    , qg.group_name
                    , qg.id                       as group_id
                    , qp.param_name
                    , sum(nvl(qpv.value_1, 0))    as param_value_1
                    , sum(nvl(qpv.value_2, 0))    as param_value_2
                    , qg.priority                 as group_priority
                    , qpg.priority                as param_priority
                    , qp.id                       as param_id
                 from qpr_group_report qgr
                    , qpr_group qg
                    , (select id
                            , param_id
                            , group_id
                            , priority
                            , inst_id
                         from qpr_param_group gp, inst) qpg
                    , qpr_param qp
                    , qpr_param_value qpv
                where qgr.report_name       = vis_api_const_pkg.QUARTER_REPORT_CROSS_BORDER
                  and qg.id                 = qgr.id
                  and qpg.group_id(+)       = qg.id
                  and qp.id(+)              = qpg.param_id
                  and qpv.param_group_id(+) = qpg.id
                  and qpv.id_param_value(+) = qpg.param_id
                  and qpv.year(+)           = i_year
                  and ceil(nvl(qpv.month_num(+), i_quarter * 3) / 3) = i_quarter
                  and qpv.inst_id(+)        = qpg.inst_id
                  and nvl(qpg.priority,0)  != -1
                group by qpv.value_3
                       , qgr.report_name
                       , qg.group_name
                       , qg.id
                       , qp.param_name
                       , qg.priority
                       , qpg.priority
                       , qp.id)
           select (select com_api_i18n_pkg.get_text('COM_COUNTRY','NAME', cc.id, l_lang)
                     from com_country cc
                    where code = c.country) as merchant_country
                , c.country
                , (select cc.rn from country_codes cc where cc.country = c.country) as rn
                , qgr.report_name
                , qg.group_name
                , qg.id                       as group_id
                , qp.param_name
                , nvl((select param_value_1 from rep r
                        where r.group_name = qg.group_name
                          and r.param_name = qp.param_name
                          and nvl(r.country_code, '000') = c.country), 0) as param_value_1
                , nvl((select param_value_2 from rep r
                        where r.group_name = qg.group_name
                          and r.param_name = qp.param_name
                          and nvl(r.country_code, '000') = c.country), 0) as param_value_2
                , qg.priority                 as group_priority
                , qpg.priority                as param_priority
                , qp.id                       as param_id
             from country_codes c
                , qpr_group_report qgr
                , qpr_group qg
                , qpr_param qp
                , (select id, param_id, group_id, priority, inst_id
                     from qpr_param_group gp, inst) qpg
            where qgr.report_name       = vis_api_const_pkg.QUARTER_REPORT_CROSS_BORDER
              and qg.id                 = qgr.id
              and qpg.group_id(+)       = qg.id
              and qp.id(+)              = qpg.param_id
              and nvl(qpg.priority,0)  != -1
          );

    --if no data
    if l_detail.getclobval() = '<table></table>' then
        select xmlelement("table"
                 , xmlagg(
                       xmlelement("record"
                         , xmlelement( "merchant_country", null)
                         , xmlelement( "group_name", null)
                         , xmlelement( "group_id", null)
                         , xmlelement( "param_name", null)
                         , xmlelement( "param_value_1", null)
                         , xmlelement( "param_value_2", null)
                       )
                   )
               )
          into l_detail
          from dual;
    end if;

    select xmlelement( "report"
             , l_header
             , l_detail
           )
      into l_result from dual;

    o_xml := l_result.getclobval();

    trc_log_pkg.debug( i_text => 'qpr_api_report_pkg.vs_acquiring_cross_border - ok' );

exception when others then
    trc_log_pkg.debug(i_text => sqlerrm);
    raise;
end vs_acquiring_cross_border;

procedure vs_acquiring_bai(
    o_xml            out clob
  , i_lang           in  com_api_type_pkg.t_dict_value
  , i_year           in  com_api_type_pkg.t_tiny_id
  , i_quarter        in  com_api_type_pkg.t_sign
  , i_inst_id        in  com_api_type_pkg.t_inst_id)
is
    l_header           xmltype;
    l_detail           xmltype;
    l_result           xmltype;
    l_lang             com_api_type_pkg.t_dict_value;
    l_inst_id          com_api_type_pkg.t_inst_id;
    l_cmid             com_api_type_pkg.t_cmid;
    l_currency         com_api_type_pkg.t_curr_name;
begin
    trc_log_pkg.debug(
        i_text        => 'qpr_api_report_pkg.vs_acquiring_bai [#1][#2][#3][#4]'
      , i_env_param1  => i_lang
      , i_env_param2  => i_year
      , i_env_param3  => i_quarter
      , i_env_param4  => i_inst_id
    );

    l_lang    := nvl(i_lang, get_user_lang);
    l_inst_id := nvl(i_inst_id, 0);

    select max(nvl(v.cmid, '0000'))
         , max(nvl(c.name, com_api_currency_pkg.EURO))
      into l_cmid
         , l_currency
      from qpr_param_value v
         , (select id as inst_id
              from ost_institution i
              connect by prior id = parent_id
              start with id = i_inst_id
           ) inst
         , com_currency c
     where ceil(nvl(v.month_num, i_quarter*3) / 3) = i_quarter
       and v.year           = i_year
       and v.inst_id        = inst.inst_id
       and v.id_param_value = 2380
       and v.param_group_id = 2878
       and c.code           = v.curr_code;

    -- header
    select
        xmlconcat(
            xmlelement("year", i_year)
              , xmlelement("quarter", i_quarter)
              , xmlelement( "inst_name", com_api_i18n_pkg.get_text('OST_INSTITUTION','NAME', l_inst_id, l_lang))
              , xmlelement( "bid", l_cmid)
              , xmlelement( "currency", l_currency)
        )
    into
        l_header
    from dual;

    -- details
    select
        xmlelement("acquiring"
            , xmlagg(
                  xmlelement("param"
                    , xmlelement("group_id", group_id)
                    , xmlelement("group_desc", group_desc)
                    , xmlelement("param_id", param_id)
                    , xmlelement("param_desc", param_desc)
                    , xmlelement("year", i_year)
                    , xmlelement("month", to_char(dt, 'MONTH yyyy'))
                    , xmlelement("value_1", trim(to_char(nvl(value_1, 0), 'FM999999999999990')))
                    , xmlelement("value_2", trim(to_char(nvl(round(value_2), 0), 'FM999999999999990')))
                    , xmlelement("value_5", trim(to_char(nvl(value_5, 0), 'FM999999999999990')))
                    , xmlelement("value_6", trim(to_char(nvl(round(value_6), 0), 'FM999999999999990')))
                    , xmlelement("value_9", trim(to_char(nvl(value_9, 0), 'FM999999999999990')))
                    , xmlelement("value_10", trim(to_char(nvl(round(value_10), 0), 'FM999999999999990')))
                    , xmlelement("value_13", trim(to_char(nvl(value_13, 0), 'FM999999999999990')))
                    , xmlelement("value_14", trim(to_char(nvl(round(value_14), 0), 'FM999999999999990')))
                )
            )
        )
    into l_detail
    from (select v.*
               , case when v.month is not null then to_date('01' || lpad(v.month, 2, '0') || v.year, 'ddmmyyyy') end dt
            from (with
                  inst as (
                      select id as inst_id
                        from ost_institution i
                     connect by prior id = parent_id
                       start with id = i_inst_id)
                , mn as (
                      select i_quarter * 3 - level + 1 month_num
                        from dual
                     connect by level < 4)
                  select group_id
                       , group_desc
                       , param_id
                       , param_desc
                       , year
                       , month
                       , max(case when region = 'Total' then value_1 end) as value_1
                       , max(case when region = 'Total' then value_2 end) as value_2
                       , max(case when region = 'On Us' then value_1 end) as value_5
                       , max(case when region = 'On Us' then value_2 end) as value_6
                       , max(case when region = 'Intra' then value_1 end) as value_9
                       , max(case when region = 'Intra' then value_2 end) as value_10
                       , max(case when region = 'Inter' then value_1 end) as value_13
                       , max(case when region = 'Inter' then value_2 end) as value_14
                    from (select g.id          as group_id
                               , g.group_desc
                               , p.id          as param_id
                               , p.param_desc
                               , i_year as year
                               , gp.month_num  as month
                               , sum(nvl(v1.value_1, 0)) as value_1
                               , sum(nvl(v1.value_2, 0)) as value_2
                               , case grouping(gp.region)
                                     when 0 then gp.region
                                     else 'Total'
                                 end region
                            from qpr_group_report r
                               , qpr_group g
                               , (select id, param_id, group_id, priority, inst.inst_id, mn.month_num, r.region
                                    from qpr_param_group gp, inst, mn, (select 'On Us' region from dual union all select 'Intra' from dual union all select 'Inter' from dual) r
                               ) gp
                               , qpr_param p
                               , qpr_param_value v1
                           where r.report_name          = 'PS_VISA_ACQUIRING_BAI'
                             and g.id                   = r.id
                             and gp.group_id            = g.id
                             and p.id(+)                = gp.param_id
                             and v1.param_group_id(+)   = gp.id
                             and v1.id_param_value(+)   = gp.param_id
                             and v1.year(+)             = i_year
                             and v1.month_num(+)        = gp.month_num
                             and v1.inst_id(+)          = gp.inst_id
                             and v1.cmid(+)             = l_cmid
                             and v1.bin(+)              = gp.region
                             and nvl(gp.priority,0)     != -1
                           group by g.id
                                  , g.group_desc
                                  , p.id
                                  , p.param_desc
                                  , gp.month_num
                                  , rollup(gp.region)
                        )
                  group by group_id
                         , group_desc
                         , param_id
                         , param_desc
                         , year
                         , month
                 ) v
                 , qpr_group g
                 , qpr_param_group gp
            where g.id = v.group_id
              and gp.group_id = g.id
              and v.param_id(+) = gp.param_id
            order by g.priority
                   , v.month
                   , gp.priority
                   , v.param_id nulls first);

    --if no data
    if l_detail.getclobval() = '<acquiring></acquiring>' then
        select
            xmlelement("acquiring"
                , xmlagg(
                      xmlelement("param"
                        , xmlelement("group_id", null)
                        , xmlelement("group_desc", null)
                        , xmlelement("param_id", null)
                        , xmlelement("param_desc", null)
                        , xmlelement("year", null)
                        , xmlelement("month", null)
                        , xmlelement("value_1", null)
                        , xmlelement("value_2", null)
                        , xmlelement("value_5", null)
                        , xmlelement("value_6", null)
                        , xmlelement("value_9", null)
                        , xmlelement("value_10", null)
                        , xmlelement("value_13", null)
                        , xmlelement("value_14", null)
                    )
                )
            )
        into l_detail from dual ;
    end if;

    select xmlelement( "report"
             , l_header
             , l_detail
           )
      into l_result from dual;

    o_xml := l_result.getclobval();

    trc_log_pkg.debug( i_text => 'qpr_api_report_pkg.vs_acquiring_bai - ok' );

exception when others then
    trc_log_pkg.debug(i_text => sqlerrm);
    raise;
end vs_acquiring_bai;

----------------------------------------------------------

procedure monthly_report_by_network(
    o_xml              out clob
    , i_lang           in  com_api_type_pkg.t_dict_value
    , i_network_id     in  com_api_type_pkg.t_inst_id
    , i_start_date     in  date
    , i_end_date       in  date
    , i_dest_curr      in  com_api_type_pkg.t_curr_code
    , i_rate_type      in  com_api_type_pkg.t_dict_value
) is
    l_start_date                   date;
    l_end_date                     date;
    l_lang                         com_api_type_pkg.t_dict_value;
    l_header                       xmltype;
    l_detail                       xmltype;
    l_result                       xmltype;

begin
    trc_log_pkg.debug (
        i_text          => 'qpr_api_report_pkg.monthly_report_by_network [#1][#2][#3][#4]'
        , i_env_param1  => i_network_id
        , i_env_param2  => com_api_type_pkg.convert_to_char(trunc(nvl(i_start_date, com_api_sttl_day_pkg.get_sysdate)))
        , i_env_param3  => com_api_type_pkg.convert_to_char(nvl(trunc(i_end_date), l_start_date) + 1-com_api_const_pkg.ONE_SECOND)
    );

    l_lang := nvl(i_lang, get_user_lang);
    l_start_date := trunc(nvl(i_start_date, com_api_sttl_day_pkg.get_sysdate));
    l_end_date := nvl(trunc(i_end_date), l_start_date) + 1 - com_api_const_pkg.ONE_SECOND;

    -- header
    select
        xmlconcat(
            xmlelement("start_date", to_char(l_start_date, 'mm.yyyy'))
            , xmlelement("end_date", to_char(l_end_date, 'mm.yyyy'))
            , xmlelement("network_id", i_network_id)
            , xmlelement("network", com_api_i18n_pkg.get_text('net_network','name', i_network_id, l_lang))
        )
    into
        l_header
            from dual;

    -- details
    begin
        select
            xmlelement("amounts"
              , xmlagg(
                    xmlelement("transactions"
                      , xmlelement("transaction_type", transaction_type)
                      , xmlelement("settlement_intra", settlement_intra)
                      , xmlelement("count_transaction_intra", count_transaction_intra)
                      , xmlelement("amount_intra", trim(to_char(nvl(amount_intra,0),'FM999999999999990')))
                      , xmlelement("oper_date", to_char(period_month, 'mm.yyyy'))
                      , xmlelement("settlement_out", settlement_out)
                      , xmlelement("count_transaction_out", count_transaction_out)
                      , xmlelement("amount_out", trim(to_char(nvl(amount_out,0),'FM999999999999990')))
                      , xmlelement("settlement_us", settlement_us)
                      , xmlelement("count_transaction_us", count_transaction_us)
                      , xmlelement("amount_us", trim(to_char(nvl(amount_us,0),'FM999999999999990')))
                      , xmlelement("settlement_them", settlement_them)
                      , xmlelement("count_transaction_them", count_transaction_them)
                      , xmlelement("amount_them", trim(to_char(nvl(amount_them,0),'FM999999999999990')))
                      , xmlelement("total_transaction_intra", total_transaction_intra)
                      , xmlelement("total_amount_intra", trim(to_char(nvl(total_amount_intra,0),'FM999999999999990')))
                      , xmlelement("total_transaction_out", total_transaction_out)
                      , xmlelement("total_amount_out", trim(to_char(nvl(total_amount_out,0),'FM999999999999990')))
                      , xmlelement("total_transaction_us", total_transaction_us)
                      , xmlelement("total_amount_us", trim(to_char(nvl(total_amount_us,0),'FM999999999999990')))
                      , xmlelement("total_transaction_them", total_transaction_them)
                      , xmlelement("total_amount_them", trim(to_char(nvl(total_amount_them,0),'FM999999999999990')))
                      , xmlelement("rn", rn)
                    )
             order by period_month, transaction_type
                )
            )
        into
            l_detail
        from (
            with month_gap as (
                select period_month
                     , transaction_type
                     , settlement
                  from (
                        select add_months(trunc(l_start_date, 'mm'),rownum - 1) period_month
                          from dual
                          connect by rownum <= months_between(trunc(l_end_date, 'mm'), trunc(l_start_date, 'mm')) + 1
                      ) g
                      , (
                        select 'POS/Purchase' transaction_type from dual
                        union
                        select 'ATM/Cash' transaction_type from dual
                        union
                        select 'POB/Cash' transaction_type from dual
                      ) t
                      , (
                        select 'US-ON-THEM-OUT' settlement from dual
                        union
                        select 'US-ON-THEM-INTRA' settlement from dual
                        union
                        select 'US-ON-US' settlement from dual
                        union
                        select 'THEM-ON-US' settlement from dual
                      )
            )
            , trans as (
                select o.transaction_type
                     , settlement
                     , count(1) count_transaction
                     , sum (o.oper_amount) amount
                     , o.oper_date
                  from (
                    -- iss
                    select o.id
                         , o.oper_type
                         , case when o.oper_type in (opr_api_const_pkg.OPERATION_TYPE_PURCHASE, opr_api_const_pkg.OPERATION_TYPE_CASHBACK) then 'POS/Purchase'
                                when o.oper_type in (opr_api_const_pkg.OPERATION_TYPE_ATM_CASH, opr_api_const_pkg.OPERATION_TYPE_UNIQUE) then 'ATM/Cash'
                                when o.oper_type in (opr_api_const_pkg.OPERATION_TYPE_POS_CASH) then 'POB/Cash'
                           end transaction_type
                         , o.msg_type
                         , o.status
                         , o.sttl_type
                         , o.terminal_type
                         , o.merchant_country
                         , o.mcc
                         , trunc(o.oper_date, 'mm') oper_date
                         , trunc(o.host_date, 'mm') host_date
                         --, o.oper_amount/power(10,cur.exponent) as oper_amount
                         , decode(o.oper_currency, i_dest_curr, o.oper_amount, com_api_rate_pkg.convert_amount (
                                                                                      o.oper_amount
                                                                                    , o.oper_currency
                                                                                    , i_dest_curr
                                                                                    , i_rate_type
                                                                                    , iss.inst_id
                                                                                    , o.oper_date
                                                                                    , 1
                                                                                    , null
                                                                                  )
                         ) / power(10,cur.exponent) oper_amount
                         , i_dest_curr
                         , iss.inst_id iss_inst_id
                         , iss.network_id iss_network_id
                         , iss.card_id
                         , iss.card_expir_date
                         , iss.card_country
                         , iss.card_network_id
                         , iss.card_inst_id
                         , iss.card_type_id
                         , acq.inst_id acq_inst_id
                         , acq.network_id acq_network_id
                         , acq.terminal_id
                         , acq.merchant_id
                         , case when sttl_type = opr_api_const_pkg.SETTLEMENT_USONUS then 'US-ON-US'
                                when iss.card_country != o.merchant_country then 'US-ON-THEM-OUT'
                                when iss.card_country  = o.merchant_country then 'US-ON-THEM-INTRA'
                                else 'US-ON-US'
                           end settlement
                      from opr_operation o
                         , opr_participant iss
                         , opr_participant acq
                         , com_currency cur
                     where iss.oper_id          = o.id
                       and iss.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
                       and acq.oper_id          = o.id
                       and acq.participant_type = com_api_const_pkg.PARTICIPANT_ACQUIRER
                       --and o.oper_currency      = cur.code
                       and cur.code             = i_dest_curr
                       and o.oper_type in (opr_api_const_pkg.OPERATION_TYPE_PURCHASE
                                         , opr_api_const_pkg.OPERATION_TYPE_CASHBACK
                                         , opr_api_const_pkg.OPERATION_TYPE_ATM_CASH
                                         , opr_api_const_pkg.OPERATION_TYPE_UNIQUE
                                         , opr_api_const_pkg.OPERATION_TYPE_POS_CASH)
                       and o.status in (opr_api_const_pkg.OPERATION_STATUS_PROCESSED, opr_api_const_pkg.OPERATION_STATUS_AWAITS_UNHOLD)
                       and iss.card_network_id = i_network_id
                       and trunc(o.oper_date) between trunc(l_start_date, 'mm') and trunc(add_months(l_end_date, 1), 'mm')
                       and o.sttl_type in (select element_value from com_array_element where array_id = 10000012)
                union all
                    -- acq
                    select o.id
                         , o.oper_type
                         , case when o.oper_type in (opr_api_const_pkg.OPERATION_TYPE_PURCHASE, opr_api_const_pkg.OPERATION_TYPE_CASHBACK) then 'POS/Purchase'
                                when o.oper_type in (opr_api_const_pkg.OPERATION_TYPE_ATM_CASH, opr_api_const_pkg.OPERATION_TYPE_UNIQUE) then 'ATM/Cash'
                                when o.oper_type in (opr_api_const_pkg.OPERATION_TYPE_POS_CASH) then 'POB/Cash'
                           end transaction_type
                         , o.msg_type
                         , o.status
                         , o.sttl_type
                         , o.terminal_type
                         , o.merchant_country
                         , o.mcc
                         , trunc(o.oper_date, 'mm') oper_date
                         , trunc(o.host_date, 'mm') host_date
                         --, o.oper_amount/power(10,cur.exponent) as oper_amount
                         , decode(o.oper_currency, i_dest_curr, o.oper_amount, com_api_rate_pkg.convert_amount (
                                                                                      o.oper_amount
                                                                                    , o.oper_currency
                                                                                    , i_dest_curr
                                                                                    , i_rate_type
                                                                                    , iss.inst_id
                                                                                    , o.oper_date
                                                                                    , 1
                                                                                    , null
                                                                                  )
                         ) / power(10,cur.exponent) oper_amount
                         , i_dest_curr
                         , iss.inst_id iss_inst_id
                         , iss.network_id iss_network_id
                         , iss.card_id
                         , iss.card_expir_date
                         , iss.card_country
                         , iss.card_network_id
                         , iss.card_inst_id
                         , iss.card_type_id
                         , acq.inst_id acq_inst_id
                         , acq.network_id acq_network_id
                         , acq.terminal_id
                         , acq.merchant_id
                         , 'THEM-ON-US' settlement
                      from opr_operation o
                         , opr_participant iss
                         , opr_participant acq
                         , com_currency cur
                     where iss.oper_id          = o.id
                       and iss.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
                       and acq.oper_id          = o.id
                       and acq.participant_type = com_api_const_pkg.PARTICIPANT_ACQUIRER
                       --and o.oper_currency      = cur.code
                       and cur.code             = i_dest_curr
                       and o.oper_type in (opr_api_const_pkg.OPERATION_TYPE_PURCHASE
                                         , opr_api_const_pkg.OPERATION_TYPE_CASHBACK
                                         , opr_api_const_pkg.OPERATION_TYPE_ATM_CASH
                                         , opr_api_const_pkg.OPERATION_TYPE_UNIQUE
                                         , opr_api_const_pkg.OPERATION_TYPE_POS_CASH)
                       and o.status in (opr_api_const_pkg.OPERATION_STATUS_PROCESSED, opr_api_const_pkg.OPERATION_STATUS_AWAITS_UNHOLD)
                       and iss.card_network_id = i_network_id
                       and trunc(o.oper_date) between trunc(l_start_date, 'mm') and trunc(add_months(l_end_date, 1), 'mm')
                       and o.sttl_type in (select element_value from com_array_element where array_id = 10000013)
                ) o
                group by o.transaction_type
                     , settlement
                     , o.oper_date
            )
            select g1.transaction_type
                 , g1.settlement settlement_intra
                 , nvl(t1.count_transaction, 0) count_transaction_intra
                 , nvl(t1.amount, 0) amount_intra
                 , g1.period_month
                 , g2.settlement settlement_out
                 , nvl(t2.count_transaction, 0) count_transaction_out
                 , nvl(t2.amount, 0) amount_out
                 , g3.settlement settlement_us
                 , nvl(t3.count_transaction, 0) count_transaction_us
                 , nvl(t3.amount, 0) amount_us
                 , g4.settlement settlement_them
                 , nvl(t4.count_transaction, 0) count_transaction_them
                 , nvl(t4.amount, 0) amount_them
                 , sum(nvl(t1.count_transaction, 0)) over() total_transaction_intra
                 , sum(nvl(t1.amount, 0)) over() total_amount_intra
                 , sum(nvl(t2.count_transaction, 0)) over() total_transaction_out
                 , sum(nvl(t2.amount, 0)) over() total_amount_out
                 , sum(nvl(t3.count_transaction, 0)) over() total_transaction_us
                 , sum(nvl(t3.amount, 0)) over() total_amount_us
                 , sum(nvl(t4.count_transaction, 0)) over() total_transaction_them
                 , sum(nvl(t4.amount, 0)) over() total_amount_them
                 , row_number() over(partition by g1.period_month order by g1.period_month) rn
              from month_gap g1
                 , month_gap g2
                 , month_gap g3
                 , month_gap g4
                 , trans t1
                 , trans t2
                 , trans t3
                 , trans t4
             where g1.period_month      = t1.oper_date(+)
               and g1.transaction_type  = t1.transaction_type(+)
               and g1.settlement        = t1.settlement(+)
               and g1.settlement        = 'US-ON-THEM-INTRA'
               and g2.period_month      = t2.oper_date(+)
               and g2.transaction_type  = t2.transaction_type(+)
               and g2.settlement        = t2.settlement(+)
               and g2.settlement        = 'US-ON-THEM-OUT'
               and g3.period_month      = t3.oper_date(+)
               and g3.transaction_type  = t3.transaction_type(+)
               and g3.settlement        = t3.settlement(+)
               and g3.settlement        = 'US-ON-US'
               and g4.period_month      = t4.oper_date(+)
               and g4.transaction_type  = t4.transaction_type(+)
               and g4.settlement        = t4.settlement(+)
               and g4.settlement        = 'THEM-ON-US'
               and g1.period_month      = g2.period_month
               and g1.period_month      = g3.period_month
               and g1.period_month      = g4.period_month
               and g1.transaction_type  = g2.transaction_type
               and g1.transaction_type  = g3.transaction_type
               and g1.transaction_type  = g4.transaction_type
             order by g1.period_month
                    , g1.transaction_type
                    , g1.settlement
        );

        select
            xmlelement (
                "report"
                , l_header
                , l_detail
            ) r
        into
            l_result
        from
            dual;

        o_xml := l_result.getclobval();


    exception
        when no_data_found then
            select
                xmlelement("report", '')
            into
                l_detail
            from
                dual;

            trc_log_pkg.debug (
                i_text  => 'Records not found'
            );
    end;

    select
        xmlelement (
            "report"
            , l_header
            , l_detail
        ) r
    into
        l_result
    from
        dual;

    o_xml := l_result.getclobval();

    --dbms_output.put_line(o_xml);
    trc_log_pkg.debug (
         i_text => 'qpr_api_report_pkg.monthly_report_by_network - ok'
    );
end;

end qpr_api_report_pkg;
/
