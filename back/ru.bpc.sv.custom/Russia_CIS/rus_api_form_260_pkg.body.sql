create or replace package body rus_api_form_260_pkg is

procedure get_header (
    i_lang         in  com_api_type_pkg.t_dict_value
  , i_inst_id      in  com_api_type_pkg.t_tiny_id
  , i_agent_id     in  com_api_type_pkg.t_short_id  default null
  , i_date_end     in  date
  , o_header       out xmltype
)is
    l_bank_name     com_api_type_pkg.t_name ;
    l_bank_address  com_api_type_pkg.t_name ;
    l_code_okpo     com_api_type_pkg.t_name ;
    l_serial_no     com_api_type_pkg.t_name ;
    l_code_okato    com_api_type_pkg.t_name ;
    l_agent_name    com_api_type_pkg.t_name ;

begin

    begin
        select get_text ('OST_INSTITUTION', 'NAME', i_inst_id, i_lang)
             , com_api_flexible_data_pkg.get_flexible_value('RUS_OKPO', ost_api_const_pkg.ENTITY_TYPE_INSTITUTION, i_inst_id)
             , com_api_flexible_data_pkg.get_flexible_value('RUS_REG_NUM', ost_api_const_pkg.ENTITY_TYPE_INSTITUTION, i_inst_id)
             , get_text ('OST_AGENT', 'NAME', i_agent_id, i_lang)
         into l_bank_name
             , l_code_okpo
             , l_serial_no
             , l_agent_name
          from dual;    
    exception 
        when others then 
            null;
    end;

    begin
        select com_api_address_pkg.get_address_string (o.address_id, i_lang ) address
             , a.region_code
          into l_bank_address
             , l_code_okato
         from com_address_object o
            , com_address a
        where o.entity_type = decode (i_agent_id, null, ost_api_const_pkg.ENTITY_TYPE_INSTITUTION, ost_api_const_pkg.ENTITY_TYPE_AGENT)
          and o.object_id = decode (i_agent_id, null, i_inst_id, i_agent_id)
          and o.address_type = 'ADTPLGLA' 
          and a.id = o.address_id ;
    exception 
        when others then 
            null;
    end;

    -- header
    select xmlelement( "header"
             , xmlelement( "bank_name"    , l_bank_name    )
             , xmlelement( "bank_address" , l_bank_address )
             , xmlelement( "agent_name"   , l_agent_name   )
             , xmlelement( "code_okpo"    , l_code_okpo    )
             , xmlelement( "serial_no"    , l_serial_no    )
             , xmlelement( "code_okato"   , l_code_okato   )
             , xmlelement( "date"         , to_char(i_date_end + 1, 'dd month yyyy', 'nls_date_language = russian' ) )
          ) xml
    into o_header
    from dual;

end;

procedure get_footer (
    i_lang         in  com_api_type_pkg.t_dict_value
  , i_inst_id      in  com_api_type_pkg.t_tiny_id
  , i_agent_id     in  com_api_type_pkg.t_short_id  default null
  , i_date_end     in  date
  , o_footer       out xmltype
)is
    l_contact_data  com_api_type_pkg.t_full_desc;
begin

    begin    
        select phone || decode(phone, null, null, ', ') || e_mail
          into l_contact_data
          from (
              select max (decode(d.commun_method,'CMNM0001',commun_address,null) ) as phone
                   , max (decode(d.commun_method,'CMNM0002',commun_address,null) ) as e_mail
                from com_contact_object o
                   , com_contact_data   d
               where o.object_id = com_ui_user_env_pkg.get_person_id
                 and o.entity_type = com_api_const_pkg.ENTITY_TYPE_PERSON
                 and o.contact_type = com_api_const_pkg.CONTACT_TYPE_PRIMARY
                 and d.contact_id = o.contact_id
                 and commun_method in (com_api_const_pkg.COMMUNICATION_METHOD_MOBILE, com_api_const_pkg.COMMUNICATION_METHOD_EMAIL)  -- mobile phone, e-mail
         );
    exception 
        when others then 
            null;
    end;

    -- footer
    select xmlelement( "footer"
             , xmlelement( "user_name", com_ui_person_pkg.get_person_name( acm_api_user_pkg.get_person_id( get_user_name ), i_lang ) )
             , xmlelement( "rpt_date" , to_char(com_api_sttl_day_pkg.get_sysdate,'dd.mm.yyyy hh24:mi' ) )
             , xmlelement( "phone"    , l_contact_data )
          ) xml
    into o_footer
    from dual;
    
