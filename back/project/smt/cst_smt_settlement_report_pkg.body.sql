CREATE OR REPLACE PACKAGE BODY cst_smt_settlement_report_pkg is
/*********************************************************
 *  Settlement reports API <br />
 *  Module: cst_smt_settlement_report_pkg <br />
 *  @headcom
 **********************************************************/
PACKAGE_NAME            constant com_api_type_pkg.t_name         := 'cst_smt_settlement_report_pkg';

DATE_FORMAT_DAY         constant com_api_type_pkg.t_oracle_name := 'dd/mm/yyyy';
DATE_FORMAT_DAY_SHORT   constant com_api_type_pkg.t_oracle_name := 'dd/mm/yy';
DATETIME_FORMAT         constant com_api_type_pkg.t_oracle_name := 'dd.mm.yyyy hh24:mi:ss';

----------------------------------------------------------------
function get_sttl_day(i_sttl_date date)
return com_api_type_pkg.t_tiny_id
is
l_day com_api_type_pkg.t_tiny_id;
begin
    select max(sttl_day)
      into l_day
      from com_settlement_day
     where inst_id = ost_api_const_pkg.DEFAULT_INST
       and is_open = COM_API_CONST_PKG.FALSE 
       and sttl_date <= i_sttl_date;    
    
    return l_day;
end;

procedure get_start_end_sttl_date(i_sttl_date in date
                                , io_start_date in out date
                                , io_end_date in out date
) is
    l_day com_api_type_pkg.t_tiny_id;
begin
    l_day := get_sttl_day(i_sttl_date);
    if l_day is not null then 
        select min(sttl_date)  
          into io_start_date
          from com_settlement_day
         where sttl_day = l_day;

        select max(sttl_date)  
          into io_start_date
          from com_settlement_day
         where sttl_day = l_day+1;    

        io_end_date := nvl(io_end_date, sysdate);
    else
        io_start_date := trunc(i_sttl_date);
        io_end_date := trunc(i_sttl_date+1);
    end if;
    
end;

function is_operation_valid(i_status com_api_type_pkg.t_dict_value)
return number
result_cache relies_on(com_array_element)
is
    l_result number;
begin
    l_result := com_api_array_pkg.is_element_in_array(
                        i_array_id      => cst_smt_api_const_pkg.INVALID_CARD_STATUS_ARRAY 
                        , i_elem_value  => i_status);
    return l_result; 
end;

function get_operation_type(i_oper_type com_api_type_pkg.t_dict_value
                            , i_msg_type com_api_type_pkg.t_dict_value
                            , i_type number default 0)
return number
result_cache
is
    l_result number := 0;
begin
    if i_type = 0 then
        If i_oper_type in ( opr_api_const_pkg.OPERATION_TYPE_PURCHASE
                            , opr_api_const_pkg.OPERATION_TYPE_CASHBACK
                            , opr_api_const_pkg.OPERATION_TYPE_UNIQUE)  
            then l_result := 0;

        Elsif i_oper_type = opr_api_const_pkg.OPERATION_TYPE_POS_CASH 
            then l_result := 1;

        Elsif i_oper_type = opr_api_const_pkg.OPERATION_TYPE_ATM_CASH 
            then l_result := 2;

        Elsif i_oper_type = opr_api_const_pkg.OPERATION_TYPE_REFUND 
            then l_result := 3;

        Elsif i_msg_type = opr_api_const_pkg.MESSAGE_TYPE_CHARGEBACK
            then l_result := 4;

        Elsif i_msg_type = opr_api_const_pkg.MESSAGE_TYPE_REPRESENTMENT
            then l_result := 5;    
        end if;  
          
    else
    
        if i_msg_type = opr_api_const_pkg.MESSAGE_TYPE_CHARGEBACK
            then 

            if i_oper_type in ( opr_api_const_pkg.OPERATION_TYPE_PURCHASE
                            , opr_api_const_pkg.OPERATION_TYPE_CASHBACK
                            , opr_api_const_pkg.OPERATION_TYPE_UNIQUE)
                    then l_result := 15;
                elsif i_oper_type = opr_api_const_pkg.OPERATION_TYPE_POS_CASH 
                    then l_result := 17;       
                Elsif i_oper_type = opr_api_const_pkg.OPERATION_TYPE_ATM_CASH 
                    then l_result := 18;
            end if;

        else

            If i_oper_type in ( opr_api_const_pkg.OPERATION_TYPE_PURCHASE
                                , opr_api_const_pkg.OPERATION_TYPE_CASHBACK
                                , opr_api_const_pkg.OPERATION_TYPE_UNIQUE)  
                then l_result := 05;

            Elsif i_oper_type = opr_api_const_pkg.OPERATION_TYPE_POS_CASH 
                then l_result := 07;

            Elsif i_oper_type = opr_api_const_pkg.OPERATION_TYPE_ATM_CASH 
                then l_result := 08;

            Elsif i_oper_type = opr_api_const_pkg.OPERATION_TYPE_REFUND 
                then l_result := 06;
            end if;

        end if;

    end if;
    
    return l_result; 
end;

-- REJECTED TRANSACTIONS REPORT BY ACQUIRER BANK
procedure acq_rejected_transaction(
    o_xml   out clob
  , i_date  in  date
  , i_inst  in  com_api_type_pkg.t_tiny_id  
  , i_lang  in  com_api_type_pkg.t_dict_value   default null
)
is
    l_table                    xmltype;
    l_date                     date := nvl(i_date, sysdate);
--    l_tag_id                   com_api_type_pkg.t_short_id;
    l_start_date               date := trunc(l_date);
    l_end_date                 date := trunc(l_date)+1;  
