create or replace package body rcn_api_report_pkg is

procedure reconciliation_report(
    o_xml              out clob
  , i_recon_type    in     com_api_type_pkg.t_dict_value    default rcn_api_const_pkg.RECON_TYPE_COMMON
  , i_start_date    in     date
  , i_end_date      in     date
  , i_lang          in     com_api_type_pkg.t_dict_value
  , i_inst_id       in     com_api_type_pkg.t_tiny_id
) is
    l_start_date           date;
    l_end_date             date;
    l_lang                 com_api_type_pkg.t_dict_value;
    l_inst_id              com_api_type_pkg.t_tiny_id;

    l_header               xmltype;
    l_detail               xmltype;
    l_result               xmltype;
begin
    trc_log_pkg.debug (
        i_text          => 'CBS Reconciliation report [#1][#2][#3]'
      , i_env_param1    => com_api_type_pkg.convert_to_char(trunc(nvl(i_start_date, trunc(com_api_sttl_day_pkg.get_sysdate) - 1)))
      , i_env_param2    => com_api_type_pkg.convert_to_char(nvl(trunc(i_end_date), trunc(com_api_sttl_day_pkg.get_sysdate) - com_api_const_pkg.ONE_SECOND))
      , i_env_param3    => nvl(i_lang, get_user_lang)
    );

    l_lang := nvl(i_lang, get_user_lang);
    l_start_date := nvl(i_start_date, trunc(com_api_sttl_day_pkg.get_sysdate) - 1);
    l_end_date := nvl(i_end_date, trunc(com_api_sttl_day_pkg.get_sysdate) - com_api_const_pkg.ONE_SECOND);
    l_inst_id := nvl(i_inst_id, rcn_api_const_pkg.PROCESSING_INST);

    -- header
    select xmlelement(
               "header"
             , xmlelement("inst_id", l_inst_id || ' - ' 
                       || com_api_i18n_pkg.get_text('OST_INSTITUTION','NAME', l_inst_id, l_lang)
               )
             , xmlelement("recon_type" , i_recon_type || ' - ' 
                       || com_api_dictionary_pkg.get_article_text(
                              i_article => i_recon_type
                            , i_lang    => l_lang
                          )
               )
             , xmlelement("date_start", to_char(l_start_date, 'dd.mm.yyyy hh24:mi:ss'))
             , xmlelement("date_end", to_char(l_end_date, 'dd.mm.yyyy hh24:mi:ss'))
           )
      into l_header
      from dual;

    -- detail
     select xmlelement(
               "details"
             , xmlagg(
                   xmlelement(
                       "detail"
                     , xmlelement("recon_status", recon_status || ' - ' 
                                               || com_api_dictionary_pkg.get_article_text(
                                                      i_article => recon_status
                                                    , i_lang    => l_lang
                                                  )
                       )
                     , xmlelement("msg_type", com_api_dictionary_pkg.get_article_text(
                                                  i_article => msg_type
                                                , i_lang    => l_lang
                                              )
                       )
                     , xmlelement("oper_type", com_api_dictionary_pkg.get_article_text(
                                                   i_article => oper_type
                                                 , i_lang    => l_lang
                                               )
                       )
                     , xmlelement("is_reversal", decode(is_reversal, 0, 'not reversal', 'reversal'))
                     , xmlelement("msg_count", msg_count)
                   )
               )
            )
       into l_detail
      from (
            select m.recon_status
                 , m.msg_type
                 , m.oper_type
                 , m.is_reversal
                 , count(*) as msg_count
              from rcn_cbs_msg m
             where m.recon_status != rcn_api_const_pkg.RECON_STATUS_REQ_RECON
               and m.msg_source = rcn_api_const_pkg.RECON_MSG_SOURCE_CBS
               and m.recon_inst_id = l_inst_id
               and m.recon_type = i_recon_type
               and m.recon_date between l_start_date and l_end_date
          group by m.recon_status
                 , m.msg_type
                 , m.oper_type
                 , m.is_reversal
          order by m.recon_status
      );    

    --if no data
    if l_detail.getclobval() = '<details></details>' then
        select xmlelement(
                   "details"
                 , xmlagg(
                       xmlelement(
                           "detail"
                         , xmlelement("recon_status", null)
                         , xmlelement("msg_type", null)
                         , xmlelement("oper_type", null)
                         , xmlelement("is_reversal", null)
                         , xmlelement("msg_count", null)
                       )
                   )
               )
        into l_detail
        from dual;
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
         i_text => 'CBS Reconciliation report - ok'
    );
         