end;

function get_terminal_count(
    i_region_code  in com_api_type_pkg.t_region_code
  , i_inst_id      in com_api_type_pkg.t_tiny_id
  , i_agent_id     in com_api_type_pkg.t_short_id  default null
)return number is

    l_result com_api_type_pkg.t_tiny_id;
begin
    select count(1)
      into l_result 
      from acq_terminal t
         , prd_contract c
         , com_address_object o
         , com_address a
     where decode(nvl(t.is_template, 0), 0, t.inst_id) = i_inst_id 
       and t.terminal_type = 'TRMT0002'
       and t.status in ('TRMS0001', 'TRMS0002')   
       and c.inst_id = t.inst_id
       and t.contract_id = c.id
       and (i_agent_id is null or c.agent_id = i_agent_id)
       and o.entity_type = 'ENTTTRMN'
       and o.object_id = t.id
       and o.address_id = a.id
       and (a.region_code = i_region_code or i_region_code = 'unknown');

    return l_result;
end;

function get_reversal_amount (
    i_oper_id      in com_api_type_pkg.t_long_id
  , i_amount_rev   in com_api_type_pkg.t_money
  , i_inst_id      in com_api_type_pkg.t_tiny_id
) return com_api_type_pkg.t_money
is
    l_amount_origin     com_api_type_pkg.t_money;
    l_oper_date_origin  date;
begin
    select oper_date
         , decode (oper_currency, 643, oper_amount, com_api_rate_pkg.convert_amount(
                                                            i_src_amount      => oper_amount
                                                          , i_src_currency    => oper_currency
                                                          , i_dst_currency    => 643
                                                          , i_rate_type       => 'RTTPCBRF'
                                                          , i_inst_id         => i_inst_id
                                                          , i_eff_date        => oper_date
                                                          , i_mask_exception  => 0
                                                          , i_exception_value => 0
                                                    )
                )
    into l_oper_date_origin
       , l_amount_origin
    from opr_operation
   where id = i_oper_id;

    if l_amount_origin <> i_amount_rev then
        return l_amount_origin - i_amount_rev ;
    else
        return i_amount_rev * -1;
    end if;
    
exception 
    when others then 
        return i_amount_rev;
end;

function correct_oper_count (
    i_oper_id      in com_api_type_pkg.t_long_id
  , i_amount_rev   in com_api_type_pkg.t_money
  , i_inst_id      in com_api_type_pkg.t_tiny_id
  , i_start_date   in date
  , i_end_date     in date
) return com_api_type_pkg.t_tiny_id
is
    l_amount_origin     com_api_type_pkg.t_money;
    l_oper_date_origin  date;
begin
    select decode (oper_currency, 643, oper_amount, com_api_rate_pkg.convert_amount(
                                                            i_src_amount      => oper_amount
                                                          , i_src_currency    => oper_currency
                                                          , i_dst_currency    => 643
                                                          , i_rate_type       => 'RTTPCBRF'
                                                          , i_inst_id         => i_inst_id
                                                          , i_eff_date        => oper_date
                                                          , i_mask_exception  => 0
                                                          , i_exception_value => 0
                                                    )
                )
       , (select min(posting_date) from acc_macros where object_id = o.id and entity_type = 'ENTTOPER')         
    into l_amount_origin
       , l_oper_date_origin
    from opr_operation o
   where o.id = i_oper_id;

    if l_amount_origin <> i_amount_rev then
        return 0;
    else
        if l_oper_date_origin between i_start_date and i_end_date then
            return 2;
        else
            return 1;
        end if;
    end if;