begin

    trc_log_pkg.debug(
        i_text       => PACKAGE_NAME||'.acq_rejected_transaction' || '<< i_date [#1]' || '<< i_inst [#2]'
      , i_env_param1 => com_api_type_pkg.convert_to_char(l_date)
      , i_env_param2 => i_inst
    );

    select xmlelement("record"
             , xmlelement("batch_id",           batch_id)
             , xmlelement("batch_seq",          batch_seq)
             , xmlelement("tr_seq",             tr_seq)
             , xmlelement("reject_value_field", reject_value_field)
             , xmlelement("reject_description", reject_description)
             , xmlelement("comm",               comm)
             , xmlelement("invoice",            incoice)
             , xmlelement("card_number",        card_number)
             , xmlelement("amount",             amount)
           )
      into l_table
      from (
            select aup_api_tag_pkg.get_tag_value(
                                    i_auth_id         => oo.id
                                    , i_tag_reference => cst_smt_api_const_pkg.TAG_BATCH_NUMBER
                                    )  batch_id
                 , dense_rank() over (order by aup_api_tag_pkg.get_tag_value(
                                                i_auth_id         => oo.id
                                                , i_tag_reference => cst_smt_api_const_pkg.TAG_BATCH_NUMBER
                                                ) 
                                                , oo.merchant_number) batch_seq
                 , rownum tr_seq
                 , oo.status reject_value_field
                 , com_api_dictionary_pkg.get_article_text(i_article=>oo.status
                                                            , i_lang => i_lang)  reject_description
                 , oo.status comm
                 , aup_api_tag_pkg.get_tag_value(
                                    i_auth_id         => oo.id
                                    , i_tag_reference => cst_smt_api_const_pkg.TAG_INVOCE
                                    ) incoice
                 , oc.card_number   card_number
                 , oo.oper_amount        amount
              from opr_operation oo
                 , opr_participant op
                 , opr_card oc
             where oo.id = op.oper_id
               and op.participant_type = com_api_const_pkg.PARTICIPANT_ACQUIRER
               and oo.id = oc.oper_id
               and oc.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
               and oo.oper_date between l_start_date and l_end_date
               and cst_smt_settlement_report_pkg.is_operation_valid(i_status=> oo.status) = com_api_const_pkg.FALSE
      ) stats
      ;    

    if l_table is null then
        select xmlelement("record"
             , xmlelement("batch_id",           null)
             , xmlelement("batch_seq",          null)
             , xmlelement("tr_seq",             null)
             , xmlelement("reject_value_field", null)
             , xmlelement("reject_description", null)
             , xmlelement("comm",               null)
             , xmlelement("incoice",            null)
             , xmlelement("card_number",        null)
             , xmlelement("amount",             null)
           )
          into l_table
          from dual;
    end if;

    select xmlelement("report"
             , (select xmlelement("header"
                         , xmlelement("report_datetime"
                             , to_char(sysdate(), DATE_FORMAT_DAY)
                           )
                        , xmlelement("acq_bank",  com_api_flexible_data_pkg.get_flexible_value(
                                                    i_field_name    => cst_smt_api_const_pkg.INST_ABBREVIATION    
                                                    , i_entity_type => ost_api_const_pkg.ENTITY_TYPE_INSTITUTION
                                                    , i_object_id   => i_inst
                                                    )
                                    )
                       )
                  from dual
                 
               ) -- header
             , (select xmlelement("table"
                         , l_table
                       )
                  from dual
               )
           ).getclobval()
      into o_xml
      from dual;

exception
    when com_api_error_pkg.e_application_error
      or com_api_error_pkg.e_fatal_error
    then
        raise;
    when others then
        trc_log_pkg.debug(
            i_text       => PACKAGE_NAME||'.acq_rejected_transaction'  || '>> FAILED: ' || sqlerrm
        );
        raise;
end;

-- PROCESSED ACQUIRER TRANSACTIONS STATISTICS FOR SMT IN THAT BUSINESS DATE
procedure acq_transaction_statistic(
    o_xml   out clob
  , i_date  in  date
  , i_lang  in  com_api_type_pkg.t_dict_value   default null
)
is
    l_table                    xmltype;
    l_date                     date := nvl(i_date,sysdate);
    l_tag_id                   com_api_type_pkg.t_short_id;
    l_start_date               date := trunc(l_date);
    l_end_date                 date := trunc(l_date)+1;    
begin

    trc_log_pkg.debug(
        i_text       => PACKAGE_NAME||'.acq_transaction_statistic' || '<< i_date [#1]'
      , i_env_param1 => com_api_type_pkg.convert_to_char(l_date)
    );
    
    l_tag_id    := aup_api_tag_pkg.find_tag_by_reference(i_reference=>cst_smt_api_const_pkg.TAG_BATCH_NUMBER);

    select xmlagg(xmlelement("record"
             , xmlelement("inst_abbreviation", com_api_flexible_data_pkg.get_flexible_value(
                                                i_field_name    => cst_smt_api_const_pkg.INST_ABBREVIATION    
                                                , i_entity_type => ost_api_const_pkg.ENTITY_TYPE_INSTITUTION
                                                , i_object_id   => stats.inst_id
                                                )
                         )
             , xmlelement("rej_batch",      count(distinct decode(stats.status, 0, stats.batch_num, null)))
             , xmlelement("rej_trnx",       count(distinct decode(stats.status, 0, stats.id, null)))
             , xmlelement("valid_batch",    count(distinct decode(stats.status, 1, stats.batch_num, null)))
             , xmlelement("valid_trnx",     count(distinct decode(stats.status, 1, stats.id, null)))
           ))
      into l_table
      from (
            select coalesce(tag.tag_value, substr(op.inst_id,-2)||to_char(oo.oper_date,'DDD')) as batch_num
                 , oo.id
                 , op.inst_id
                 , cst_smt_settlement_report_pkg.is_operation_valid(i_status=> oo.status) status
              from opr_operation oo
                 , opr_participant op
                 , aup_tag_value tag
             where oo.id = op.oper_id
               and op.participant_type = com_api_const_pkg.PARTICIPANT_ACQUIRER
               and oo.id    = tag.auth_id(+)
               and oo.oper_date between l_start_date and l_end_date
               and l_tag_id = tag.tag_id(+)
      ) stats
      group by inst_id;

    if l_table is null then
        select xmlelement("record"
             , xmlelement("inst_abbreviation",  null)
             , xmlelement("rej_batch",          null)
             , xmlelement("rej_trnx",           null)
             , xmlelement("valid_batch",        null)
             , xmlelement("valid_trnx",         null)
           )
          into l_table
          from dual;
    end if;

    select xmlelement("report"
             , (select xmlelement("header"
                         , xmlelement("report_datetime"
                             , to_char(sysdate(), DATE_FORMAT_DAY)
                           )
                        , xmlelement("sttl_date", to_char(l_date, DATE_FORMAT_DAY))
                       )
                  from dual
                 
               ) -- header
             , (select xmlelement("table"
                         , l_table
                       )
                  from dual
               )
           ).getclobval()
      into o_xml
      from dual;

exception
    when com_api_error_pkg.e_application_error
      or com_api_error_pkg.e_fatal_error
    then
        raise;
    when others then
        trc_log_pkg.debug(
            i_text       => PACKAGE_NAME||'.acq_transaction_statistic'  || '>> FAILED: ' || sqlerrm
        );
        raise;
end;

-- CIRRUS / MAESTRO TRANSACTIONS REPORT BY ACQUIRER BANK
procedure mc_acq_transaction(
    o_xml   out clob
  , i_date  in  date
  , i_inst  in  com_api_type_pkg.t_tiny_id
  , i_lang  in  com_api_type_pkg.t_dict_value   default null
)
is
    l_table                    xmltype;
    l_tag_id                   com_api_type_pkg.t_short_id;
    l_date                     date := nvl(i_date,sysdate);
    l_tag_id_batch             com_api_type_pkg.t_short_id;
    l_default_batch_num        cst_smt_api_type_pkg.t_batch_number;
    l_start_date               date;
    l_end_date                 date;
