create or replace package body cst_lvp_report_pkg as

procedure card_inventory(
    o_xml                  out clob
  , i_inst_id           in     com_api_type_pkg.t_inst_id       default null
  , i_date_start        in     date                             default null
  , i_date_end          in     date                             default null
  , i_report_id         in     com_api_type_pkg.t_short_id
  , i_lang              in     com_api_type_pkg.t_dict_value    default null
) is
    l_date_start        date := i_date_start;
    l_date_end          date := i_date_end;
    l_lang              com_api_type_pkg.t_dict_value;

    l_header            xmltype;
    l_detail            xmltype;
    l_result            xmltype;

begin

    l_lang       := nvl(i_lang, get_user_lang);

    if l_date_start is null then
        begin
            select start_date
              into l_date_start
              from
            (
                select r.start_date + interval '1' second as start_date
                  from rpt_run r
                  where report_id = nvl(i_report_id, -50000018)
                  order by r.start_date desc
            )
            where rownum = 1;
        exception when no_data_found then
            l_date_start := com_api_sttl_day_pkg.get_sysdate - 1;
        end;
    end if;

    if l_date_end is null then
        l_date_end   := com_api_sttl_day_pkg.get_sysdate - interval '1' second;
    end if;

    trc_log_pkg.debug (
              i_text        => 'cst_lvp_report_pkg.card_inventory [#1][#2][#3][#4]'
            , i_env_param1  => i_lang
            , i_env_param2  => i_inst_id
            , i_env_param3  => to_char(l_date_start, 'dd.mm.yyyy hh24:mi:ss')
            , i_env_param4  => to_char(l_date_end, 'dd.mm.yyyy hh24:mi:ss')
    );

    -- header
    select xmlelement(
               "header"
             , xmlelement("p_date_start" , to_char(l_date_start, 'dd/mm/yyyy'))
             , xmlelement("p_date_end"   , to_char(l_date_end, 'dd/mm/yyyy'))
             , xmlelement("p_inst_id"    , decode (i_inst_id, null, 'All'
                                                   ,i_inst_id || ' - ' || get_text('OST_INSTITUTION','NAME', i_inst_id, l_lang))
                         )
           )
      into l_header
      from dual;

     select xmlelement(
               "details"
             , xmlagg(
                   xmlelement(
                       "detail"
                     , xmlelement("blank_type"  , nvl(get_text('PRS_BLANK_TYPE','NAME', l.blank_type_id, l_lang), 'Undefined card blanks'))
                     , xmlelement("agent"       , decode(a.id, null, null, a.agent_number || ' - ' || get_text('OST_AGENT','NAME', l.agent_id, l_lang)))
                     , xmlelement("inst_id"     , decode(l.inst_id, null, null, l.inst_id || ' - ' || get_text('OST_INSTITUTION','NAME', l.inst_id, l_lang)))
                     , xmlelement("card_cnt"    , to_char(l.card_cnt))
                   )
               )
            )
       into l_detail
       from (
            select blank_type_id, agent_id, inst_id, count(*) as card_cnt
            from (
                select nvl(i.blank_type_id
                        , nvl((select min(t.blank_type_id)
                                 from iss_card c, iss_product_card_type t
                                where i.blank_type_id is null
                                  and c.id = i.card_id
                                  and t.card_type_id = c.card_type_id
                                  and t.blank_type_id is not null
                              )
                             ,(select min(b.id)
                                 from iss_card c
                                 join prs_blank_type b on c.card_type_id = b.card_type_id
                                where c.id = i.card_id
                              )
                             )
                            ) as blank_type_id 
                     , i.agent_id
                     , i.inst_id
                  from iss_card_instance i
                 where i.state in (iss_api_const_pkg.CARD_STATE_ACTIVE, iss_api_const_pkg.CARD_STATE_DELIVERED)
                   and i.iss_date between l_date_start and l_date_end
                 ) a
            group by blank_type_id, agent_id, inst_id
       ) l, ost_agent a
     where l.agent_id = a.id(+);

    --if no data
    if l_detail.getclobval() = '<details></details>' then
        select xmlelement(
                   "details"
                 , xmlagg(
                       xmlelement(
                           "detail"
                         , xmlelement("blank_type"  , null)
                         , xmlelement("agent"       , null)
                         , xmlelement("inst_id"     , null)
                         , xmlelement("card_cnt"    , null)
                       )
                   )
               )
        into l_detail
        from dual;
    end if;

    select xmlelement(
               "report"
             , l_header
             , l_detail
           )
    into l_result
    from dual;

    o_xml := l_result.getclobval();

    trc_log_pkg.debug(
        i_text => 'cst_lvp_report_pkg.card_inventory - ok'
    );

exception when others then
    trc_log_pkg.debug(i_text => sqlerrm);
    raise ;
end;

end;
/
