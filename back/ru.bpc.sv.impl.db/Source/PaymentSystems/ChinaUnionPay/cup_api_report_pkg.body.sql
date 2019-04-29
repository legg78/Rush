create or replace package body cup_api_report_pkg as

procedure audit_trailer_data_matching(
    o_xml                     out  clob
  , i_inst_id                  in  com_api_type_pkg.t_inst_id
  , i_lang                     in  com_api_type_pkg.t_dict_value   default null
  , i_audit_trailer_file_id    in  com_api_type_pkg.t_long_id      default null
  , i_start_date               in  date                            default null
  , i_end_date                 in  date                            default null
  , i_match_status             in  com_api_type_pkg.t_dict_value
) is
    LOG_PREFIX  constant    com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.audit_trailer_data_matching: ';
    
    l_from_id               com_api_type_pkg.t_long_id;
    l_till_id               com_api_type_pkg.t_long_id;
    
    l_eff_date              date;
begin
    trc_log_pkg.debug(
        i_text        => LOG_PREFIX || 'Run with params inst_id [#1] lang [#2] audit_trailer_file_id [#3] start_date [#4] end_date [#5] match_status [#6]'
      , i_env_param1  => i_inst_id
      , i_env_param2  => i_lang
      , i_env_param3  => i_audit_trailer_file_id
      , i_env_param4  => i_start_date
      , i_env_param5  => i_end_date
      , i_env_param6  => i_match_status
    );
    l_eff_date := com_api_sttl_day_pkg.get_sysdate;
    l_from_id  := coalesce(
                      i_audit_trailer_file_id
                    , case 
                          when i_start_date is null
                              then null
                          else com_api_id_pkg.get_from_id(i_date => i_start_date)
                      end
                  );
    l_till_id  := coalesce(
                      i_audit_trailer_file_id
                    , case
                          when i_end_date is null
                              then null
                          else com_api_id_pkg.get_till_id(i_date => i_end_date)
                      end
                  );
                  
    with detail_data as(
    select cu.file_id
         , cu.rrn
         , cu.trans_currency
         , tc.name           as trans_curr_name
         , tc.exponent       as trans_curr_exp
         , cu.trans_amount
         , cu.sttl_currency
         , sc.name           as sttl_curr_name
         , sc.exponent       as sttl_curr_exp
         , cu.sttl_amount
         , iss_api_card_pkg.get_card_mask(
               i_card_number => cc.card_number
           )                 as card_mask
      from cup_audit_trailer cu
         , cup_card cc
         , com_currency tc
         , com_currency sc
     where cu.file_id between l_from_id and l_till_id
       and cu.match_status = i_match_status
       and cu.inst_id      = i_inst_id
       and cc.id           = cu.fin_msg_id
       and tc.code         = cu.trans_currency
       and sc.code         = cu.sttl_currency
    )
    select xmlelement("audit_trailer_data"
               , xmlconcat(
                     xmlelement("inst_name",             com_api_i18n_pkg.get_text(
                                                             i_table_name    => 'OST_INSTITUTION'
                                                           , i_column_name   => 'NAME'
                                                           , i_object_id     => i_inst_id
                                                           , i_lang          => i_lang
                                                         )
                     )
                   , xmlelement("input_audit_file_id",   to_char(i_audit_trailer_file_id))
                   , xmlelement("eff_date",              to_char(l_eff_date, com_api_const_pkg.XML_DATETIME_FORMAT))
                   , xmlelement("start_date",            nvl2(i_audit_trailer_file_id, null, to_char(i_start_date, com_api_const_pkg.XML_DATE_FORMAT)))
                   , xmlelement("end_date",              nvl2(i_audit_trailer_file_id, null, to_char(i_end_date, com_api_const_pkg.XML_DATE_FORMAT)))
                   , (select xmlelement("processed_files"
                               , xmlagg(xmlelement("file"
                                          , xmlforest(
                                                sf.id                                                    "file_id"
                                              , sf.file_name                                             "file_name"
                                              , to_char(sf.file_date, com_api_const_pkg.XML_DATE_FORMAT) "file_date"
                                            )
                                        ) order by sf.id
                                 )
                             )
                        from prc_session_file sf
                       where sf.id between l_from_id and l_till_id
                         and exists(select 1
                                      from detail_data dd
                                     where dd.file_id = sf.id
                             )
                     )
                   , rez
                   , (select xmlelement("totals"
                               , xmlagg(xmlelement("total"
                                          , xmlforest(
                                                trans_currency      "trans_currency"
                                              , trans_curr_name     "trans_curr_name"
                                              , trans_amount        "total_trans_amount"
                                              , trans_count         "total_trans_count"
                                              , trans_amount_format "trans_amount_format"
                                              , trans_curr_exp      "trans_curr_exp"
                                            ) 
                                        ) order by trans_currency
                                 )
                             )
                        from (
                              select dd.trans_currency
                                   , dd.trans_curr_name
                                   , '###0.' || lpad('0', greatest(dd.trans_curr_exp, 2), '0')
                                  || ';-###0.' || lpad('0', greatest(dd.trans_curr_exp, 2), '0') trans_amount_format
                                   , power(10, dd.trans_curr_exp)                                trans_curr_exp
                                   , sum(dd.trans_amount) as trans_amount
                                   , count(1) as trans_count
                                from detail_data dd
                               group by
                                     dd.trans_currency
                                   , dd.trans_curr_name
                                   , dd.trans_curr_exp
                                   , dd.trans_curr_exp
                        )
                     )
                 )
           ).getclobVal()
      into o_xml
      from (
            select xmlelement("group_data"
                     , xmlagg(
                           xmlelement("group_file"
                             , xmlforest(
                                   sf.id                                                       "file_id"
                                 , sf.file_name                                                "file_name"
                                 , to_char(sf.file_date, com_api_const_pkg.XML_DATE_FORMAT)    "file_date"
                               )
                             , xmlelement("group_currencies"
                                 , (select xmlagg(
                                               xmlelement("group_currency"
                                                 , xmlforest(
                                                       dd.trans_currency                                           "trans_currency"
                                                     , dd.trans_curr_name                                          "trans_curr_name"
                                                     , sum(dd.trans_amount)                                        "sub_total_amount"
                                                     , count(1)                                                    "sub_total_count"
                                                     , '###0.' || lpad('0', greatest(dd.trans_curr_exp, 2), '0')
                                                    || ';-###0.' || lpad('0', greatest(dd.trans_curr_exp, 2), '0') "trans_amount_format"
                                                     , power(10, dd.trans_curr_exp)                                "trans_curr_exp"
                                                   )
                                                 , xmlelement("details"
                                                     , xmlagg(
                                                           xmlelement("detail"
                                                             , xmlforest(
                                                                  dd.rrn                                                      "rrn"
                                                                , dd.sttl_amount                                              "sttl_amount"
                                                                , dd.sttl_curr_name                                           "sttl_curr_name"
                                                                , '###0.' || lpad('0', greatest(dd.sttl_curr_exp, 2), '0')
                                                               || ';-###0.' || lpad('0', greatest(dd.sttl_curr_exp, 2), '0')  "sttl_amount_format"
                                                                , power(10, dd.sttl_curr_exp)                                 "sttl_curr_exp"
                                                                , '###0.' || lpad('0', greatest(dd.trans_curr_exp, 2), '0')
                                                               || ';-###0.' || lpad('0', greatest(dd.trans_curr_exp, 2), '0') "trans_amount_format"
                                                                , power(10, dd.trans_curr_exp)                                "trans_curr_exp"
                                                                , dd.trans_amount                                             "trans_amount"
                                                                , dd.card_mask                                                "card_mask"
                                                              )
                                                           ) order by dd.card_mask
                                                      )
                                                   )
                                               ) order by dd.trans_currency
                                           )
                                      from detail_data dd
                                     where dd.file_id = sf.id
                                     group by
                                           dd.trans_currency
                                         , dd.trans_curr_name
                                         , dd.trans_curr_exp
                                   )
                              )
                          ) order by sf.id
                       )   
                   ) as rez
              from prc_session_file sf
             where sf.id between l_from_id and l_till_id
               and exists(select 1 from detail_data dd where dd.file_id = sf.id)
             order by
                   sf.id
      );
    
end audit_trailer_data_matching;

end cup_api_report_pkg;
/