begin

    trc_log_pkg.debug(
        i_text       => PACKAGE_NAME||'.mc_acq_transaction' || '<< i_date [#1], i_inst[#2]'
      , i_env_param1 => com_api_type_pkg.convert_to_char(l_date)
      , i_env_param2 => com_api_type_pkg.convert_to_char(i_inst)
    );
    
    l_tag_id            := aup_api_tag_pkg.find_tag_by_reference(i_reference=>cst_smt_api_const_pkg.TAG_BATCH_NUMBER);
    l_default_batch_num := substr(i_inst,-2)||to_char(nvl(i_date,sysdate),'DDD');
    l_start_date        := trunc(l_date);
    l_end_date          := l_start_date+1;

    select xmlagg(xmlelement("record"
             , xmlelement("batch_number", batch_number)                         
             , xmlelement("remmit",       remmit)
             , xmlelement("merch_id",     merch_id)
             , xmlelement("trnx_date",    trnx_date)             
             , xmlelement("auth_code",    auth_code)
             , xmlelement("card_num",     card_num)
             , xmlelement("trnx_amnt",    trnx_amnt)
           ))
      into l_table         
    from 
    (select 
            nvl(tag_b.tag_value,l_default_batch_num) batch_number
            , dense_rank() over (order by nvl(tag_b.tag_value, l_default_batch_num) , oo.merchant_number) remmit
            , oo.merchant_number                    merch_id
            , to_char(oper_date, DATE_FORMAT_DAY)   trnx_date                 
            , iss_part.auth_code                    auth_code
            , card.card_number                      card_num
            , oo.oper_amount                        trnx_amnt
      from opr_operation oo
         , opr_participant acq_part
         , opr_participant iss_part
         , opr_card card
         , aup_tag_value tag_b
     where acq_part.oper_id = oo.id
       and acq_part.participant_type = com_api_const_pkg.PARTICIPANT_ACQUIRER
       and card.oper_id = oo.id
       and card.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
       and iss_part.oper_id = oo.id
       and iss_part.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
       and oo.id = tag_b.auth_id(+)
       and l_tag_id = tag_b.tag_id(+)
       and iss_part.inst_id = cst_smt_api_const_pkg.MC_NETWORK_INST
       and oo.oper_date between l_start_date and l_end_date
       and acq_part.inst_id = i_inst
       and oo.terminal_type in (acq_api_const_pkg.TERMINAL_TYPE_POS, acq_api_const_pkg.TERMINAL_TYPE_MOBILE_POS)
       order by nvl(tag_b.tag_value, l_default_batch_num) 
              , oo.merchant_number);

    if l_table is null then
        select xmlelement("record"
                 , xmlelement("batch_number",  null)
                 , xmlelement("remmit",        null)
                 , xmlelement("merch_id",      null)
                 , xmlelement("trnx_date",     null)
                 , xmlelement("auth_code",     null)
                 , xmlelement("card_num",      null)
                 , xmlelement("trnx_amnt",     null)
               )
          into l_table
          from dual;
    end if;

    select xmlelement("report"
             , (select xmlelement("header"
                         , xmlelement("report_datetime"
                             , to_char(sysdate(), DATE_FORMAT_DAY)
                           )
                        , xmlelement("inst_abbreviation", to_char(l_date, DATE_FORMAT_DAY))
                       )
                  from dual
                 
               ) -- header
             , (select xmlelement("table"
                         , l_table
                       )
                  from dual
               )
           ).getclobval()
      into o_xml
      from dual;

exception
    when com_api_error_pkg.e_application_error
      or com_api_error_pkg.e_fatal_error
    then
        raise;
    when others then
        trc_log_pkg.debug(
            i_text       => PACKAGE_NAME||'.mc_acq_transaction'  || '>> FAILED: ' || sqlerrm
        );
        raise;
end;

-- GENERAL ACQUIRED TRANSACTIONS REPORT IN RELATION TO ISSUERS
procedure acq_general_transaction(
    o_xml   out clob
  , i_date  in  date
  , i_inst  in  com_api_type_pkg.t_tiny_id
  , i_lang  in  com_api_type_pkg.t_dict_value   default null
)
is
    l_table                    xmltype;
    l_date                     date := nvl(i_date,sysdate);
    l_tag_id                   com_api_type_pkg.t_short_id;
    l_start_date                date := trunc(l_date);
    l_end_date                  date := trunc(l_date)+1;