exception
    when no_data_found then
        trc_log_pkg.debug (
            i_text  => 'No data found'
        );
end;


procedure atm_reconcilation_statistic(
    o_xml            out clob
  , i_lang        in     com_api_type_pkg.t_dict_value
  , i_inst_id     in     com_api_type_pkg.t_inst_id default null
  , i_start_date  in     date default null
  , i_end_date    in     date default null
) is
    l_header               xmltype;
    l_detail               xmltype;
    l_result               xmltype;
    l_start_date           date;
    l_end_date             date;
    l_inst                 com_api_type_pkg.t_name;
    l_lang                 com_api_type_pkg.t_name;
begin
    l_lang := nvl(i_lang, get_user_lang);
    l_start_date := nvl(i_start_date, trunc(com_api_sttl_day_pkg.get_sysdate) - 1);      

    l_end_date := nvl(i_end_date, trunc(com_api_sttl_day_pkg.get_sysdate)- interval '1' second);
        
    trc_log_pkg.debug(
        i_text        => 'Run statement report [#1] [#2] [#3] [#4]'
      , i_env_param1  => l_lang
      , i_env_param2  => i_inst_id
      , i_env_param3  => i_start_date
      , i_env_param4  => i_end_date
    );

    if i_inst_id is not null then
        l_inst := com_api_i18n_pkg.get_text(
                      i_table_name   => 'OST_INSTITUTION'
                    , i_column_name  => 'NAME'
                    , i_object_id    => i_inst_id
                    , i_lang         => l_lang
                  );
    else
        l_inst := 'All acquiring institutions';
    end if;
    -- header
    select xmlconcat(
               xmlelement("header"
                 , xmlelement("inst", l_inst)
                 , xmlelement("start_date", to_char(l_start_date, 'dd.mm.yyyy hh24:mi:ss'))
                 , xmlelement("end_date",   to_char(l_end_date,   'dd.mm.yyyy hh24:mi:ss'))
               )
           )
      into l_header
      from dual;

    select xmlelement("details",
               nvl(xmlagg(
                       xmlelement(
                           "detail"
                         , xmlelement("rcn_status", recon_status || ' - ' || get_article_text(i_article => recon_status, i_lang => l_lang))
                         , xmlelement("rcn_count", count(1))
                       )
                       order by recon_status
                   )
                 , xmlelement("detail")
               )
           )
      into l_detail
      from rcn_atm_msg m
     where m.msg_source = rcn_api_const_pkg.RECON_MSG_SOURCE_ATM_EJOURNAL
       and m.msg_date >= l_start_date
       and m.msg_date <= l_end_date
  group by recon_status;

    select xmlelement(
              "report"
             , l_header
             , l_detail
           ) r
      into l_result
      from dual;

    o_xml := l_result.getclobval();

    trc_log_pkg.debug(
        i_text => 'cst_lvp_report_pkg.card_inventory - ok'
    );

exception 
    when others then
        trc_log_pkg.debug(i_text => sqlerrm);
        raise;
end atm_reconcilation_statistic;

procedure host_reconcilation_statistic(
    o_xml            out clob
  , i_recon_type  in     com_api_type_pkg.t_dict_value    default rcn_api_const_pkg.RECON_TYPE_COMMON
  , i_inst_id     in     com_api_type_pkg.t_inst_id
  , i_date_start  in     date
  , i_date_end    in     date
  , i_lang        in     com_api_type_pkg.t_dict_value
) is
    l_date_start        date := i_date_start;
    l_date_end          date := i_date_end;
    l_lang              com_api_type_pkg.t_dict_value;

    l_header            xmltype;
    l_detail            xmltype;
    l_result            xmltype;