exception 
    when others then 
        return 0;
end;

procedure run_rpt_form_260_1 (
    o_xml          out clob
  , i_lang         in com_api_type_pkg.t_dict_value
  , i_inst_id      in com_api_type_pkg.t_tiny_id
  , i_agent_id     in com_api_type_pkg.t_short_id  default null
  , i_start_date   in date
  , i_end_date     in date
) is
    l_start_date   date;
    l_end_date     date;
    l_lang         com_api_type_pkg.t_dict_value;
    l_inst_id      com_api_type_pkg.t_inst_id;

    l_part_1       xmltype;
    l_header       xmltype;
    l_result       xmltype;
begin
    trc_log_pkg.debug( 
        i_text         => 'rus_api_form_260_pkg.run_rpt_form_260_1 [#1][#2][#3][#4][#5]]'
        , i_env_param1 => i_lang
        , i_env_param2 => i_inst_id
        , i_env_param3 => i_agent_id
        , i_env_param4 => i_start_date
        , i_env_param5 => i_end_date
    );
        
    l_lang := nvl(i_lang, get_user_lang);
    l_start_date := trunc(nvl(i_start_date, com_api_sttl_day_pkg.get_sysdate));
    l_end_date := nvl(trunc(i_end_date), l_start_date) + 1 - (1/86400);
    l_inst_id := nvl(i_inst_id, 0);

    get_header (
        i_lang        => i_lang
      , i_inst_id     => i_inst_id
      , i_agent_id    => i_agent_id
      , i_date_end    => l_end_date
      , o_header      => l_header
    );

    select
        xmlelement("part_1"
             , xmlagg(
                xmlelement("record"
                     , xmlelement("record_type", record_type)
                     , xmlelement("atm_count", atm_count)
                     , xmlelement("term_count", term_count)
                     , xmlelement("region_code", region_code)
                     , xmlelement("ci_cnt", ci_cnt)
                     , xmlelement("cl_cnt", cl_cnt)
                     , xmlelement("cw_cnt", cw_cnt)
                     , xmlelement("ci_amount", com_api_currency_pkg.get_amount_str(ci_amount, '643', com_api_type_pkg.TRUE))
                     , xmlelement("cl_amount", com_api_currency_pkg.get_amount_str(cl_amount, '643', com_api_type_pkg.TRUE))
                     , xmlelement("cw_amount", com_api_currency_pkg.get_amount_str(cw_amount, '643', com_api_type_pkg.TRUE))
                )
                order by region_code
             )
             -- total
             , xmlelement("record"
                 , xmlelement("record_type", 2)
                 , xmlelement("atm_count", 0)
                 , xmlelement("term_count", 0)
                 , xmlelement("region_code", '')
                 , xmlelement("ci_cnt", 0)
                 , xmlelement("cl_cnt", 0)
                 , xmlelement("cw_cnt", 0)
                 , xmlelement("ci_amount", 0)
                 , xmlelement("cl_amount", 0)
                 , xmlelement("cw_amount", 0)
           ) 
       )
    into
        l_part_1
    from (    
        select 1 as record_type
             , get_terminal_count(region_code, l_inst_id, i_agent_id) as atm_count
             , 0 term_count
             , region_code
             , (ci_cnt - nvl(ci_corr_cnt, 0)) ci_cnt
             , (cl_cnt - nvl(cl_corr_cnt, 0)) cl_cnt
             , (cw_cnt - nvl(cw_corr_cnt, 0)) cw_cnt
             , nvl(ci_amount, 0) ci_amount
             , nvl(cl_amount, 0) cl_amount
             , nvl(cw_amount, 0) cw_amount
             , nvl(ci_corr_cnt, 0) ci_corr_cnt
             , nvl(cl_corr_cnt, 0) cl_corr_cnt
             , nvl(cw_corr_cnt, 0) cw_corr_cnt
          from (     
              select t.oper_type
                   , t.region_code
                   , decode(t.is_reversal, 0, t.oper_amount, rus_api_form_260_pkg.get_reversal_amount(
                                                                 i_oper_id       => original_id
                                                                 , i_amount_rev  => oper_amount
                                                                 , i_inst_id     => l_inst_id
                                                             )
                   ) oper_amount 
                   , decode (t.is_reversal, 0, 0, rus_api_form_260_pkg.correct_oper_count (
                                                                 i_oper_id       => original_id
                                                                 , i_amount_rev  => oper_amount
                                                                 , i_inst_id     => l_inst_id
                                                                 , i_start_date  => l_start_date
                                                                 , i_end_date    => l_end_date
                                                              ) 
                   ) correct_count 
               from (     
                   select case when op.oper_type in (opr_api_const_pkg.OPERATION_TYPE_ATM_CASH, opr_api_const_pkg.OPERATION_TYPE_POS_CASH) then 'cw'
                             else 'ci'-- case when u.id is null then 'cl' else 'ci' end
                          end oper_type
                        , nvl((select region_code from com_address a 
                             where a.id = o.address_id  
                               and rownum = 1), 'unknown') as region_code
                        , case when op.oper_currency = '643' then op.oper_amount
                               else com_api_rate_pkg.convert_amount(op.oper_amount, op.oper_currency, '643', 'RTTPCBRF', l_inst_id, op.oper_date, 0, 0)
                          end oper_amount   
                        , op.is_reversal  
                        , op.original_id  
                     from acq_terminal t
                        , com_address_object o
                        , prd_contract c
                        , opr_participant p
                        , opr_operation op
                        , aut_auth u
                        , (select o.id as oper_id
                                , min(m.posting_date) as transaction_date
                             from opr_operation o
                                , acc_macros m
                            where m.entity_type = 'ENTTOPER'
                              and m.object_id = o.id
                              and m.posting_date between l_start_date and l_end_date
                            group by
                                o.id 
                          ) x                         
                    where decode(nvl(t.is_template, 0), 0, t.inst_id) = l_inst_id 
                      and t.terminal_type = acq_api_const_pkg.TERMINAL_TYPE_ATM
                      and t.status in (acq_api_const_pkg.TERMINAL_STATUS_ACTIVE, acq_api_const_pkg.TERMINAL_STATUS_INACTIVE)                              
                      and o.object_id = t.id
                      and o.entity_type = acq_api_const_pkg.ENTITY_TYPE_TERMINAL
                      and o.address_type   = 'ADTPBSNA'
                      and c.inst_id = t.inst_id                             
                      and t.contract_id = c.id
                      and (i_agent_id is null or c.agent_id = i_agent_id) 
                      and t.split_hash = p.split_hash  
                      and p.terminal_id = t.id
                      and p.participant_type = com_api_const_pkg.PARTICIPANT_ACQUIRER  
                      and p.oper_id = op.id
                      and op.oper_type in(opr_api_const_pkg.OPERATION_TYPE_ATM_CASH, opr_api_const_pkg.OPERATION_TYPE_POS_CASH, opr_api_const_pkg.OPERATION_TYPE_CASHIN)      
                      and op.status in (opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY, opr_api_const_pkg.OPERATION_STATUS_PROCESSED, opr_api_const_pkg.OPERATION_STATUS_AUTHORIZED)
                      and op.id = x.oper_id
                      and op.id = u.id(+)                           
                ) t    
        ) pivot ( count(1) as cnt, sum(oper_amount) as amount, sum(correct_count) as corr_cnt for oper_type in('cw' as cw, 'ci' as ci, 'cl' as cl) )      
    );

    select xmlelement ( "report"
             , l_header
             , l_part_1
           )
    into l_result
    from dual;

    o_xml := l_result.getclobval();

    trc_log_pkg.debug ( i_text => 'rus_api_form_260_pkg.run_rpt_form_260_1 - ok' );   