begin

    trc_log_pkg.debug(
        i_text       => PACKAGE_NAME||'.acq_general_transaction' || '<< i_date [#1], i_inst[#2]'
      , i_env_param1 => com_api_type_pkg.convert_to_char(l_date)
      , i_env_param2 => com_api_type_pkg.convert_to_char(i_inst)
    );
    
    l_tag_id    := aup_api_tag_pkg.find_tag_by_reference(i_reference=>cst_smt_api_const_pkg.TAG_BATCH_NUMBER);

    select xmlagg(xmlelement("record"
             , xmlelement("inst_abbreviation", nvl(
                                                com_api_flexible_data_pkg.get_flexible_value(
                                                    i_field_name    => cst_smt_api_const_pkg.INST_ABBREVIATION    
                                                    , i_entity_type => ost_api_const_pkg.ENTITY_TYPE_INSTITUTION
                                                    , i_object_id   => opr.iss_inst)
                                                , opr.iss_inst)
                         )                         
             , xmlelement("cnt_0",    opr.cnt_0)
             , xmlelement("cnt_1",    opr.cnt_1)
             , xmlelement("cnt_2",    opr.cnt_2)             
             , xmlelement("cnt_3",    opr.cnt_3)
             , xmlelement("cnt_4",    opr.cnt_4)
             , xmlelement("cnt_5",    opr.cnt_5)
             , xmlelement("sum_0",    opr.sum_0)
             , xmlelement("sum_1",    opr.sum_1)
             , xmlelement("sum_2",    opr.sum_2)             
             , xmlelement("sum_3",    opr.sum_3)
             , xmlelement("sum_4",    opr.sum_4)
             , xmlelement("sum_5",    opr.sum_5)
           ))
      into l_table
      from (  select opr.iss_inst iss_inst,
                   sum(decode(opr.oper_type, 0, opr.oper_amount,0)) sum_0,
                   sum(decode(opr.oper_type, 1, opr.oper_amount,0)) sum_1,
                   sum(decode(opr.oper_type, 2, opr.oper_amount,0)) sum_2,
                   sum(decode(opr.oper_type, 3, opr.oper_amount,0)) sum_3,
                   sum(decode(opr.oper_type, 4, opr.oper_amount,0)) sum_4,
                   sum(decode(opr.oper_type, 5, opr.oper_amount,0)) sum_5,
                   count(decode(opr.oper_type, 0, opr.oper_amount,null)) cnt_0,
                   count(decode(opr.oper_type, 1, opr.oper_amount,null)) cnt_1,
                   count(decode(opr.oper_type, 2, opr.oper_amount,null)) cnt_2,
                   count(decode(opr.oper_type, 3, opr.oper_amount,null)) cnt_3,
                   count(decode(opr.oper_type, 4, opr.oper_amount,null)) cnt_4,
                   count(decode(opr.oper_type, 5, opr.oper_amount,null)) cnt_5       
                from 
                        (select  participant_acq.inst_id acq_inst, 
                                participant_iss.inst_id iss_inst,
                                cst_smt_settlement_report_pkg.get_operation_type(i_oper_type => opr.oper_type
                                                                               , i_msg_type=> opr.msg_type) oper_type, 
                                opr.oper_amount
                          from  opr_operation opr
                                , opr_participant participant_acq
                                , opr_participant participant_iss
                         where opr.id = participant_acq.oper_id and opr.id = participant_iss.oper_id
                           and participant_acq.participant_type = com_api_const_pkg.PARTICIPANT_ACQUIRER 
                           and participant_acq.network_id = cst_smt_api_const_pkg.LOCAL_NETWORK
                           and participant_iss.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER 
                           and participant_iss.inst_id != participant_acq.inst_id
                           and opr.oper_date between l_start_date and l_end_date
                           and participant_acq.inst_id = i_inst) opr
            group by opr.acq_inst, opr.iss_inst      

      ) opr;

    if l_table is null then
        select xmlelement("record"
             , xmlelement("inst_abbreviation",  null)
             , xmlelement("cnt_0",    null)
             , xmlelement("cnt_1",    null)
             , xmlelement("cnt_2",    null)             
             , xmlelement("cnt_3",    null)
             , xmlelement("cnt_4",    null)
             , xmlelement("cnt_5",    null)
             , xmlelement("sum_0",    null)
             , xmlelement("sum_1",    null)
             , xmlelement("sum_2",    null)             
             , xmlelement("sum_3",    null)
             , xmlelement("sum_4",    null)
             , xmlelement("sum_5",    null)
           )
          into l_table
          from dual;
    end if;

    select xmlelement("report"
             , (select xmlelement("header"
                         , xmlelement("report_datetime"
                             , to_char(sysdate(), DATE_FORMAT_DAY)
                           )
                        , xmlelement("sttl_date", to_char(l_date, DATE_FORMAT_DAY))
                        , xmlelement("acq_inst_name", nvl(com_api_i18n_pkg.get_text(i_table_name => 'OST_INSTITUTION'
                                                                                  , i_column_name => 'NAME'
                                                                                  , i_object_id => i_inst
                                                                                  , i_lang      => i_lang)
                                                          , i_inst)
                       ))
                  from dual
                 
               ) -- header
             , (select xmlelement("table"
                         , l_table
                       )
                  from dual
               )
           ).getclobval()
      into o_xml
      from dual;

exception
    when com_api_error_pkg.e_application_error
      or com_api_error_pkg.e_fatal_error
    then
        raise;
    when others then
        trc_log_pkg.debug(
            i_text       => PACKAGE_NAME||'.acq_general_transaction'  || '>> FAILED: ' || sqlerrm
        );
        raise;
end;

-- NATIONAL INCOMING CLEARING REPORT BY BANK (ISSUING).
procedure iss_national_transaction(
    o_xml   out clob
  , i_date  in  date
  , i_inst  in  com_api_type_pkg.t_tiny_id
  , i_lang  in  com_api_type_pkg.t_dict_value   default null
)
is
    l_table                    xmltype;
    l_date                     date := nvl(i_date,sysdate);
    l_business_date            date := trunc(l_date);
    l_sttl_date                date := trunc(l_date)+1;
    l_tag_arn                  com_api_type_pkg.t_short_id;
    l_start_date               date := trunc(l_date);
    l_end_date                 date := trunc(l_date)+1;
