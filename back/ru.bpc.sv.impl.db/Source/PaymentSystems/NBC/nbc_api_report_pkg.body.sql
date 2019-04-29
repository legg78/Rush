create or replace package body nbc_api_report_pkg is
/*********************************************************
 *  Issuer reports API <br />
 *  Created by Kolodkina (kolodkina@bpcbt.com) at 02.12.2016 <br />
 *  Last changed by $Author: kolodkina $ <br />
 *  $LastChangedDate:: 2016-12-02 09:46:00 +0400#$ <br />
 *  Revision: $LastChangedRevision: 25841 $ <br />
 *  Module: nbc_api_report_pkg <br />
 *  @headcom
 **********************************************************/

procedure detail_report (
    o_xml                out       clob
    , i_inst_id          in        com_api_type_pkg.t_inst_id    default null
    , i_start_date       in        date                          default null 
    , i_end_date         in        date                          default null
    , i_mode             in        com_api_type_pkg.t_dict_value  
    , i_lang             in        com_api_type_pkg.t_dict_value
) is
    l_inst_id                      com_api_type_pkg.t_inst_id;
    l_agent_id                     com_api_type_pkg.t_agent_id;
    l_start_date                   date;
    l_end_date                     date;
    l_lang                         com_api_type_pkg.t_dict_value;
    l_header                       xmltype;
    l_detail                       xmltype;
    l_result                       xmltype;
    l_caption                      com_api_type_pkg.t_name;  