exception
    when others then
        trc_log_pkg.debug (
                i_text   => sqlerrm
        );
        raise_application_error (-20001, sqlerrm);             
    
end;

procedure run_rpt_form_260_2 (
    o_xml          out clob
  , i_lang         in com_api_type_pkg.t_dict_value
  , i_inst_id      in com_api_type_pkg.t_tiny_id
  , i_agent_id     in com_api_type_pkg.t_short_id  default null
  , i_start_date   in date
  , i_end_date     in date
) is
    l_start_date   date;
    l_end_date     date;
    l_sysdate      date;
    l_lang         com_api_type_pkg.t_dict_value;
    l_inst_id      com_api_type_pkg.t_inst_id;

    l_part_2       xmltype;
    l_result       xmltype;
begin
    trc_log_pkg.debug( 
        i_text         => 'rus_api_form_260_pkg.run_rpt_form_260_2 [#1][#2][#3][#4][#5]]'
        , i_env_param1 => i_lang
        , i_env_param2 => i_inst_id
        , i_env_param3 => i_agent_id
        , i_env_param4 => i_start_date
        , i_env_param5 => i_end_date
    );
        
    l_lang := nvl(i_lang, get_user_lang);
    l_start_date := trunc(nvl(i_start_date, com_api_sttl_day_pkg.get_sysdate));
    l_end_date := nvl(trunc(i_end_date), l_start_date) + 1 - (1/86400);
    l_inst_id := nvl(i_inst_id, 0);
    l_sysdate := com_api_sttl_day_pkg.get_sysdate;

    --part_2
    select
        xmlelement("part_2"
             , xmlagg(
                xmlelement("record"
                     , xmlelement("rn", rn)
                     , xmlelement("terminal_type", terminal_type)
                     , xmlelement("start_date", to_char(start_date, 'dd.mm.yyyy'))
                     , xmlelement("end_date", to_char(end_date, 'dd.mm.yyyy'))
                     , xmlelement("region_code", region_code)
                     , xmlelement("postal_code", postal_code)
                     , xmlelement("postal_address", postal_address)
                     , xmlelement("placement_type", placement_type)
                     , xmlelement("phone_number", phone_number)
                     , xmlelement("property_indicator", property_indicator)
                     , xmlelement("fiscal_number", fiscal_number)
                )
                order by region_code
                       , end_date nulls first 
             )
       )
    into
        l_part_2
    from (    
        select rownum as rn
             , t.terminal_type
             , t.start_date
             , t.end_date
             , t.region_code
             , t.postal_code
             , t.postal_address
             , get_article_text(t.placement_type, l_lang) placement_type
             , t.property_indicator
             , t.fiscal_number
             , t.phone_number
          from (     
              select 'Atm' as terminal_type
                   , so.start_date
                   , so.end_date 
                   , (select region_code from com_address a 
                                                where a.id = ao.address_id and rownum = 1) as region_code
                   , (select postal_code from com_address a 
                                                where a.id = ao.address_id and rownum = 1) as postal_code
                   , com_api_address_pkg.get_address_string(ao.address_id, l_lang, l_inst_id) as  postal_address
                   , tt.placement_type
                   , (
                         select commun_address
                           from com_contact_data d
                          where d.contact_id = co.contact_id
                            and commun_method = com_api_const_pkg.COMMUNICATION_METHOD_MOBILE
                            and (end_date is null or end_date > l_sysdate)
                     ) phone_number
                   , 'C' as property_indicator
                   , to_char(null) as fiscal_number 
                from acq_terminal t
                   , atm_terminal tt 
                   , prd_contract c
                   , com_address_object ao
                   , prd_service_object so    
                   , com_contact_object co
               where decode(nvl(t.is_template, 0), 0, t.inst_id) = l_inst_id 
                 and t.terminal_type = acq_api_const_pkg.TERMINAL_TYPE_ATM
                 and t.status in (acq_api_const_pkg.TERMINAL_STATUS_ACTIVE, acq_api_const_pkg.TERMINAL_STATUS_INACTIVE)  
                 and t.id = tt.id(+) --(+)??
                 and c.inst_id = t.inst_id
                 and t.contract_id = c.id
                 and (i_agent_id is null or c.agent_id = i_agent_id) 
                 and ao.object_id = t.id
                 and ao.entity_type = acq_api_const_pkg.ENTITY_TYPE_TERMINAL
                 and ao.address_type   = 'ADTPBSNA'
                 and so.object_id      = t.id
                 and so.entity_type    = acq_api_const_pkg.ENTITY_TYPE_TERMINAL
                 and so.contract_id    = c.id
                 and co.object_id(+)      = t.id --(+) ??
                 and co.entity_type(+)    = acq_api_const_pkg.ENTITY_TYPE_TERMINAL
                 and co.contact_type(+)   = com_api_const_pkg.CONTACT_TYPE_PRIMARY
                 and exists (select 1 
                                 from opr_operation o
                                    , opr_participant p   
                                    , acc_macros m
                                where m.entity_type = 'ENTTOPER'
                                  and m.object_id = o.id
                                  and p.participant_type = com_api_const_pkg.PARTICIPANT_ACQUIRER  
                                  and p.terminal_id = t.id    
                                  and p.oper_id = o.id
                                  and p.split_hash = t.split_hash   
                                  and m.posting_date between l_start_date and l_end_date
                            )   
            ) t
    );                   
    
    select xmlelement ( "report"
             , l_part_2
           )
    into l_result
    from dual;

    o_xml := l_result.getclobval();

    trc_log_pkg.debug ( i_text => 'rus_api_form_260_pkg.run_rpt_form_260_1 - ok' );   