begin

    trc_log_pkg.debug(
        i_text       => PACKAGE_NAME||'.iss_national_transaction' || '<< i_date [#1], i_inst[#2]'
      , i_env_param1 => com_api_type_pkg.convert_to_char(l_date)
      , i_env_param2 => com_api_type_pkg.convert_to_char(i_inst)
    );
    l_tag_arn    := aup_api_tag_pkg.find_tag_by_reference(i_reference=>cst_smt_api_const_pkg.TAG_ARN);
    
    l_start_date        := trunc(l_date);
    l_end_date          := l_start_date+1;

    select xmlagg(xmlelement("record"
             , xmlelement("acq_bank_abbr", com_api_flexible_data_pkg.get_flexible_value(
                                                    i_field_name    => cst_smt_api_const_pkg.INST_ABBREVIATION    
                                                    , i_entity_type => ost_api_const_pkg.ENTITY_TYPE_INSTITUTION
                                                    , i_object_id   => acq_inst)
                          )
             , xmlelement("acq_inst",       substr(acq_inst,-2))
             , xmlelement("acq_inst_full",  acq_inst)
             , xmlelement("oper_type",      oper_type)
             , xmlelement("oper_type_sum",  oper_type_sum)
             , xmlelement("acq_ref_num",    acq_ref_num)
             , xmlelement("draft",          draft)
             , xmlelement("card_num",       card_num)
             , xmlelement("oper_date",      to_char(oper_date, DATE_FORMAT_DAY_SHORT))
             , xmlelement("oper_amount",    oper_amount)
             , xmlelement("sttl_amount",    sttl_amount)             
             , xmlelement("auth_code",      auth_code)
             , xmlelement("mas",            mas)
             , xmlelement("merch_id",       merch_id)
             , xmlelement("merch_name",     merch_name)                                                                          
               ))
      into l_table
    from (
        select acq_part.inst_id acq_inst
             , cst_smt_settlement_report_pkg.get_operation_type(i_oper_type => oo.oper_type
                                                              , i_msg_type=> oo.msg_type
                                                              , i_type => 1) oper_type
             , cst_smt_settlement_report_pkg.get_operation_type(i_oper_type => oo.oper_type
                                                              , i_msg_type=> oo.msg_type
                                                              , i_type => 0) oper_type_sum
             , tag_arn.tag_value acq_ref_num
             , null draft
             , oc.card_number card_num
             , oo.oper_date oper_date
             , oo.oper_amount oper_amount
             , oo.sttl_amount sttl_amount
             , iss_part.auth_code auth_code
             , com_api_flexible_data_pkg.get_flexible_value(
                i_field_name    => cst_smt_api_const_pkg.MERCHANT_ACTICITY_SECTOR    
                , i_entity_type => acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                , i_object_id   => acq_part.merchant_id
                )                   mas
             , oo.merchant_number   merch_id
             , oo.merchant_name     merch_name
          from opr_operation oo
             , opr_participant iss_part
             , opr_participant acq_part
             , opr_card oc
             , aup_tag_value tag_arn
         where acq_part.oper_id    = oo.id  
           and acq_part.participant_type = com_api_const_pkg.PARTICIPANT_ACQUIRER
           and acq_part.network_id = cst_smt_api_const_pkg.LOCAL_NETWORK
           and iss_part.network_id = cst_smt_api_const_pkg.LOCAL_NETWORK
           and iss_part.oper_id    = oo.id
           and iss_part.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
           and oc.oper_id    = oo.id
           and oc.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
           and iss_part.inst_id    != acq_part.inst_id
           and oo.id = tag_arn.auth_id(+)
           and l_tag_arn = tag_arn.tag_id(+)
           and oo.oper_date between l_start_date and l_end_date
           and iss_part.inst_id = i_inst
           order by acq_part.inst_id
                  , cst_smt_settlement_report_pkg.get_operation_type(i_oper_type => oo.oper_type
                                                                   , i_msg_type=> oo.msg_type)
           );

    if l_table is null then
        select xmlelement("record"
             , xmlelement("acq_bank_abbr",  null)
             , xmlelement("acq_inst_full",  null)
             , xmlelement("acq_inst",       null)
             , xmlelement("oper_type",      null)
             , xmlelement("oper_type_sum",  null)
             , xmlelement("acq_ref_num",    null)
             , xmlelement("draft",          null)
             , xmlelement("card_num",       null)
             , xmlelement("oper_date",      null)
             , xmlelement("oper_amount",    null)
             , xmlelement("sttl_amount",    null)             
             , xmlelement("auth_code",      null)
             , xmlelement("mas",            null)
             , xmlelement("merch_id",       null)
             , xmlelement("merch_name",     null)
           )
          into l_table
          from dual;
    end if;

    select xmlelement("report"
             , (select xmlelement("header"
                         , xmlelement("report_datetime"
                             , to_char(sysdate(), DATE_FORMAT_DAY)
                           )
                        , xmlelement("sttl_date", cst_smt_settlement_report_pkg.get_sttl_day(l_sttl_date)|| ' '
                                                  ||to_char(l_sttl_date, DATE_FORMAT_DAY))
                        , xmlelement("business_date", cst_smt_settlement_report_pkg.get_sttl_day(l_business_date)|| ' '
                                                  ||to_char(l_business_date, DATE_FORMAT_DAY))
                        , xmlelement("inst_abbreviation", nvl(com_api_flexible_data_pkg.get_flexible_value(
                                                                i_field_name    => cst_smt_api_const_pkg.INST_ABBREVIATION    
                                                                , i_entity_type => ost_api_const_pkg.ENTITY_TYPE_INSTITUTION
                                                                , i_object_id   => i_inst)
                                                              ,i_inst)
                        
                        , xmlelement("acq_inst_name", nvl(com_api_i18n_pkg.get_text(i_table_name => 'OST_INSTITUTION'
                                                                                  , i_column_name => 'NAME'
                                                                                  , i_object_id => i_inst
                                                                                  , i_lang      => i_lang)
                                                          , i_inst)
                                     )                     
                       ))
                  from dual
                 
               ) -- header
             , (select xmlelement("table"
                         , l_table
                       )
                  from dual
               )
           ).getclobval()
      into o_xml
      from dual;

exception
    when com_api_error_pkg.e_application_error
      or com_api_error_pkg.e_fatal_error
    then
        raise;
    when others then
        trc_log_pkg.debug(
            i_text       => PACKAGE_NAME||'.iss_national_transaction'  || '>> FAILED: ' || sqlerrm
        );
        raise; 
end;

-- NATIONAL OUTGOING CLEARING REPORT BY BANK (ACQUIRING)
procedure acq_national_transaction(
    o_xml   out clob
  , i_date  in  date
  , i_inst  in  com_api_type_pkg.t_tiny_id
  , i_lang  in  com_api_type_pkg.t_dict_value   default null
)
is
    l_table                    xmltype;
    l_date                     date := nvl(i_date,sysdate);
    l_business_date            date := trunc(l_date);
    l_sttl_date                date := trunc(l_date)+1;
    l_tag_arn                  com_api_type_pkg.t_short_id;
    l_start_date               date := trunc(l_date);
    l_end_date                 date := trunc(l_date)+1;