begin
    l_lang       := nvl(i_lang, get_user_lang);

    if l_date_end is null and l_date_start is null then
        l_date_end   := trunc(com_api_sttl_day_pkg.get_sysdate) - interval '1' second;
    end if;
    
    if l_date_start is null  and l_date_end is not null then
        l_date_start := trunc(l_date_end);
    end if;
    
    trc_log_pkg.debug (
              i_text        => 'rcn_api_report_pkg.host_reconcilation_statistic [#1][#2][#3][#4][#5]'
            , i_env_param1  => i_recon_type
            , i_env_param2  => i_lang
            , i_env_param3  => i_inst_id
            , i_env_param4  => to_char(l_date_start, 'dd.mm.yyyy hh24:mi:ss')
            , i_env_param5  => to_char(l_date_end, 'dd.mm.yyyy hh24:mi:ss')
    );

    -- header
    select xmlelement(
               "header"
             , xmlelement("p_date_start" , to_char(l_date_start, 'dd.mm.yyyy'))
             , xmlelement("p_date_end"   , to_char(l_date_end, 'dd.mm.yyyy'))
             , xmlelement("p_inst"       , decode (i_inst_id, null, 'All'
                                                   ,i_inst_id || ' - ' || get_text('OST_INSTITUTION','NAME', i_inst_id, l_lang))
                         )
             , xmlelement("p_recon_type" , i_recon_type)
             , xmlelement("p_recon_description" , get_article_text(i_recon_type, i_lang))
           )
      into l_header
      from dual;

     select xmlelement(
               "details"
             , xmlagg(
                   xmlelement(
                       "detail"
                     , xmlelement("recon_status"  , m.recon_status || ' - ' || get_article_text(m.recon_status, l_lang) )
                     , xmlelement("msg_type"      , get_article_text(m.msg_type, l_lang) )
                     , xmlelement("oper_type"     , get_article_text(m.oper_type, l_lang) )
                     , xmlelement("reversal_sign" , decode(m.is_reversal, 1, 'Reversal', 0, 'Not reversal'))
                     , xmlelement("oper_count"    , 1)
                   )
              order by m.recon_status
                     , m.msg_type
                     , m.oper_type
                     , m.is_reversal
               )
            )
       into l_detail
       from rcn_host_msg m
      where m.recon_type = nvl(i_recon_type, rcn_api_const_pkg.RECON_TYPE_HOST)
        and m.msg_date between l_date_start and l_date_end
   order by m.recon_status, msg_type
         ;

    --if no data
    if l_detail.getclobval() = '<details></details>' then
        select xmlelement(
                   "details"
                 , xmlagg(
                       xmlelement(
                           "detail"
                         , xmlelement("recon_status"  , null)
                         , xmlelement("msg_type"      , null)
                         , xmlelement("oper_type"     , null)
                         , xmlelement("reversal_sign" , null)
                         , xmlelement("oper_count"    , null)
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
        i_text => 'rcn_api_report_pkg.host_reconcilation_statistic - ok'
    );

exception when others then
    trc_log_pkg.debug(i_text => sqlerrm);
    raise ;
end;

procedure srvp_reconcilation_statistic(
    o_xml              out clob
  , i_recon_type    in     com_api_type_pkg.t_dict_value    default rcn_api_const_pkg.RECON_TYPE_SRVP
  , i_start_date    in     date
  , i_end_date      in     date
  , i_lang          in     com_api_type_pkg.t_dict_value    default null
  , i_inst_id       in     com_api_type_pkg.t_tiny_id
  , i_recon_status  in     com_api_type_pkg.t_dict_value    default null
) is
    l_start_date           date;
    l_end_date             date;
    l_lang                 com_api_type_pkg.t_dict_value;
    l_inst_id              com_api_type_pkg.t_tiny_id;
    l_recon_type           com_api_type_pkg.t_dict_value;

    l_header               xmltype;
    l_detail               xmltype;
    l_result               xmltype;
begin

    l_recon_type        := nvl(i_recon_type, rcn_api_const_pkg.RECON_TYPE_SRVP);
    l_start_date        := trunc(nvl(i_start_date, trunc(com_api_sttl_day_pkg.get_sysdate) - 1));
    l_end_date          := nvl(trunc(i_end_date), trunc(com_api_sttl_day_pkg.get_sysdate) - com_api_const_pkg.ONE_SECOND);
    l_lang              := nvl(i_lang, get_user_lang);
    l_inst_id           := nvl(i_inst_id, rcn_api_const_pkg.PROCESSING_INST);

    trc_log_pkg.debug (
        i_text          => 'Service provider reconciliation statistic report l_start_date [#1], l_end_date [#2], l_lang [#3], l_inst_id [#4], l_recon_type [#5]'
      , i_env_param1    => l_start_date
      , i_env_param2    => l_end_date
      , i_env_param3    => l_lang
      , i_env_param4    => l_inst_id
      , i_env_param5    => l_recon_type
    );

    -- header
    select xmlelement(
               "header"
             , xmlelement("inst_id", l_inst_id || ' - ' 
                       || com_api_i18n_pkg.get_text('ost_institution','name', l_inst_id, l_lang)
               )
             , xmlelement("recon_type" , i_recon_type || ' - ' 
                       || com_api_dictionary_pkg.get_article_text(
                              i_article => i_recon_type
                            , i_lang    => l_lang
                          )
               )
             , xmlelement("date_start", to_char(l_start_date, 'dd.mm.yyyy hh24:mi:ss'))
             , xmlelement("date_end", to_char(l_end_date, 'dd.mm.yyyy hh24:mi:ss'))
           )
      into l_header
      from dual;

    -- detail
     select xmlelement(
               "details"
             , xmlagg(
                   xmlelement(
                       "detail"
                     , xmlelement("recon_status",   recon_status || ' - ' ||
                                                    com_api_dictionary_pkg.get_article_text(
                                                        i_article => r.recon_status
                                                      , i_lang    => l_lang
                                                    )
                       )
                     , xmlelement("provider_name",  com_api_i18n_pkg.get_text(
                                                        i_table_name  => 'pmo_provider'
                                                      , i_column_name => 'label'
                                                      , i_object_id   => r.provider_id
                                                      , i_lang        => l_lang
                                                    )
                       )
                     , xmlelement("purpose_name",   com_api_i18n_pkg.get_text(
                                                        i_table_name  => 'pmo_service'
                                                      , i_column_name => 'label'
                                                      , i_object_id   => r.purpose_id
                                                      , i_lang        => l_lang
                                                    )
                       )
                     , xmlelement("status_count", status_count)
                   )
               )
            )
       into l_detail
      from (
            select count(1) as status_count
                 , m.recon_status
                 , m.provider_id
                 , m.purpose_id
              from rcn_srvp_msg m
             where 1 = 1
               and (
                    m.recon_status = i_recon_status
                    or i_recon_status is null
                   )
               and m.msg_source     = rcn_api_const_pkg.RECON_MSG_SOURCE_SRVP
               and m.inst_id        = l_inst_id
               and m.recon_type     = l_recon_type
               and m.recon_date     between l_start_date
                                        and l_end_date
            group by 
                   m.recon_status
                 , m.provider_id
                 , m.purpose_id
            order by
                   m.recon_status
      ) r;

    --if no data
    if l_detail.getclobval() = '<details></details>' then
        select xmlelement(
                   "details"
                 , xmlagg(
                       xmlelement(
                           "detail"
                         , xmlelement("recon_status", null)
                         , xmlelement("provider_name", null)
                         , xmlelement("purpose_name", null)
                         , xmlelement("status_count", null)
                       )
                   )
               )
        into l_detail
        from dual;
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
         i_text => 'Service provider reconciliation statistic report - ok'
    );

exception
    when no_data_found then
        trc_log_pkg.debug (
            i_text  => 'No data found'
        );
end srvp_reconcilation_statistic;

end rcn_api_report_pkg;
/