exception
    when others then
        trc_log_pkg.debug (
                i_text   => sqlerrm
        );
        raise_application_error (-20001, sqlerrm);             
end;

procedure run_rpt_form_260_3 (
    o_xml          out clob
  , i_lang         in com_api_type_pkg.t_dict_value
  , i_inst_id      in com_api_type_pkg.t_tiny_id
  , i_agent_id     in com_api_type_pkg.t_short_id  default null
  , i_start_date   in date
  , i_end_date     in date
) is
    l_start_date   date;
    l_end_date     date;
    l_lang         com_api_type_pkg.t_dict_value;
    l_inst_id      com_api_type_pkg.t_inst_id;

    l_part_3       xmltype;
    l_footer       xmltype;
    l_result       xmltype;
begin
    trc_log_pkg.debug( 
        i_text         => 'rus_api_form_260_pkg.run_rpt_form_260_3 [#1][#2][#3][#4][#5]]'
        , i_env_param1 => i_lang
        , i_env_param2 => i_inst_id
        , i_env_param3 => i_agent_id
        , i_env_param4 => i_start_date
        , i_env_param5 => i_end_date
    );
        
    l_lang := nvl(i_lang, get_user_lang);
    l_start_date := trunc(nvl(i_start_date, com_api_sttl_day_pkg.get_sysdate));
    l_end_date := nvl(trunc(i_end_date), l_start_date) + 1 - (1/86400);
    l_inst_id := nvl(i_inst_id, 0);
    
    get_footer (
        i_lang        => i_lang
      , i_inst_id     => i_inst_id
      , i_agent_id    => i_agent_id
      , i_date_end    => l_end_date
      , o_footer      => l_footer
    );
    --part_3
    select xmlelement ("part_3")
      into l_part_3
      from dual;
     
    select xmlelement ( "report"
             , l_part_3
             , l_footer
           )
    into l_result
    from dual;

    o_xml := l_result.getclobval();

    trc_log_pkg.debug ( i_text => 'rus_api_form_260_pkg.run_rpt_form_260_3 - ok' );   

exception
    when others then
        trc_log_pkg.debug (
                i_text   => sqlerrm
        );
        raise_application_error (-20001, sqlerrm);             

end;

end;
/