begin

    trc_log_pkg.debug(
        i_text       => PACKAGE_NAME||'.acq_national_transaction' || '<< i_date [#1], i_inst[#2]'
      , i_env_param1 => com_api_type_pkg.convert_to_char(l_date)
      , i_env_param2 => com_api_type_pkg.convert_to_char(i_inst)
    );
    l_tag_arn    := aup_api_tag_pkg.find_tag_by_reference(i_reference=>cst_smt_api_const_pkg.TAG_ARN);
    
    l_start_date        := trunc(l_date);
    l_end_date          := l_start_date+1;

    select xmlagg(xmlelement("record"
             , xmlelement("iss_bank_abbr", com_api_flexible_data_pkg.get_flexible_value(
                                                    i_field_name    => cst_smt_api_const_pkg.INST_ABBREVIATION    
                                                    , i_entity_type => ost_api_const_pkg.ENTITY_TYPE_INSTITUTION
                                                    , i_object_id   => iss_inst)
                          )
             , xmlelement("iss_inst",       substr(iss_inst,-2))
             , xmlelement("iss_inst_full",  iss_inst)
             , xmlelement("oper_type",      oper_type)
             , xmlelement("oper_type_sum",  oper_type_sum)
             , xmlelement("acq_ref_num",    acq_ref_num)
             , xmlelement("draft",          draft)
             , xmlelement("card_num",       card_num)
             , xmlelement("oper_date",      to_char(oper_date, DATE_FORMAT_DAY_SHORT))
             , xmlelement("oper_amount",    oper_amount)
             , xmlelement("sttl_amount",    sttl_amount)             
             , xmlelement("auth_code",      auth_code)
             , xmlelement("mas",            mas)
             , xmlelement("merch_id",       merch_id)
             , xmlelement("merch_name",     merch_name)                                                                          
               ))
      into l_table
    from (
        select iss_part.inst_id iss_inst
             , cst_smt_settlement_report_pkg.get_operation_type(i_oper_type => oo.oper_type
                                                              , i_msg_type=> oo.msg_type
                                                              , i_type => 1) oper_type
             , cst_smt_settlement_report_pkg.get_operation_type(i_oper_type => oo.oper_type
                                                              , i_msg_type=> oo.msg_type
                                                              , i_type => 0) oper_type_sum
             , tag_arn.tag_value acq_ref_num
             , null draft
             , oc.card_number card_num
             , oo.oper_date oper_date
             , oo.oper_amount oper_amount
             , oo.sttl_amount sttl_amount
             , iss_part.auth_code auth_code
             , com_api_flexible_data_pkg.get_flexible_value(
                i_field_name    => cst_smt_api_const_pkg.MERCHANT_ACTICITY_SECTOR    
                , i_entity_type => acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                , i_object_id   => acq_part.merchant_id
                )                   mas
             , oo.merchant_number   merch_id
             , oo.merchant_name     merch_name
          from opr_operation oo
             , opr_participant iss_part
             , opr_participant acq_part
             , opr_card oc
             , aup_tag_value tag_arn
         where acq_part.oper_id    = oo.id  
           and acq_part.participant_type = com_api_const_pkg.PARTICIPANT_ACQUIRER
           and acq_part.network_id = cst_smt_api_const_pkg.LOCAL_NETWORK
           and iss_part.network_id = cst_smt_api_const_pkg.LOCAL_NETWORK
           and iss_part.oper_id    = oo.id
           and iss_part.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
           and oc.oper_id    = oo.id
           and oc.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
           and iss_part.inst_id    != acq_part.inst_id
           and oo.id = tag_arn.auth_id(+)
           and l_tag_arn = tag_arn.tag_id(+)
           and oo.oper_date between l_start_date and l_end_date
           and acq_part.inst_id = i_inst
           order by iss_part.inst_id
                  , cst_smt_settlement_report_pkg.get_operation_type(i_oper_type => oo.oper_type
                                                                   , i_msg_type=> oo.msg_type)
           );

    if l_table is null then
        select xmlelement("record"
             , xmlelement("acq_bank_abbr",  null)
             , xmlelement("acq_inst_full",  null)
             , xmlelement("acq_inst",       null)
             , xmlelement("oper_type",      null)
             , xmlelement("oper_type_sum",  null)
             , xmlelement("acq_ref_num",    null)
             , xmlelement("draft",          null)
             , xmlelement("card_num",       null)
             , xmlelement("oper_date",      null)
             , xmlelement("oper_amount",    null)
             , xmlelement("sttl_amount",    null)             
             , xmlelement("auth_code",      null)
             , xmlelement("mas",            null)
             , xmlelement("merch_id",       null)
             , xmlelement("merch_name",     null)
           )
          into l_table
          from dual;
    end if;

    select xmlelement("report"
             , (select xmlelement("header"
                         , xmlelement("report_datetime"
                             , to_char(sysdate(), DATE_FORMAT_DAY)
                           )
                        , xmlelement("sttl_date", cst_smt_settlement_report_pkg.get_sttl_day(l_sttl_date)|| ' '
                                                  ||to_char(l_sttl_date, DATE_FORMAT_DAY))
                        , xmlelement("business_date", cst_smt_settlement_report_pkg.get_sttl_day(l_business_date)|| ' '
                                                  ||to_char(l_business_date, DATE_FORMAT_DAY))
                        , xmlelement("inst_abbreviation", nvl(com_api_flexible_data_pkg.get_flexible_value(
                                                                i_field_name    => cst_smt_api_const_pkg.INST_ABBREVIATION    
                                                                , i_entity_type => ost_api_const_pkg.ENTITY_TYPE_INSTITUTION
                                                                , i_object_id   => i_inst)
                                                              ,i_inst)
                        
                        , xmlelement("acq_inst_name", nvl(com_api_i18n_pkg.get_text(i_table_name => 'OST_INSTITUTION'
                                                                                  , i_column_name => 'NAME'
                                                                                  , i_object_id => i_inst
                                                                                  , i_lang      => i_lang)
                                                          , i_inst)
                                     )                     
                       ))
                  from dual
                 
               ) -- header
             , (select xmlelement("table"
                         , l_table
                       )
                  from dual
               )
           ).getclobval()
      into o_xml
      from dual;

exception
    when com_api_error_pkg.e_application_error
      or com_api_error_pkg.e_fatal_error
    then
        raise;
    when others then
        trc_log_pkg.debug(
            i_text       => PACKAGE_NAME||'.acq_national_transaction'  || '>> FAILED: ' || sqlerrm
        );
        raise;  
end;

-- STATISTICS INTERNATIONAL OUTGOING REPORT FOR SMT IN THAT BUSINESS DATE
procedure outgoing_international_trnx(
    o_xml   out clob
  , i_date  in  date
  , i_lang  in  com_api_type_pkg.t_dict_value   default null
)
is
    l_table                    xmltype;
    l_date                     date := nvl(i_date,sysdate);
    l_start_date               date ;
    l_end_date                 date ;
begin

    trc_log_pkg.debug(
        i_text       => PACKAGE_NAME||'.outgoing_international_trnx' || '<< i_date [#1] start[#2] end[#3]'
      , i_env_param1 => com_api_type_pkg.convert_to_char(l_date)
      , i_env_param2 => com_api_type_pkg.convert_to_char(l_start_date)
      , i_env_param3 => com_api_type_pkg.convert_to_char(l_end_date)
    );
    
    get_start_end_sttl_date(i_sttl_date => l_date
                            , io_start_date => l_start_date
                            , io_end_date => l_end_date);    

    select xmlagg(xmlelement("record"
             , xmlelement("acq_bank_abbr", com_api_flexible_data_pkg.get_flexible_value(
                                                    i_field_name    => cst_smt_api_const_pkg.INST_ABBREVIATION    
                                                    , i_entity_type => ost_api_const_pkg.ENTITY_TYPE_INSTITUTION
                                                    , i_object_id   => inst.id)
                          )
             , xmlelement("mc_count",       nvl(mc_count,0))
             , xmlelement("mc_amount",      nvl(mc_amount,0))
             , xmlelement("visa_count",     nvl(visa_count,0))
             , xmlelement("visa_amount",    nvl(visa_amount,0))             
             , xmlelement("amex_count",     nvl(amex_count,0))
             , xmlelement("amex_amount",    nvl(amex_amount,0))
             , xmlelement("diners_count",   nvl(diners_count,0))
             , xmlelement("diners_amount",  nvl(diners_amount,0))
               )
            )
      into l_table
      from 
        (select net_type
            , inst_id
            , count(decode(net_type, 1, 1, null)) mc_count
            , sum(decode(net_type, 1, oper_amount,0)) mc_amount
            , count(decode(net_type, 2, 1, null)) visa_count
            , sum(decode(net_type, 2, oper_amount,0)) visa_amount
            , count(decode(net_type, 3, 1, null)) amex_count
            , sum(decode(net_type, 3, oper_amount,0)) amex_amount
            , count(decode(net_type, 4, 1, null)) diners_count
            , sum(decode(net_type, 4, oper_amount,0)) diners_amount
        from 
            (select 
                   opr.inst_id
                 , opr.id
                 , opr.oper_amount        
                ,(select 1 from mcw_fin where id= opr.id and is_incoming =0 and file_id is not null and rownum<=1
                  union 
                  select 2 from vis_fin_message where id= opr.id and is_incoming =1 and file_id is not null and rownum<=1
                  union
                  select 3 from amx_fin_message where id= opr.id and is_incoming =0 and file_id is not null and rownum<=1
                  union
                  select 4 from din_fin_message where id= opr.id and is_incoming =0 and file_id is not null and rownum<=1
                  ) net_type
            from 
                (select participant_acq.inst_id
                      , participant_iss.network_id
                      , opr.id
                      , opr.oper_amount
                from opr_operation opr
                   , opr_participant participant_iss
                   , opr_participant participant_acq
                where opr.id = participant_iss.oper_id 
                    and participant_iss.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER 
                    and participant_iss.network_id != cst_smt_api_const_pkg.LOCAL_NETWORK --network issuer
                    and opr.id = participant_acq.oper_id 
                    and participant_acq.participant_type = com_api_const_pkg.PARTICIPANT_ACQUIRER
                    and participant_acq.network_id = cst_smt_api_const_pkg.LOCAL_NETWORK -- local acquirer
                    and opr.oper_date between l_start_date and l_end_date
                ) opr
            )
        group by inst_id,   -- acq inst
                 net_type -- network
    ) op
    , (select * from ost_institution where inst_type = cst_smt_api_const_pkg.INSTITUTE_PROCESSING_TYPE) inst
    where inst.id = op.inst_id(+) 
    ;

    if l_table is null then
        select xmlelement("record"
             , xmlelement("acq_bank_abbr",  null)
             , xmlelement("visa_count",     null)
             , xmlelement("visa_amount",    null)
             , xmlelement("mc_count",       null)
             , xmlelement("mc_amount",      null)
             , xmlelement("amex_count",     null)
             , xmlelement("amex_amount",    null)
             , xmlelement("diners_count",   null)
             , xmlelement("diners_amount",  null)
           )
          into l_table
          from dual;
    end if;    

    select xmlelement("report"
             , (select xmlelement("header"
                         , xmlelement("report_datetime"
                             , to_char(sysdate(), DATE_FORMAT_DAY)
                           )
                        , xmlelement("business_date", to_char(l_date, DATE_FORMAT_DAY))

                       )
                  from dual
               ) -- header
             , (select xmlelement("table"
                         , l_table
                       )
                  from dual
               )
           ).getclobval()
      into o_xml
      from dual;    
 
