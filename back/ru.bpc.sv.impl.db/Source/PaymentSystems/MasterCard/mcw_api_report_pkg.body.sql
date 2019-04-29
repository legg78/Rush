
create or replace package body mcw_api_report_pkg is
/*********************************************************
 *  Issuer reports API <br />
 *  Created by Kolodkina J.(kolodkina@bpcbt.com)  at 20.03.2013 <br />
 *  Last changed by $Author: truschelev $ <br />
 *  $LastChangedDate:: 2015-08-21 09:26:00 +0400#$ <br />
 *  Revision: $LastChangedRevision: 25841 $ <br />
 *  Module: mcw_api_report_pkg <br />
 *  @headcom
 **********************************************************/
 
    NUM_FORMAT                constant com_api_type_pkg.t_name := 'FM999999999999999990,00';

    procedure mc_reconciliation_250b_batch (
        o_xml                          out clob
        , i_inst_id                    in com_api_type_pkg.t_inst_id
        , i_reconciliation_date        in date
        , i_lang                       in com_api_type_pkg.t_dict_value
    )is
        l_reconciliation_date      date;
        l_lang                     com_api_type_pkg.t_dict_value;
        l_inst_id                  com_api_type_pkg.t_inst_id;
        l_header                   xmltype;
        l_detail                   xmltype;
        l_result                   xmltype;

    begin
        trc_log_pkg.debug (
            i_text          => 'mcw_api_report_pkg.mc_reconciliation_250b_batch [#1][#2][#3]'
            , i_env_param1  => i_inst_id
            , i_env_param2  => i_reconciliation_date
            , i_env_param3  => i_lang
        );

        l_lang := nvl(i_lang, get_user_lang);
        l_reconciliation_date := trunc(nvl(i_reconciliation_date, com_api_sttl_day_pkg.get_sysdate));
        l_inst_id := nvl(i_inst_id, 0);

        -- header
        select
            xmlconcat(
                xmlelement("inst_id", l_inst_id)
                , xmlelement("inst", com_api_i18n_pkg.get_text('OST_INSTITUTION','NAME', l_inst_id, l_lang))
                , xmlelement("reconciliation_date", to_char(l_reconciliation_date, 'dd.mm.yyyy'))
            )
        into l_header 
        from dual;

        -- details
        begin
            select
                xmlelement("reconciliation"
                     , xmlagg(
                        xmlelement("record"
                             , xmlelement("oper_type",          oper_type)
                             , xmlelement("sttl_currency",      sttl_currency)
                             , xmlelement("processor",          processor)
                             , xmlelement("recon_amount",       recon_amount)
                             , xmlelement("recon_count",        recon_count)
                             , xmlelement("oper_amount",        oper_amount)
                             , xmlelement("oper_count",         oper_count)
                             , xmlelement("not_match_record",   not_match_record)
                             , xmlelement("curr_name",          curr_name)                             
                        )
                        order by processor
                               , sttl_currency
                               , oper_type
                     )
               )
            into
                l_detail
            from (
                with msg as (
                    select o.oper_type
                         , m.processor
                         , m.sttl_currency
                         , sum(m.sttl_amount) recon_amount
                         , count(1) recon_count        
                      from mcw_250byte_message m
                         , opr_operation o
                     where m.oper_id                  = o.id(+)
                       and trunc(m.transaction_date)  = l_reconciliation_date         
                     group by o.oper_type
                         , m.processor
                         , m.sttl_currency 
                     order by o.oper_type 
                         , m.sttl_currency 
                )
              , opr as (    
                    select oper_type
                         , processor 
                         , sttl_currency   
                         , sum(nvl(sttl_amount, 0)) oper_amount
                         , count(1) oper_count
                      from (  
                        select o.oper_type
                             , o.sttl_currency
                             , o.sttl_amount
                             , case when p_iss.inst_id = l_inst_id then 'A' 
                                    else 'I' 
                               end processor
                             , o.id  
                             , o.status
                          from opr_operation o
                             , aut_auth a
                             , opr_participant p_acq
                             , opr_participant p_iss
                         where o.id = a.id
                           and trunc(nvl(a.network_cnvt_date, o.oper_date))    = l_reconciliation_date
                           and o.msg_type             = opr_api_const_pkg.MESSAGE_TYPE_AUTHORIZATION
                           and o.status               in (opr_api_const_pkg.OPERATION_STATUS_PROCESSED
                                                      , opr_api_const_pkg.OPERATION_STATUS_DONE_WO_PROC
                                                      , opr_api_const_pkg.OPERATION_STATUS_UNHOLDED
                                                      , opr_api_const_pkg.OPERATION_STATUS_AUTHORIZED
                                                      , opr_api_const_pkg.OPERATION_STATUS_AWAITS_UNHOLD
                                                     )    
                           and a.parent_id            is null       
                           and p_acq.oper_id          = o.id
                           and p_acq.participant_type = com_api_const_pkg.PARTICIPANT_ACQUIRER
                           and p_iss.oper_id          = o.id
                           and p_iss.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
                           and p_iss.inst_id         != p_acq.inst_id --us_on_us 
                           and (l_inst_id = p_iss.inst_id or l_inst_id = p_acq.inst_id)
                         ) t   
                     group by oper_type
                         , processor 
                         , sttl_currency   
                     order by oper_type 
                         , sttl_currency    
                )
                select m.oper_type
                     , m.sttl_currency
                     , m.processor
                     , nvl(m.recon_amount, 0)/power (10, nvl(c.exponent,0)) recon_amount
                     , nvl(m.recon_count, 0) recon_count
                     , nvl(o.oper_amount, 0)/power (10, nvl(c.exponent,0)) oper_amount
                     , nvl(o.oper_count, 0) oper_count
                     , case when m.recon_amount != o.oper_amount or m.recon_count != o.oper_count then 1 else 0 end not_match_record
                     , c.name curr_name
                  from msg m
                     , opr o
                     , com_currency c
                 where m.oper_type      = o.oper_type(+)
                   and m.sttl_currency  = o.sttl_currency(+)
                   and c.code(+)        = m.sttl_currency         
                 order by m.processor 
                     , m.sttl_currency
                     , m.oper_type nulls last
            );       

        exception
            when no_data_found then
                select
                    xmlelement("reconciliation", '')
                into
                    l_detail
                from
                    dual;
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

        trc_log_pkg.debug (
            i_text => 'mcw_api_report_pkg.mc_reconciliation_250b_batch - ok'
        );
    exception
        when others then
            trc_log_pkg.debug (
                i_text   => sqlerrm
            );
            raise;
    end;
    
    procedure mc_unmatched_presentments (
        o_xml            out clob
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
        l_logo_path         xmltype;		
    begin
        l_lang       := nvl(i_lang, get_user_lang);

        if l_date_end is null and l_date_start is null then
            l_date_end   := trunc(com_api_sttl_day_pkg.get_sysdate) - interval '1' second;
        end if;
    
        if l_date_start is null  and l_date_end is not null then
            l_date_start := trunc(l_date_end);
        end if;
    
        trc_log_pkg.debug (
            i_text        => 'mcw_api_report_pkg.mc_unmatched_presentments [#1][#2][#3][#4]'
          , i_env_param1  => i_lang
          , i_env_param2  => i_inst_id
          , i_env_param3  => to_char(l_date_start, 'dd.mm.yyyy hh24:mi:ss')
          , i_env_param4  => to_char(l_date_end, 'dd.mm.yyyy hh24:mi:ss')
        );

        -- header          
        l_logo_path := rpt_api_template_pkg.logo_path_xml;
        select xmlelement(
                   "header"       
                 , l_logo_path
                 , xmlelement("p_date_start", to_char(l_date_start, 'dd.mm.yyyy'))
                 , xmlelement("p_date_end"  , to_char(l_date_end, 'dd.mm.yyyy'))
                 , xmlelement("p_inst"      , decode (i_inst_id, null, 'All'
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
                         , xmlelement("curr",             com_api_currency_pkg.get_currency_name(nvl(m.de050, o.sttl_currency)) )
                         , xmlelement("oper_type",        get_article_text(o.oper_type, l_lang) )
                         , xmlelement("oper_date",        to_char(m.de012, 'dd.mm.yyyy') )  -- oper_date
                         , xmlelement("sttl_amount",      to_char(m.de005, NUM_FORMAT) ) 
                         , xmlelement("auth_code",        m.de038)
                         , xmlelement("reversal_sign",    decode(m.is_reversal, 1, 'Y', 0, 'N'))
                         , xmlelement("card_number",      iss_api_card_pkg.get_card_mask(c.card_number))
                         , xmlelement("arn",              m.de031)   -- arn
                         , xmlelement("acquirer_bin",     m.de032)   -- acquirer_bin
                         , xmlelement("mcc",              m.de026)   -- mcc
                         , xmlelement("merchant_number",  m.de042)   -- merchant_number
                         , xmlelement("merchant_name",    m.de043_1) -- merchant_name
                         , xmlelement("merchant_address", m.de043_4 || ',' || -- o.merchant_postcode
                                                          m.de043_2 || ',' || -- o.merchant_street
                                                          m.de043_3 || ',' || -- merchant_city
                                                          m.de043_5 || ',' || -- merchant_region
                                                          com_api_country_pkg.get_country_code_by_name(m.de043_6, com_api_type_pkg.FALSE) --merchant_country
                                     )
                         , xmlelement("terminal_number",  m.de041) -- terminal_number
                         , xmlelement("matching_status",  get_article_text(o.match_status, l_lang))
                         
                       )
                   order by nvl(m.de050, o.sttl_currency)
                           , o.oper_date
                           , o.oper_type
                   )
                )
           into l_detail
           from mcw_fin m
              , opr_operation o
              , opr_card c
          where m.id         = o.id
            and c.oper_id    = o.id
            and o.oper_date >= l_date_start
            and o.oper_date < trunc(l_date_end) + 1
            and m.mti        = mcw_api_const_pkg.MSG_TYPE_PRESENTMENT
            and m.de024      = mcw_api_const_pkg.FUNC_CODE_FIRST_PRES
            and o.match_status in (OPR_API_CONST_PKG.OPERATION_MATCH_REQ_MATCH
                                 , OPR_API_CONST_PKG.OPERATION_MATCH_EXPIRED)
          order by nvl(m.de050, o.sttl_currency)
                 , o.oper_date
                 , o.oper_type 
                 ;

    --if no data
        if l_detail.getclobval() = '<details></details>' then
            select xmlelement(
                       "details"
                     , xmlagg(
                           xmlelement(
                               "detail"
                                 , xmlelement("curr",             null)
                                 , xmlelement("oper_type",        null)
                                 , xmlelement("oper_date",        null)
                                 , xmlelement("sttl_amount",      null)
                                 , xmlelement("auth_code",        null)
                                 , xmlelement("reversal_sign",    null)
                                 , xmlelement("auth_code",        null)
                                 , xmlelement("card_number",      null)
                                 , xmlelement("arn",              null)
                                 , xmlelement("acquirer_bin",     null)
                                 , xmlelement("mcc",              null)
                                 , xmlelement("merchant_number",  null)
                                 , xmlelement("merchant_name",    null)
                                 , xmlelement("merchant_address", null)
                                 , xmlelement("terminal_number",  null)
                                 , xmlelement("matching_status",  null)
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
            i_text => 'mcw_api_report_pkg.mc_unmatched_presentments - ok'
        );

    exception when others then
        trc_log_pkg.debug(i_text => sqlerrm);
        raise ;
    end;  

    
end;
/