begin
    trc_log_pkg.debug (
        i_text          => 'nbc_api_report_pkg.detail_report [#1][#2][#3][#4]'
        , i_env_param1  => i_inst_id
        , i_env_param2  => com_api_type_pkg.convert_to_char(trunc(nvl(i_start_date, com_api_sttl_day_pkg.get_sysdate)))
        , i_env_param3  => com_api_type_pkg.convert_to_char(nvl(trunc(i_end_date), l_start_date) + 1 - com_api_const_pkg.ONE_SECOND)
        , i_env_param4  => i_mode
    );

    l_lang := nvl(i_lang, get_user_lang);
    l_start_date := trunc(nvl(i_start_date, com_api_sttl_day_pkg.get_sysdate));
    l_end_date := nvl(trunc(i_end_date), l_start_date) + 1 - com_api_const_pkg.ONE_SECOND;
    l_inst_id := nvl(i_inst_id, 0);
    
    l_caption := case when i_mode = 'NBCRRMCH' then 'REPORT OF DETAILS MATCH TRANSACTIONS'
                      when i_mode = 'NBCRRMSM' then 'REPORT OF DETAILS MISMATCH TRANSACTIONS'
                      else 'REPORT OF DETAILS DISPUTE TRANSACTIONS'
                 end;  
                  
    -- header
    select
        xmlconcat(
            xmlelement("inst_id", l_inst_id)
            , xmlelement("inst", com_api_i18n_pkg.get_text('OST_INSTITUTION','NAME', l_inst_id, l_lang))
            , xmlelement("start_date", to_char(l_start_date, 'dd.mm.yyyy'))
            , xmlelement("end_date", to_char(l_end_date, 'dd.mm.yyyy'))
            , xmlelement("caption", l_caption)
            , xmlelement("mode", i_mode)
        )
    into
        l_header
            from dual;

    begin
        case i_mode
            when 'NBCRRMCH' then
                select
                    xmlelement("messages"
                      , xmlagg(
                            xmlelement("message"
                              , xmlelement("id", id)
                              , xmlelement("record_type", record_type)
                              , xmlelement("nbc_resp_code", nbc_resp_code)  
                              , xmlelement("acq_resp_code", acq_resp_code)  
                              , xmlelement("iss_resp_code", iss_resp_code)  
                              , xmlelement("bnb_resp_code", bnb_resp_code)  
                              , xmlelement("dispute_trans_result", dispute_trans_result)                          
                              , xmlelement("participant_type", participant_type) 
                              , xmlelement("card_number", card_number) 
                              , xmlelement("proc_code", proc_code)
                              , xmlelement("trans_amount", com_api_currency_pkg.get_amount_str(nvl(trans_amount, 0), trans_currency, com_api_type_pkg.TRUE))                              
                              , xmlelement("sttl_amount", case when sttl_amount is null then ''
                                                               else com_api_currency_pkg.get_amount_str(nvl(sttl_amount, 0), settl_currency, com_api_type_pkg.TRUE, null, com_api_type_pkg.TRUE)
                                                          end)      
                              , xmlelement("crdh_bill_amount", case when crdh_bill_amount is null then ''
                                                                    else com_api_currency_pkg.get_amount_str(nvl(crdh_bill_amount, 0), crdh_bill_currency, com_api_type_pkg.TRUE, null, com_api_type_pkg.TRUE)
                                                               end)
                              , xmlelement("crdh_bill_fee", case when crdh_bill_fee is null then ''
                                                                 else com_api_currency_pkg.get_amount_str(nvl(crdh_bill_fee, 0), crdh_bill_currency, com_api_type_pkg.TRUE, null, com_api_type_pkg.TRUE)
                                                            end)                                    
                              , xmlelement("settl_rate", settl_rate)       
                              , xmlelement("crdh_bill_rate", crdh_bill_rate)   
                              , xmlelement("system_trace_number", system_trace_number)
                              , xmlelement("local_trans_time", local_trans_time)  
                              , xmlelement("local_trans_date", to_char(local_trans_date, 'dd.mm.yy')) 
                              , xmlelement("settlement_date", to_char(settlement_date, 'dd.mm.yy'))    
                              , xmlelement("merchant_type", merchant_type)      
                              , xmlelement("trans_fee_amount", com_api_currency_pkg.get_amount_str(nvl(trans_fee_amount, 0), trans_currency, com_api_type_pkg.TRUE))   
                              , xmlelement("acq_inst_code", acq_inst_code)      
                              , xmlelement("iss_inst_code", iss_inst_code)        
                              , xmlelement("bnb_inst_code", bnb_inst_code)     
                              , xmlelement("rrn",    rrn)            
                              , xmlelement("auth_number",  auth_number)      
                              , xmlelement("resp_code", resp_code)               
                              , xmlelement("terminal_id",  terminal_id)      
                              , xmlelement("trans_currency", trans_currency)    
                              , xmlelement("settl_currency", settl_currency)    
                              , xmlelement("crdh_bill_currency", crdh_bill_currency)
                              , xmlelement("from_account_id", from_account_id)   
                              , xmlelement("to_account_id", to_account_id)     
                              , xmlelement("nbc_fee", com_api_currency_pkg.get_amount_str(nvl(nbc_fee, 0), trans_currency, com_api_type_pkg.TRUE))           
                              , xmlelement("acq_fee", com_api_currency_pkg.get_amount_str(nvl(acq_fee, 0), trans_currency, com_api_type_pkg.TRUE))           
                              , xmlelement("iss_fee", com_api_currency_pkg.get_amount_str(nvl(iss_fee, 0), trans_currency, com_api_type_pkg.TRUE))           
                              , xmlelement("bnb_fee", com_api_currency_pkg.get_amount_str(nvl(bnb_fee, 0), trans_currency, com_api_type_pkg.TRUE))           
                              , xmlelement("mti", mti)
                            )
                            order by
                              participant_type
                            , id 
                        )
                    )
                into
                    l_detail
                from (
                    select m.id 
                        , m.record_type
                        , m.participant_type
                        , m.nbc_resp_code   
                        , m.acq_resp_code   
                        , m.iss_resp_code   
                        , m.bnb_resp_code   
                        , m.dispute_trans_result    
                        , trim('0' from c.card_number) card_number
                        , m.proc_code
                        , m.trans_amount
                        , m.sttl_amount
                        , m.crdh_bill_amount
                        , m.crdh_bill_fee      
                        , m.settl_rate       
                        , m.crdh_bill_rate   
                        , m.system_trace_number
                        , m.local_trans_time   
                        , m.local_trans_date   
                        , m.settlement_date    
                        , m.merchant_type      
                        , m.trans_fee_amount   
                        , m.acq_inst_code      
                        , m.iss_inst_code      
                        , m.bnb_inst_code      
                        , m.rrn                
                        , m.auth_number        
                        , m.resp_code                
                        , m.terminal_id        
                        , m.trans_currency     
                        , m.settl_currency     
                        , m.crdh_bill_currency 
                        , m.from_account_id    
                        , m.to_account_id      
                        , m.nbc_fee            
                        , m.acq_fee            
                        , m.iss_fee            
                        , m.bnb_fee            
                        , m.mti
                     from nbc_fin_message m 
                        , nbc_fin_message out_msg 
                        , nbc_card c
                    where trunc(m.local_trans_date) between l_start_date and l_end_date
                      and (l_inst_id = 0 or m.inst_id = l_inst_id) 
                      and m.is_incoming       = com_api_type_pkg.TRUE
                      and out_msg.is_incoming = com_api_type_pkg.FALSE
                      and (l_inst_id = 0 or out_msg.inst_id = l_inst_id)
                      and m.original_id       = out_msg.original_id
                      and c.id                = m.id
                );
            when 'NBCRRMSM' then
                select
                    xmlelement("messages"
                      , xmlagg(
                            xmlelement("message"
                              , xmlelement("id", id)
                              , xmlelement("record_type", record_type)
                              , xmlelement("nbc_resp_code", nbc_resp_code)  
                              , xmlelement("acq_resp_code", acq_resp_code)  
                              , xmlelement("iss_resp_code", iss_resp_code)  
                              , xmlelement("bnb_resp_code", bnb_resp_code)  
                              , xmlelement("dispute_trans_result", dispute_trans_result)                          
                              , xmlelement("participant_type", participant_type) 
                              , xmlelement("card_number", card_number) 
                              , xmlelement("proc_code", proc_code)
                              , xmlelement("trans_amount", com_api_currency_pkg.get_amount_str(nvl(trans_amount, 0), trans_currency, com_api_type_pkg.TRUE))
                              , xmlelement("sttl_amount", case when sttl_amount is null then ''
                                                               else com_api_currency_pkg.get_amount_str(nvl(sttl_amount, 0), settl_currency, com_api_type_pkg.TRUE, null, com_api_type_pkg.TRUE)
                                                          end)      
                              , xmlelement("crdh_bill_amount", case when crdh_bill_amount is null then ''
                                                                    else com_api_currency_pkg.get_amount_str(nvl(crdh_bill_amount, 0), crdh_bill_currency, com_api_type_pkg.TRUE, null, com_api_type_pkg.TRUE)
                                                               end)
                              , xmlelement("crdh_bill_fee", case when crdh_bill_fee is null then ''
                                                                 else com_api_currency_pkg.get_amount_str(nvl(crdh_bill_fee, 0), crdh_bill_currency, com_api_type_pkg.TRUE, null, com_api_type_pkg.TRUE)
                                                            end)                                    
                              , xmlelement("settl_rate", settl_rate)       
                              , xmlelement("crdh_bill_rate", crdh_bill_rate)   
                              , xmlelement("system_trace_number", system_trace_number)
                              , xmlelement("local_trans_time", local_trans_time)  
                              , xmlelement("local_trans_date", to_char(local_trans_date, 'dd.mm.yyyy')) 
                              , xmlelement("settlement_date", to_char(settlement_date, 'dd.mm.yyyy'))    
                              , xmlelement("merchant_type", merchant_type)      
                              , xmlelement("trans_fee_amount", com_api_currency_pkg.get_amount_str(nvl(trans_fee_amount, 0), trans_currency, com_api_type_pkg.TRUE))   
                              , xmlelement("acq_inst_code", acq_inst_code)      
                              , xmlelement("iss_inst_code", iss_inst_code)        
                              , xmlelement("bnb_inst_code", bnb_inst_code)     
                              , xmlelement("rrn",    rrn)            
                              , xmlelement("auth_number",  auth_number)      
                              , xmlelement("resp_code", resp_code)               
                              , xmlelement("terminal_id",  terminal_id)      
                              , xmlelement("trans_currency", trans_currency)    
                              , xmlelement("settl_currency", settl_currency)    
                              , xmlelement("crdh_bill_currency", crdh_bill_currency)
                              , xmlelement("from_account_id", from_account_id)   
                              , xmlelement("to_account_id", to_account_id)     
                              , xmlelement("nbc_fee", com_api_currency_pkg.get_amount_str(nvl(nbc_fee, 0), trans_currency, com_api_type_pkg.TRUE))           
                              , xmlelement("acq_fee", com_api_currency_pkg.get_amount_str(nvl(acq_fee, 0), trans_currency, com_api_type_pkg.TRUE))           
                              , xmlelement("iss_fee", com_api_currency_pkg.get_amount_str(nvl(iss_fee, 0), trans_currency, com_api_type_pkg.TRUE))           
                              , xmlelement("bnb_fee", com_api_currency_pkg.get_amount_str(nvl(bnb_fee, 0), trans_currency, com_api_type_pkg.TRUE))           
                              , xmlelement("mti", mti)
                            )
                            order by
                              is_incoming
                            , participant_type
                            , id 
                        )
                    )
                into
                    l_detail
                from (
                    select m.id 
                        , m.record_type
                        , m.is_incoming
                        , m.participant_type
                        , m.nbc_resp_code   
                        , m.acq_resp_code   
                        , m.iss_resp_code   
                        , m.bnb_resp_code   
                        , m.dispute_trans_result    
                        , trim('0' from c.card_number) card_number
                        , m.proc_code
                        , m.trans_amount
                        , m.sttl_amount
                        , m.crdh_bill_amount
                        , m.crdh_bill_fee      
                        , m.settl_rate       
                        , m.crdh_bill_rate   
                        , m.system_trace_number
                        , m.local_trans_time   
                        , m.local_trans_date   
                        , m.settlement_date    
                        , m.merchant_type      
                        , m.trans_fee_amount   
                        , m.acq_inst_code      
                        , m.iss_inst_code      
                        , m.bnb_inst_code      
                        , m.rrn                
                        , m.auth_number        
                        , m.resp_code                
                        , m.terminal_id        
                        , m.trans_currency     
                        , m.settl_currency     
                        , m.crdh_bill_currency 
                        , m.from_account_id    
                        , m.to_account_id      
                        , m.nbc_fee            
                        , m.acq_fee            
                        , m.iss_fee            
                        , m.bnb_fee            
                        , m.mti
                     from nbc_fin_message m
                        , nbc_card c 
                    where m.is_incoming = com_api_type_pkg.TRUE
                      and trunc(m.local_trans_date) between l_start_date and l_end_date
                      and m.original_id is null
                      and c.id = m.id
                      and (l_inst_id = 0 or m.inst_id = l_inst_id) 
                    union all
                    select m.id
                        , m.record_type
                        , m.is_incoming
                        , m.participant_type
                        , m.nbc_resp_code   
                        , m.acq_resp_code   
                        , m.iss_resp_code   
                        , m.bnb_resp_code   
                        , m.dispute_trans_result    
                        , trim('0' from c.card_number) card_number
                        , m.proc_code
                        , m.trans_amount
                        , m.sttl_amount
                        , m.crdh_bill_amount
                        , m.crdh_bill_fee      
                        , m.settl_rate       
                        , m.crdh_bill_rate   
                        , m.system_trace_number
                        , m.local_trans_time   
                        , m.local_trans_date   
                        , m.settlement_date    
                        , m.merchant_type      
                        , m.trans_fee_amount   
                        , m.acq_inst_code      
                        , m.iss_inst_code      
                        , m.bnb_inst_code      
                        , m.rrn                
                        , m.auth_number        
                        , m.resp_code                
                        , m.terminal_id        
                        , m.trans_currency     
                        , m.settl_currency     
                        , m.crdh_bill_currency 
                        , m.from_account_id    
                        , m.to_account_id      
                        , m.nbc_fee            
                        , m.acq_fee            
                        , m.iss_fee            
                        , m.bnb_fee            
                        , m.mti
                     from nbc_fin_message m 
                     left join nbc_fin_message in_msg on in_msg.original_id = m.original_id 
                                                     and in_msg.is_incoming = com_api_type_pkg.TRUE
                                                     and trunc(m.local_trans_date) between l_start_date and l_end_date
                                                     and (l_inst_id = 0 or in_msg.inst_id = l_inst_id)
                        , nbc_card c
                    where m.is_incoming = com_api_type_pkg.FALSE    
                      and trunc(m.local_trans_date) between l_start_date and l_end_date
                      and (l_inst_id = 0 or m.inst_id = l_inst_id)
                      and c.id = m.id
                      and in_msg.id is null 
                );
            when 'NBCRDISP' then            
                select
                    xmlelement("messages"
                      , xmlagg(
                            xmlelement("message"
                              , xmlelement("id", id)
                              , xmlelement("record_type", record_type)
                              , xmlelement("nbc_resp_code", nbc_resp_code)  
                              , xmlelement("acq_resp_code", acq_resp_code)  
                              , xmlelement("iss_resp_code", iss_resp_code)  
                              , xmlelement("bnb_resp_code", bnb_resp_code)  
                              , xmlelement("dispute_trans_result", dispute_trans_result)                          
                              , xmlelement("participant_type", participant_type) 
                              , xmlelement("card_number", card_number) 
                              , xmlelement("proc_code", proc_code)
                              , xmlelement("trans_amount", com_api_currency_pkg.get_amount_str(nvl(trans_amount, 0), trans_currency, com_api_type_pkg.TRUE))
                              , xmlelement("sttl_amount", case when sttl_amount is null then ''
                                                               else com_api_currency_pkg.get_amount_str(nvl(sttl_amount, 0), settl_currency, com_api_type_pkg.TRUE, null, com_api_type_pkg.TRUE)
                                                          end)      
                              , xmlelement("crdh_bill_amount", case when crdh_bill_amount is null then ''
                                                                    else com_api_currency_pkg.get_amount_str(nvl(crdh_bill_amount, 0), crdh_bill_currency, com_api_type_pkg.TRUE, null, com_api_type_pkg.TRUE)
                                                               end)
                              , xmlelement("crdh_bill_fee", case when crdh_bill_fee is null then ''
                                                                 else com_api_currency_pkg.get_amount_str(nvl(crdh_bill_fee, 0), crdh_bill_currency, com_api_type_pkg.TRUE, null, com_api_type_pkg.TRUE)
                                                            end)                                    
                              , xmlelement("settl_rate", settl_rate)       
                              , xmlelement("crdh_bill_rate", crdh_bill_rate)   
                              , xmlelement("system_trace_number", system_trace_number)
                              , xmlelement("local_trans_time", local_trans_time)  
                              , xmlelement("local_trans_date", to_char(local_trans_date, 'dd.mm.yyyy')) 
                              , xmlelement("settlement_date", to_char(settlement_date, 'dd.mm.yyyy'))    
                              , xmlelement("merchant_type", merchant_type)      
                              , xmlelement("trans_fee_amount", com_api_currency_pkg.get_amount_str(nvl(trans_fee_amount, 0), trans_currency, com_api_type_pkg.TRUE))   
                              , xmlelement("acq_inst_code", acq_inst_code)      
                              , xmlelement("iss_inst_code", iss_inst_code)        
                              , xmlelement("bnb_inst_code", bnb_inst_code)     
                              , xmlelement("rrn",    rrn)            
                              , xmlelement("auth_number",  auth_number)      
                              , xmlelement("resp_code", resp_code)               
                              , xmlelement("terminal_id",  terminal_id)      
                              , xmlelement("trans_currency", trans_currency)    
                              , xmlelement("settl_currency", settl_currency)    
                              , xmlelement("crdh_bill_currency", crdh_bill_currency)
                              , xmlelement("from_account_id", from_account_id)   
                              , xmlelement("to_account_id", to_account_id)     
                              , xmlelement("nbc_fee", com_api_currency_pkg.get_amount_str(nvl(nbc_fee, 0), trans_currency, com_api_type_pkg.TRUE))           
                              , xmlelement("acq_fee", com_api_currency_pkg.get_amount_str(nvl(acq_fee, 0), trans_currency, com_api_type_pkg.TRUE))           
                              , xmlelement("iss_fee", com_api_currency_pkg.get_amount_str(nvl(iss_fee, 0), trans_currency, com_api_type_pkg.TRUE))           
                              , xmlelement("bnb_fee", com_api_currency_pkg.get_amount_str(nvl(bnb_fee, 0), trans_currency, com_api_type_pkg.TRUE))           
                              , xmlelement("mti", mti)
                            )
                            order by
                              participant_type
                            , id 
                        )
                    )
                into
                    l_detail
                from (
                    select m.id 
                        , m.record_type
                        , m.participant_type
                        , m.nbc_resp_code   
                        , m.acq_resp_code   
                        , m.iss_resp_code   
                        , m.bnb_resp_code   
                        , m.dispute_trans_result    
                        , trim('0' from c.card_number) card_number
                        , m.proc_code
                        , m.trans_amount
                        , m.sttl_amount
                        , m.crdh_bill_amount
                        , m.crdh_bill_fee      
                        , m.settl_rate       
                        , m.crdh_bill_rate   
                        , m.system_trace_number
                        , m.local_trans_time   
                        , m.local_trans_date   
                        , m.settlement_date    
                        , m.merchant_type      
                        , m.trans_fee_amount   
                        , m.acq_inst_code      
                        , m.iss_inst_code      
                        , m.bnb_inst_code      
                        , m.rrn                
                        , m.auth_number        
                        , m.resp_code                
                        , m.terminal_id        
                        , m.trans_currency     
                        , m.settl_currency     
                        , m.crdh_bill_currency 
                        , m.from_account_id    
                        , m.to_account_id      
                        , m.nbc_fee            
                        , m.acq_fee            
                        , m.iss_fee            
                        , m.bnb_fee            
                        , m.mti
                     from nbc_fin_message m 
                        , nbc_card c
                    where c.id               = m.id
                      and trunc(m.local_trans_date) between l_start_date and l_end_date
                      and (l_inst_id = 0 or m.inst_id = l_inst_id)
                      and m.participant_type = 'DSP'
                );
        end case;

    exception
        when no_data_found then
            select
                xmlelement("messages", '')
            into
                l_detail
            from
                dual;

            trc_log_pkg.debug (
                i_text  => 'Messages not found'
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
    
    trc_log_pkg.debug (
         i_text => 'nbc_api_report_pkg.detail_report - ok'
    );

exception
    when others then
        trc_log_pkg.debug (
            i_text   => sqlerrm
        );
        raise;
end detail_report;

procedure total_report (
    o_xml                out       clob
    , i_inst_id          in        com_api_type_pkg.t_inst_id  default null
    , i_start_date       in        date                        default null 
    , i_end_date         in        date                        default null 
    , i_mode             in        com_api_type_pkg.t_dict_value  
    , i_lang             in        com_api_type_pkg.t_dict_value
) is
    l_inst_id                      com_api_type_pkg.t_inst_id;
    l_agent_id                     com_api_type_pkg.t_agent_id;
    l_start_date                   date;
    l_end_date                     date;
    l_lang                         com_api_type_pkg.t_dict_value;
    l_header                       xmltype;
    l_detail                       xmltype;
    l_result                       xmltype;
    l_caption                      com_api_type_pkg.t_name;
     
begin
    trc_log_pkg.debug (
        i_text          => 'nbc_api_report_pkg.total_report [#1][#2][#3][#4]'
        , i_env_param1  => i_inst_id
        , i_env_param2  => com_api_type_pkg.convert_to_char(trunc(nvl(i_start_date, com_api_sttl_day_pkg.get_sysdate)))
        , i_env_param3  => com_api_type_pkg.convert_to_char(nvl(trunc(i_end_date), l_start_date) + 1 - com_api_const_pkg.ONE_SECOND)
        , i_env_param4  => i_mode
    );

    l_lang := nvl(i_lang, get_user_lang);
    l_start_date := trunc(nvl(i_start_date, com_api_sttl_day_pkg.get_sysdate));
    l_end_date := nvl(trunc(i_end_date), l_start_date) + 1 - com_api_const_pkg.ONE_SECOND;
    l_inst_id := nvl(i_inst_id, 0);

    l_caption := case when i_mode = 'NBCRRMCH' then 'REPORT OF SUMMARY MATCH TRANSACTIONS'
                      when i_mode = 'NBCRRMSM' then 'REPORT OF SUMMARY MISMATCH TRANSACTIONS'
                      else 'REPORT OF SUMMARY DISPUTE TRANSACTIONS'
                 end;  

    -- header
    select
        xmlconcat(
            xmlelement("inst_id", l_inst_id)
            , xmlelement("inst", com_api_i18n_pkg.get_text('OST_INSTITUTION','NAME', l_inst_id, l_lang))
            , xmlelement("start_date", to_char(l_start_date, 'dd.mm.yyyy'))
            , xmlelement("end_date", to_char(l_end_date, 'dd.mm.yyyy'))
            , xmlelement("caption", l_caption)
            , xmlelement("mode", i_mode)
        )
    into
        l_header
            from dual;
            
    -- detail            
    begin
        case i_mode
            when 'NBCRRMCH' then            
                select
                    xmlelement("messages"
                      , xmlagg(
                            xmlelement("message"
                              , xmlelement("trans_date", to_char(trans_date, 'dd.mm.yyyy')) 
                              , xmlelement("acq_inst_code", acq_inst_code)      
                              , xmlelement("iss_inst_code", iss_inst_code)                              
                              , xmlelement("total_atm_count", total_atm_count)      
                              , xmlelement("total_pos_count", total_pos_count)    
                              , xmlelement("total_atm_amount", com_api_currency_pkg.get_amount_str(nvl(total_atm_amount, 0), trans_currency, com_api_type_pkg.TRUE))
                              , xmlelement("total_pos_amount", com_api_currency_pkg.get_amount_str(nvl(total_pos_amount, 0), trans_currency, com_api_type_pkg.TRUE)) 
                              , xmlelement("trans_currency", trans_currency)    
                            )
                            order by
                                  trans_date
                                , acq_inst_code      
                                , iss_inst_code 
                        )
                    )
                into
                    l_detail
                from (
                      select trunc(m.local_trans_date) trans_date
                            , m.acq_inst_code      
                            , m.iss_inst_code 
                            , count(case when m.merchant_type = '6011' then 1 else null end) total_atm_count
                            , count(case when m.merchant_type = '6012' then 1 else null end) total_pos_count
                            , sum(case when m.merchant_type = '6011' then m.trans_amount else 0 end) total_atm_amount  
                            , sum(case when m.merchant_type = '6012' then m.trans_amount else 0 end) total_pos_amount  
                            , m.trans_currency    
                         from nbc_fin_message m 
                            , nbc_fin_message out_msg 
                            , nbc_card c
                        where trunc(m.local_trans_date) between l_start_date and l_end_date
                          and (l_inst_id = 0 or m.inst_id = l_inst_id) 
                          and m.is_incoming       = com_api_type_pkg.TRUE
                          and out_msg.is_incoming = com_api_type_pkg.FALSE
                          and (l_inst_id = 0 or out_msg.inst_id = l_inst_id)
                          and m.original_id       = out_msg.original_id
                          and c.id                = m.id                  
                        group by 
                              trunc(m.local_trans_date)
                            , m.acq_inst_code      
                            , m.iss_inst_code 
                            , m.trans_currency              
                );
            when 'NBCRRMSM' then
                select
                    xmlelement("messages"
                      , xmlagg(
                            xmlelement("message"
                              , xmlelement("trans_date", to_char(trans_date, 'dd.mm.yyyy')) 
                              , xmlelement("acq_inst_code", acq_inst_code)      
                              , xmlelement("iss_inst_code", iss_inst_code)                              
                              , xmlelement("total_atm_count", total_atm_count)      
                              , xmlelement("total_pos_count", total_pos_count)    
                              , xmlelement("total_atm_amount", com_api_currency_pkg.get_amount_str(nvl(total_atm_amount, 0), trans_currency, com_api_type_pkg.TRUE))
                              , xmlelement("total_pos_amount", com_api_currency_pkg.get_amount_str(nvl(total_pos_amount, 0), trans_currency, com_api_type_pkg.TRUE)) 
                              , xmlelement("trans_currency", trans_currency)    
                            )
                            order by
                                  trans_date
                                , acq_inst_code      
                                , iss_inst_code 
                        )
                    )
                into
                    l_detail
                from (
                    select t.trans_date
                         , t.acq_inst_code      
                         , t.iss_inst_code 
                         , sum(t.total_atm_count) total_atm_count
                         , sum(t.total_atm_amount) total_atm_amount  
                         , sum(t.total_pos_count) total_pos_count
                         , sum(t.total_pos_amount) total_pos_amount  
                         , t.trans_currency
                      from (       
                        select trunc(m.local_trans_date) trans_date
                             , m.acq_inst_code      
                             , m.iss_inst_code 
                             , count(case when m.merchant_type = '6011' then 1 else null end) total_atm_count
                             , count(case when m.merchant_type = '6012' then 1 else null end) total_pos_count
                             , sum(case when m.merchant_type = '6011' then m.trans_amount else 0 end) total_atm_amount  
                             , sum(case when m.merchant_type = '6012' then m.trans_amount else 0 end) total_pos_amount  
                             , m.trans_currency    
                         from nbc_fin_message m
                            , nbc_card c 
                        where m.is_incoming = com_api_type_pkg.TRUE
                          and trunc(m.local_trans_date) between l_start_date and l_end_date
                          and m.original_id is null
                          and c.id = m.id
                          and (l_inst_id = 0 or m.inst_id = l_inst_id) 
                        group by 
                              trunc(m.local_trans_date)
                            , m.acq_inst_code      
                            , m.iss_inst_code 
                            , m.trans_currency              
                        union all
                       select trunc(m.local_trans_date)
                            , m.acq_inst_code      
                            , m.iss_inst_code 
                            , count(case when m.merchant_type = '6011' then 1 else null end) total_atm_count
                            , count(case when m.merchant_type = '6012' then 1 else null end) total_pos_count
                            , sum(case when m.merchant_type = '6011' then m.trans_amount else 0 end) total_atm_amount  
                            , sum(case when m.merchant_type = '6012' then m.trans_amount else 0 end) total_pos_amount  
                            , m.trans_currency    
                         from nbc_fin_message m 
                         left join nbc_fin_message in_msg on in_msg.original_id = m.original_id 
                                                         and in_msg.is_incoming = com_api_type_pkg.TRUE
                                                         and trunc(m.local_trans_date) between l_start_date and l_end_date
                                                         and (l_inst_id = 0 or in_msg.inst_id = l_inst_id)
                            , nbc_card c
                        where m.is_incoming = com_api_type_pkg.FALSE    
                          and trunc(m.local_trans_date) between l_start_date and l_end_date
                          and (l_inst_id = 0 or m.inst_id = l_inst_id)
                          and c.id = m.id
                          and in_msg.id is null 
                        group by 
                              trunc(m.local_trans_date)
                            , m.acq_inst_code      
                            , m.iss_inst_code 
                            , m.trans_currency    
                       ) t
                    group by 
                          t.trans_date
                        , t.acq_inst_code      
                        , t.iss_inst_code 
                        , t.trans_currency                  
                );
            when 'NBCRDISP' then            
                select
                    xmlelement("messages"
                      , xmlagg(
                            xmlelement("message"
                              , xmlelement("trans_date", to_char(trans_date, 'dd.mm.yyyy')) 
                              , xmlelement("acq_inst_code", acq_inst_code)      
                              , xmlelement("iss_inst_code", iss_inst_code)                              
                              , xmlelement("total_atm_count", total_atm_count)      
                              , xmlelement("total_pos_count", total_pos_count)    
                              , xmlelement("total_atm_amount", com_api_currency_pkg.get_amount_str(nvl(total_atm_amount, 0), trans_currency, com_api_type_pkg.TRUE))
                              , xmlelement("total_pos_amount", com_api_currency_pkg.get_amount_str(nvl(total_pos_amount, 0), trans_currency, com_api_type_pkg.TRUE)) 
                              , xmlelement("trans_currency", trans_currency)    
                            )
                            order by
                                  trans_date
                                , acq_inst_code      
                                , iss_inst_code 
                        )
                    )
                into
                    l_detail
                from (
                      select trunc(m.local_trans_date) trans_date
                            , m.acq_inst_code      
                            , m.iss_inst_code 
                            , count(case when m.merchant_type = '6011' then 1 else null end) total_atm_count
                            , count(case when m.merchant_type = '6012' then 1 else null end) total_pos_count
                            , sum(case when m.merchant_type = '6011' then m.trans_amount else 0 end) total_atm_amount  
                            , sum(case when m.merchant_type = '6012' then m.trans_amount else 0 end) total_pos_amount  
                            , m.trans_currency    
                         from nbc_fin_message m 
                            , nbc_card c
                        where c.id               = m.id
                          and trunc(m.local_trans_date) between l_start_date and l_end_date
                          and (l_inst_id = 0 or m.inst_id = l_inst_id)
                          and m.participant_type = 'DSP'
                        group by 
                              trunc(m.local_trans_date)
                            , m.acq_inst_code      
                            , m.iss_inst_code 
                            , m.trans_currency              
                        order by 
                              trunc(m.local_trans_date)
                            , m.acq_inst_code      
                            , m.iss_inst_code 
                );
        end case;

    exception
        when no_data_found then
            select
                xmlelement("messages", '')
            into
                l_detail
            from
                dual;

            trc_log_pkg.debug (
                i_text  => 'Messages not found'
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
            
    trc_log_pkg.debug (
         i_text => 'nbc_api_report_pkg.total_report - ok'
    );

exception
    when others then
        trc_log_pkg.debug (
            i_text   => sqlerrm
        );
        raise;
end total_report;


end nbc_api_report_pkg;
/