exception
    when com_api_error_pkg.e_application_error
      or com_api_error_pkg.e_fatal_error
    then
        raise;
    when others then
        trc_log_pkg.debug(
            i_text       => PACKAGE_NAME||'.outgoing_international_trnx'  || '>> FAILED: ' || sqlerrm
        );
        raise; 
end;

-- CENTRAL BANK SUMMARY CLEARING REPORT
procedure central_bank_summary_clearing(
    o_xml   out clob
  , i_date  in  date
  , i_lang  in  com_api_type_pkg.t_dict_value   default null  
)
is
    l_table                    xmltype;
    l_date                     date := nvl(i_date,sysdate);
    l_sttl_day                 number;
begin

    trc_log_pkg.debug(
        i_text       => PACKAGE_NAME||'.central_bank_summary_clearing' || '<< i_date [#1]'
      , i_env_param1 => com_api_type_pkg.convert_to_char(l_date)
    );
    
    l_sttl_day := get_sttl_day(i_sttl_date => l_date);

    select xmlagg(xmlelement("record"
             , xmlelement("inst_abbreviation", com_api_flexible_data_pkg.get_flexible_value(
                                                i_field_name    => cst_smt_api_const_pkg.INST_ABBREVIATION    
                                                , i_entity_type => ost_api_const_pkg.ENTITY_TYPE_INSTITUTION
                                                , i_object_id   => ins.inst_name
                                                )
                         )
             , xmlelement("debit_count", ins.debit_count)
             , xmlelement("credit_count", ins.credit_count)
             , xmlelement("debit_sum", ins.debit_sum)
             , xmlelement("credit_sum", ins.credit_sum)
           ))
      into l_table
      from (
            select 
                count(decode(ae.balance_impact, -1, 1,null))    debit_count,    -- debit count
                count(decode(ae.balance_impact, 1, 1,null))     credit_count,   -- credit count
                sum(decode(ae.balance_impact, -1, ae.amount,0)) debit_sum,      -- debit sum
                sum(decode(ae.balance_impact, 1, ae.amount,0))  credit_sum,     -- credit sum
                aa.inst_id  inst_name
            from acc_entry ae
               , acc_account aa
            where ae.account_id = aa.id
              and aa.account_type = cst_smt_api_const_pkg.INSTITUTE_GL_ACCOUNT
              and ae.sttl_day = l_sttl_day 
            group by aa.inst_id
      ) ins
    ;

    if l_table is null then
        select xmlelement("record"
             , xmlelement("inst_abbreviation",  null)
             , xmlelement("debit_count",        null)
             , xmlelement("credit_count",       null)
             , xmlelement("debit_sum",          null)
             , xmlelement("credit_sum",         null)
           )
          into l_table
          from dual;
    end if;

    select xmlelement("report"
             , (select xmlelement("header"
                         , xmlelement("report_datetime"
                             , to_char(sysdate(), DATE_FORMAT_DAY)
                           )
                        , xmlelement("sttl_date", to_char(l_date, DATE_FORMAT_DAY))
                       )
                  from dual
                 
               ) -- header
             , (select xmlelement("table"
                         , l_table
                       )
                  from dual
               )
           ).getclobval()
      into o_xml
      from dual;

exception
    when com_api_error_pkg.e_application_error
      or com_api_error_pkg.e_fatal_error
    then
        raise;
    when others then
        trc_log_pkg.debug(
            i_text       => PACKAGE_NAME||'.central_bank_summary_clearing'  || '>> FAILED: ' || sqlerrm
        );
        raise;
end;

-- SUMMARY MERCHANT REMITTANCE BY NETWORK
procedure summary_merchant_remittance(
    o_xml   out clob
  , i_date  in  date
  , i_inst  in  com_api_type_pkg.t_tiny_id
  , i_lang  in  com_api_type_pkg.t_dict_value   default null
)
is
    l_table                    xmltype;
    l_date                     date := nvl(i_date,sysdate);
    l_business_date            date := trunc(l_date);
    l_tag_batch                com_api_type_pkg.t_short_id;
    l_default_batch_num        cst_smt_api_type_pkg.t_batch_number;
    l_sttl_date                date := trunc(l_date)+1;
    l_start_date               date := trunc(l_date);
    l_end_date                 date := trunc(l_date)+1;
begin

    trc_log_pkg.debug(
        i_text       => PACKAGE_NAME||'.summary_merchant_remittance' || '<< i_date [#1], i_inst[#2]'
      , i_env_param1 => com_api_type_pkg.convert_to_char(l_date)
      , i_env_param2 => com_api_type_pkg.convert_to_char(i_inst)
    );
    
    l_tag_batch         := aup_api_tag_pkg.find_tag_by_reference(i_reference=>cst_smt_api_const_pkg.TAG_BATCH_NUMBER);
    l_default_batch_num := substr(i_inst,-2)||to_char(nvl(i_date,sysdate),'DDD');
    
    l_start_date        := trunc(l_date);
    l_end_date          := l_start_date+1;
    
    select xmlelement("record"
             , xmlelement("merchant_id",                merchant_number)
             , xmlelement("merchant_name",              merchant_name)
             , xmlelement("remitt_num",                 remitt_id)
             , xmlelement("remitt_date",                remitt_date)
             , xmlelement("visa_national_count",        nvl(visa_national_count,0))
             , xmlelement("visa_national_amount",       nvl(visa_national_amount,0))
             , xmlelement("visa_international_count",   nvl(visa_international_count,0))
             , xmlelement("visa_international_amount",  nvl(visa_international_amount,0))
             , xmlelement("mc_national_count",          nvl(mc_national_count,0))
             , xmlelement("mc_national_amount",         nvl(mc_national_amount,0))
             , xmlelement("mc_international_count",     nvl(mc_international_count,0))
             , xmlelement("mc_international_amount",    nvl(mc_international_amount,0))
             , xmlelement("privet_count",               nvl(privet_count,0))
             , xmlelement("privet_amount",              nvl(privet_amount,0))
           )
      into l_table    
      from 
        (select merchant_number
             , merchant_name
             , remitt_id
             , remitt_date
             , count(decode(card_type, 1, decode(iss_inst_id,cst_smt_api_const_pkg.VISA_NETWORK_INST,null,1),null))        visa_national_count
             , sum(decode(card_type,   1, decode(iss_inst_id,cst_smt_api_const_pkg.VISA_NETWORK_INST,0,oper_amount),0))    visa_national_amount
             , count(decode(card_type, 1, decode(iss_inst_id,cst_smt_api_const_pkg.VISA_NETWORK_INST,1,null),null))        visa_international_count
             , sum(decode(card_type,   1, decode(iss_inst_id,cst_smt_api_const_pkg.VISA_NETWORK_INST,oper_amount,0),0))    visa_international_amount
             , count(decode(card_type, 2, decode(iss_inst_id,cst_smt_api_const_pkg.MC_NETWORK_INST,null,1),null))        mc_national_count
             , sum(decode(card_type,   2, decode(iss_inst_id,cst_smt_api_const_pkg.MC_NETWORK_INST,0,oper_amount),0))    mc_national_amount
             , count(decode(card_type, 2, decode(iss_inst_id,cst_smt_api_const_pkg.MC_NETWORK_INST,1,null),null))        mc_international_count
             , sum(decode(card_type,   2, decode(iss_inst_id,cst_smt_api_const_pkg.MC_NETWORK_INST,oper_amount,0),0))    mc_international_amount                  
             , count(decode(card_type, 3, 1,null)) privet_count
             , sum(decode(card_type,   3, oper_amount,0)) privet_amount
         from  ( 
             select oo.merchant_number
                  , oo.merchant_name
                  , oo.oper_amount
                  , decode(cst_smt_prc_cb_outgoing_pkg.get_convertation(
                              i_array_type_id       => cst_smt_api_const_pkg.CARD_TYPE_ARRAY_TYPE
                              , i_array_id          => cst_smt_api_const_pkg.CARD_TYPE_CONVERTER
                              , i_elem_value        => iss_part.card_type_id
                              , i_retun_def_value   => cst_smt_api_const_pkg.DEFAULT_CARD_TYPE
                            ) 
                               , cst_smt_api_const_pkg.VISA_NETWORK_NAME, 1
                               , cst_smt_api_const_pkg.MASTERCARD_NETWORK_NAME, 2
                               , 3)  card_type
                  , iss_part.inst_id iss_inst_id
                  , nvl(tag_batch.tag_value, l_default_batch_num) batch
                  , dense_rank() over (ORDER BY oo.merchant_number, oo.merchant_name, nvl(tag_batch.tag_value, l_default_batch_num) ) as remitt_id
                  , to_char(oo.oper_date,'YYMMDD') remitt_date
               from opr_operation oo
                  , opr_participant iss_part
                  , opr_participant acq_part
                  , aup_tag_value tag_batch
              where oo.id = iss_part.oper_id
                and iss_part.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
                and oo.id = acq_part.oper_id
                and acq_part.participant_type = com_api_const_pkg.PARTICIPANT_ACQUIRER
                and oo.id =  tag_batch.auth_id(+)
                and l_tag_batch = tag_batch.tag_id(+) 
                and acq_part.inst_id = i_inst
                and acq_part.inst_id != nvl(iss_part.inst_id,-1)
                and oo.oper_date between l_start_date and l_end_date
                order by oo.merchant_number
                       , oo.merchant_name
                       , nvl(tag_batch.tag_value, l_default_batch_num)
           ) oper
          group by oper.merchant_number
                 , oper.merchant_name
                 , oper.remitt_id
                 , oper.remitt_date
          )
      order by merchant_number
             , merchant_name
             , remitt_id
             , remitt_date;

    if l_table is null then
        select xmlelement("record"
             , xmlelement("merchant_id",                null)
             , xmlelement("merchant_name",              null)
             , xmlelement("remitt_num",                 null)
             , xmlelement("remitt_date",                null)
             , xmlelement("visa_national_count",        null)
             , xmlelement("visa_national_amount",       null)
             , xmlelement("visa_international_count",   null)
             , xmlelement("visa_international_amount",  null)
             , xmlelement("mc_national_count",          null)
             , xmlelement("mc_national_amount",         null)
             , xmlelement("mc_international_count",     null)
             , xmlelement("mc_international_amount",    null)
             , xmlelement("privet_count",               null)
             , xmlelement("privet_amount",              null)
           )
          into l_table
          from dual;
    end if;

    select xmlelement("report"
             , (select xmlelement("header"
                         , xmlelement("report_datetime"
                             , to_char(sysdate(), DATE_FORMAT_DAY)
                           )
                        , xmlelement("acq_bank_abbr", com_api_flexible_data_pkg.get_flexible_value(
                                                        i_field_name    => cst_smt_api_const_pkg.INST_ABBREVIATION    
                                                        , i_entity_type => ost_api_const_pkg.ENTITY_TYPE_INSTITUTION
                                                        , i_object_id   => i_inst
                                                        )
                                     )
                       )
                  from dual
               ) -- header
             , (select xmlelement("table"
                         , l_table
                       )
                  from dual
               )
           ).getclobval()
      into o_xml
      from dual;

exception
    when com_api_error_pkg.e_application_error
      or com_api_error_pkg.e_fatal_error
    then
        raise;
    when others then
        trc_log_pkg.debug(
            i_text       => PACKAGE_NAME||'.summary_merchant_remittance'  || '>> FAILED: ' || sqlerrm
        );
        raise;
end;

end cst_smt_settlement_report_pkg;
/
