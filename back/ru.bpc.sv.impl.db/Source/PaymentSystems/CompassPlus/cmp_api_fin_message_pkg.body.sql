create or replace package body cmp_api_fin_message_pkg as

g_column_list           com_api_type_pkg.t_text :=
    'f.id'
||  ', f.card_id'
||  ', f.card_hash'
||  ', f.card_mask'
||  ', iss_api_token_pkg.decode_card_number(i_card_number => c.card_number) as card_number'
||  ', f.file_id'
||  ', f.inst_id'
||  ', f.network_id'
||  ', f.host_inst_id'
||  ', f.msg_number'
||  ', f.is_reversal'
||  ', f.is_incoming'
||  ', f.is_rejected'
||  ', f.is_invalid'
||  ', f.tran_code'
||  ', f.conversion_rate'
||  ', f.ext_stan'
||  ', f.orig_time'                
||  ', f.capability'    
||  ', f.tran_type'
||  ', f.tran_class'        
||  ', f.term_class'        
||  ', f.mcc'
||  ', f.arn'         
||  ', f.ext_fid'        
||  ', f.tran_number'         
||  ', f.approval_code'
||  ', f.term_name'
||  ', f.term_retailer_name'
||  ', f.ext_term_retailer_name' 
||  ', f.term_city'
||  ', f.term_location'
||  ', f.term_owner'
||  ', f.term_country' 
||  ', f.amount'
||  ', f.reconcil_amount'        
||  ', f.orig_amount'
||  ', f.currency'
||  ', f.reconcil_currency'        
||  ', f.orig_currency'
||  ', f.pay_amount'
||  ', f.pay_currency'
||  ', f.term_inst_id'
||  ', f.status'
||  ', f.term_zip'
||  ', f.exp_date'
||  ', f.network'       
||  ', f.host_net_id'
||  ', f.ext_tran_attr'
||  ', f.term_inst_country'
||  ', f.pos_condition'
||  ', f.pos_entry_mode'
||  ', f.pin_presence'
||  ', f.term_entry_caps'
||  ', f.host_time'      
||  ', f.ext_ps_fields'
||  ', f.term_contactless_capable' 
||  ', f.final_rrn'
||  ', f.from_acct_type'
||  ', f.aid'
||  ', f.orig_fi_name'
||  ', f.dest_fi_name'
||  ', f.clear_date'
||  ', f.card_member'
||  ', f.icc_term_caps'
||  ', f.icc_tvr'
||  ', f.icc_random'
||  ', f.icc_term_sn'
||  ', f.icc_issuer_data'
||  ', f.icc_cryptogram'
||  ', f.icc_app_tran_count'
||  ', f.icc_term_tran_count'
||  ', f.icc_app_profile'
||  ', f.icc_iad'
||  ', f.icc_tran_type' 
||  ', f.icc_term_country'
||  ', f.icc_tran_date' 
||  ', f.icc_amount'
||  ', f.icc_currency'
||  ', f.icc_cb_amount'
||  ', f.icc_crypt_inform_data'
||  ', f.icc_cvm_res'
||  ', f.icc_card_member'        
||  ', f.icc_respcode'       
||  ', f.emv_data_exists'   
||  ', f.collect_only_flag'     
||  ', f.service_code' 
;

function put_message (
    i_fin_rec               in cmp_api_type_pkg.t_cmp_fin_mes_rec
) return com_api_type_pkg.t_long_id
is
    l_id                    com_api_type_pkg.t_long_id;
begin
    trc_log_pkg.debug (
        i_text         => 'cmp_api_fin_message_pkg.put_message start'
    );

    l_id := nvl(i_fin_rec.id, opr_api_create_pkg.get_id);

    insert into cmp_fin_message (
        id                           
        , file_id                    
        , inst_id                            
        , network_id                  
        , host_inst_id                           
        , msg_number                 
        , is_reversal                
        , is_incoming                
        , is_rejected                
        , is_invalid                 
        , card_id                    
        , card_mask                  
        , card_hash                  
        , tran_code                  
        , conversion_rate             
        , ext_stan                    
        , orig_time                          
        , capability                     
        , tran_type                  
        , tran_class                 
        , term_class                         
        , mcc                        
        , arn                                 
        , ext_fid                             
        , tran_number                         
        , approval_code              
        , term_name                  
        , term_retailer_name         
        , ext_term_retailer_name      
        , term_city                  
        , term_location              
        , term_owner                 
        , term_country               
        , term_zip                   
        , exp_date                       
        , amount                     
        , reconcil_amount                    
        , orig_amount                
        , currency                   
        , reconcil_currency                  
        , orig_currency              
        , pay_amount                         
        , pay_currency                       
        , term_inst_id               
        , status                     
        , network                            
        , host_net_id                
        , ext_tran_attr              
        , term_inst_country          
        , pos_condition              
        , pos_entry_mode             
        , pin_presence               
        , term_entry_caps            
        , host_time                        
        , ext_ps_fields               
        , term_contactless_capable    
        , final_rrn                   
        , from_acct_type             
        , aid                        
        , orig_fi_name                
        , dest_fi_name               
        , clear_date                 
        , card_member                
        , icc_term_caps              
        , icc_tvr                    
        , icc_random                 
        , icc_term_sn                
        , icc_issuer_data            
        , icc_cryptogram             
        , icc_app_tran_count         
        , icc_term_tran_count        
        , icc_app_profile            
        , icc_iad                    
        , icc_tran_type               
        , icc_term_country           
        , icc_tran_date               
        , icc_amount                 
        , icc_currency               
        , icc_cb_amount              
        , icc_crypt_inform_data      
        , icc_cvm_res                
        , icc_card_member  
        , icc_respcode
        , emv_data_exists      
        , collect_only_flag    
        , service_code   
    ) values (
        l_id
        , i_fin_rec.file_id                    
        , i_fin_rec.inst_id                            
        , i_fin_rec.network_id                  
        , i_fin_rec.host_inst_id                           
        , i_fin_rec.msg_number                 
        , i_fin_rec.is_reversal                
        , i_fin_rec.is_incoming                
        , i_fin_rec.is_rejected                
        , i_fin_rec.is_invalid                 
        , i_fin_rec.card_id                    
        , i_fin_rec.card_mask                  
        , i_fin_rec.card_hash                  
        , i_fin_rec.tran_code                  
        , i_fin_rec.conversion_rate             
        , i_fin_rec.ext_stan                    
        , i_fin_rec.orig_time                          
        , i_fin_rec.capability                     
        , i_fin_rec.tran_type                  
        , i_fin_rec.tran_class                 
        , i_fin_rec.term_class                         
        , i_fin_rec.mcc                        
        , i_fin_rec.arn                                 
        , i_fin_rec.ext_fid                             
        , i_fin_rec.tran_number                         
        , i_fin_rec.approval_code              
        , i_fin_rec.term_name                  
        , i_fin_rec.term_retailer_name         
        , i_fin_rec.ext_term_retailer_name      
        , i_fin_rec.term_city                  
        , i_fin_rec.term_location              
        , i_fin_rec.term_owner                 
        , i_fin_rec.term_country               
        , i_fin_rec.term_zip                   
        , i_fin_rec.exp_date                       
        , i_fin_rec.amount                     
        , i_fin_rec.reconcil_amount                    
        , i_fin_rec.orig_amount                
        , i_fin_rec.currency                   
        , i_fin_rec.reconcil_currency                  
        , i_fin_rec.orig_currency              
        , i_fin_rec.pay_amount                         
        , i_fin_rec.pay_currency                       
        , i_fin_rec.term_inst_id               
        , i_fin_rec.status                     
        , i_fin_rec.network                            
        , i_fin_rec.host_net_id                
        , i_fin_rec.ext_tran_attr              
        , i_fin_rec.term_inst_country          
        , i_fin_rec.pos_condition              
        , i_fin_rec.pos_entry_mode             
        , i_fin_rec.pin_presence               
        , i_fin_rec.term_entry_caps            
        , i_fin_rec.host_time                        
        , i_fin_rec.ext_ps_fields               
        , i_fin_rec.term_contactless_capable    
        , i_fin_rec.final_rrn                   
        , i_fin_rec.from_acct_type             
        , i_fin_rec.aid                        
        , i_fin_rec.orig_fi_name                
        , i_fin_rec.dest_fi_name               
        , i_fin_rec.clear_date                 
        , i_fin_rec.card_member                
        , i_fin_rec.icc_term_caps              
        , i_fin_rec.icc_tvr                    
        , i_fin_rec.icc_random                 
        , i_fin_rec.icc_term_sn                
        , i_fin_rec.icc_issuer_data            
        , i_fin_rec.icc_cryptogram             
        , i_fin_rec.icc_app_tran_count         
        , i_fin_rec.icc_term_tran_count        
        , i_fin_rec.icc_app_profile            
        , i_fin_rec.icc_iad                    
        , i_fin_rec.icc_tran_type               
        , i_fin_rec.icc_term_country           
        , i_fin_rec.icc_tran_date               
        , i_fin_rec.icc_amount                 
        , i_fin_rec.icc_currency               
        , i_fin_rec.icc_cb_amount              
        , i_fin_rec.icc_crypt_inform_data      
        , i_fin_rec.icc_cvm_res                
        , i_fin_rec.icc_card_member     
        , i_fin_rec.icc_respcode  
        , i_fin_rec.emv_data_exists  
        , i_fin_rec.collect_only_flag     
        , i_fin_rec.service_code 
    );

    insert into cmp_card (
        id
        , card_number
    ) values (
        l_id
        , iss_api_token_pkg.encode_card_number(i_card_number => i_fin_rec.card_number)
    );

    trc_log_pkg.debug (
        i_text          => 'flush_messages: implemented [#1] CMP fin messages'
        , i_env_param1  => l_id
    );

    return l_id;
end;

procedure create_operation (
    i_oper                  in opr_api_type_pkg.t_oper_rec
    , i_iss_part            in opr_api_type_pkg.t_oper_part_rec
    , i_acq_part            in opr_api_type_pkg.t_oper_part_rec
)is
    l_oper_id               com_api_type_pkg.t_long_id := i_oper.id;
begin
    trc_log_pkg.debug (
        i_text         => 'cmp_api_fin_message_pkg.create_operation start'
    );

    opr_api_create_pkg.create_operation (
        io_oper_id             => l_oper_id
        , i_session_id         => get_session_id
        , i_status             => nvl(i_oper.status, opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY)
        , i_status_reason      => i_oper.status_reason
        , i_sttl_type          => i_oper.sttl_type
        , i_msg_type           => i_oper.msg_type
        , i_oper_type          => i_oper.oper_type
        , i_oper_reason        => i_oper.oper_reason
        , i_is_reversal        => i_oper.is_reversal
        , i_oper_amount        => i_oper.oper_amount
        , i_oper_currency      => i_oper.oper_currency
        , i_sttl_amount        => i_oper.sttl_amount
        , i_sttl_currency      => i_oper.sttl_currency
        , i_oper_date          => i_oper.oper_date
        , i_host_date          => i_oper.host_date
        , i_terminal_type      => i_oper.terminal_type
        , i_mcc                => i_oper.mcc
        , i_originator_refnum  => i_oper.originator_refnum
        , i_acq_inst_bin       => i_oper.acq_inst_bin
        , i_merchant_number    => i_oper.merchant_number
        , i_terminal_number    => i_oper.terminal_number
        , i_merchant_name      => i_oper.merchant_name
        , i_merchant_street    => i_oper.merchant_street
        , i_merchant_city      => i_oper.merchant_city
        , i_merchant_region    => i_oper.merchant_region
        , i_merchant_country   => i_oper.merchant_country
        , i_merchant_postcode  => i_oper.merchant_postcode
        , i_dispute_id         => i_oper.dispute_id
        , i_match_status       => i_oper.match_status
        , i_original_id        => i_oper.original_id
        , i_proc_mode          => i_oper.proc_mode
        , i_incom_sess_file_id => i_oper.incom_sess_file_id
    );

    opr_api_create_pkg.add_participant (
        i_oper_id             => l_oper_id
        , i_msg_type          => i_oper.msg_type
        , i_oper_type         => i_oper.oper_type
        , i_participant_type  => com_api_const_pkg.PARTICIPANT_ISSUER
        , i_host_date         => i_oper.host_date
        , i_inst_id           => i_iss_part.inst_id
        , i_network_id        => i_iss_part.network_id
        , i_customer_id       => i_iss_part.customer_id
        , i_client_id_type    => opr_api_const_pkg.CLIENT_ID_TYPE_CARD
        , i_client_id_value   => i_iss_part.card_number
        , i_card_id           => i_iss_part.card_id
        , i_card_type_id      => i_iss_part.card_type_id
        , i_card_expir_date   => i_iss_part.card_expir_date
        , i_card_seq_number   => i_iss_part.card_seq_number
        , i_card_number       => i_iss_part.card_number
        , i_card_mask         => i_iss_part.card_mask
        , i_card_hash         => i_iss_part.card_hash
        , i_card_country      => i_iss_part.card_country
        , i_card_inst_id      => i_iss_part.card_inst_id
        , i_card_network_id   => i_iss_part.card_network_id
        , i_account_id        => null
        , i_account_number    => null
        , i_account_amount    => null
        , i_account_currency  => null
        , i_auth_code         => i_iss_part.auth_code
        , i_split_hash        => i_iss_part.split_hash
        , i_without_checks    => com_api_const_pkg.TRUE
    );

    opr_api_create_pkg.add_participant (
        i_oper_id             => l_oper_id
        , i_msg_type          => i_oper.msg_type
        , i_oper_type         => i_oper.oper_type
        , i_participant_type  => com_api_const_pkg.PARTICIPANT_ACQUIRER
        , i_host_date         => i_oper.host_date
        , i_inst_id           => i_acq_part.inst_id
        , i_network_id        => i_acq_part.network_id
        , i_merchant_id       => null
        , i_terminal_id       => null
        , i_terminal_number   => i_oper.terminal_number
        , i_split_hash        => null
        , i_without_checks    => com_api_const_pkg.TRUE
    );
    trc_log_pkg.debug (
        i_text         => 'cmp_api_fin_message_pkg.create_operation end'
    );
end;

procedure create_operation (
    i_fin_rec               in cmp_api_type_pkg.t_cmp_fin_mes_rec
    , i_standard_id         in com_api_type_pkg.t_tiny_id
)is
begin
    null;
end;

procedure get_fin (
    i_id                    in com_api_type_pkg.t_long_id
    , o_fin_rec             out cmp_api_type_pkg.t_cmp_fin_mes_rec
    , i_mask_error          in com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
) is
    l_fin_cur               sys_refcursor;
    l_statemet              com_api_type_pkg.t_text;
begin
    l_statemet := '
select
' || g_column_list || '
from
cmp_fin_message f
, cmp_card c
where
f.id = :i_id
and f.id = c.id(+)';
    open l_fin_cur for l_statemet using i_id;
    fetch l_fin_cur into o_fin_rec;
    close l_fin_cur;

    if o_fin_rec.id is null then
        if i_mask_error = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_error (
                i_error         => 'FINANCIAL_MESSAGE_NOT_FOUND'
                , i_env_param1  => i_id
            );
        else
            trc_log_pkg.error (
                i_text          => 'FINANCIAL_MESSAGE_NOT_FOUND'
                , i_env_param1  => i_id
            );
        end if;
    end if;
exception
    when others then
        if l_fin_cur%isopen then
            close l_fin_cur;
        end if;
        raise;
end;

procedure process_auth (
    i_auth_rec     in     aut_api_type_pkg.t_auth_rec
  , i_inst_id      in     com_api_type_pkg.t_inst_id default null
  , i_network_id   in     com_api_type_pkg.t_tiny_id default null
  , i_collect_only in     com_api_type_pkg.t_boolean default null
  , i_status       in     com_api_type_pkg.t_dict_value default null
  , io_fin_mess_id in out com_api_type_pkg.t_long_id
)is
    l_fin_rec             cmp_api_type_pkg.t_cmp_fin_mes_rec;
    l_original_rec        cmp_api_type_pkg.t_cmp_fin_mes_rec;
    l_host_id             com_api_type_pkg.t_tiny_id;
    l_standard_id         com_api_type_pkg.t_tiny_id;
    l_param_tab           com_api_type_pkg.t_param_tab;
    l_emv_tag_tab         com_api_type_pkg.t_tag_value_tab;
    l_is_binary           com_api_type_pkg.t_boolean;
    l_acquirer_bin        com_api_type_pkg.t_rrn;
    l_pos_data_code_2     com_api_type_pkg.t_dict_value;         
    l_pos_data_code_7     com_api_type_pkg.t_dict_value;   
    l_tag_id              com_api_type_pkg.t_short_id;
    l_tag_value           com_api_type_pkg.t_text;
    l_mask_emv_tag_error  com_api_type_pkg.t_boolean         := com_api_type_pkg.FALSE;
    l_standard_version_id com_api_type_pkg.t_tiny_id;
    l_network_oper_type   com_api_type_pkg.t_dict_value;
    
    function get_arn (
        i_tran_code   in com_api_type_pkg.t_mcc
    ) return com_api_type_pkg.t_name is
        l_result com_api_type_pkg.t_name;
    begin
        select acq_bin
          into l_result 
          from cmp_acq_bin
         where tran_code = i_tran_code;
           
        return l_result;
    exception 
        when no_data_found then
            return null;                     
    end;

begin
    trc_log_pkg.debug (
        i_text         => 'cmp_api_fin_message_pkg.process_auth start'
    );
    if io_fin_mess_id is null then
        io_fin_mess_id := opr_api_create_pkg.get_id;
    end if;

    l_fin_rec.id           := io_fin_mess_id;
    l_fin_rec.status       := nvl(i_status, net_api_const_pkg.CLEARING_MSG_STATUS_READY);
    l_fin_rec.is_reversal  := i_auth_rec.is_reversal;
    l_fin_rec.is_incoming  := com_api_type_pkg.FALSE;
    l_fin_rec.is_rejected  := com_api_type_pkg.FALSE;
    l_fin_rec.is_invalid   := com_api_type_pkg.FALSE;
    l_fin_rec.inst_id      := nvl(i_inst_id, i_auth_rec.acq_inst_id);
    l_fin_rec.network_id   := nvl(i_network_id, i_auth_rec.iss_network_id);
    l_fin_rec.host_inst_id := net_api_network_pkg.get_inst_id(l_fin_rec.network_id);

    -- get network communication standard
    l_host_id              := net_api_network_pkg.get_default_host(i_network_id => l_fin_rec.network_id);
    l_standard_id          := net_api_network_pkg.get_offline_standard(i_network_id => l_fin_rec.network_id);

    l_standard_version_id := cmn_api_standard_pkg.get_current_version(
        i_network_id => l_fin_rec.network_id
    );

    trc_log_pkg.debug (
        i_text        => 'process_auth: inst_id[#1] network_id[#2] host_id[#3] standard_id[#4]'
      , i_env_param1  => l_fin_rec.inst_id
      , i_env_param2  => l_fin_rec.network_id
      , i_env_param3  => l_host_id
      , i_env_param4  => l_standard_id
    );

    if length(i_auth_rec.acq_inst_bin) > 11 then
    
        l_fin_rec.term_inst_id := substr(i_auth_rec.acq_inst_bin, -11);
    else
        l_fin_rec.term_inst_id := i_auth_rec.acq_inst_bin;
    end if;    
    
    l_fin_rec.network := case when l_fin_rec.network_id in (cmp_api_const_pkg.VISA_NETWORK, cmp_api_const_pkg.VISA_NETWORK_NSPK) then '11'
                              when l_fin_rec.network_id in (cmp_api_const_pkg.MC_NETWORK, cmp_api_const_pkg.MC_NETWORK_NSPK) then '22'
                              else '1' --TranzWare
                         end;           
    
    l_tag_id    := aup_api_tag_pkg.find_tag_by_reference('DF862F');
    trc_log_pkg.debug (
        i_text          => 'l_tag_id = ' || l_tag_id
    );    
    l_tag_value := aup_api_tag_pkg.get_tag_value(i_auth_id => i_auth_rec.id, i_tag_id => l_tag_id);
    trc_log_pkg.debug (
        i_text          => 'l_tag_value = ' || l_tag_value
    );    

    if l_fin_rec.network_id in (cmp_api_const_pkg.VISA_NETWORK, cmp_api_const_pkg.VISA_NETWORK_NSPK) then
        l_fin_rec.host_net_id   := '0002';
        l_fin_rec.ext_tran_attr := ' ' || l_tag_value;
    else 
        l_fin_rec.host_net_id   := null;
        l_fin_rec.ext_tran_attr := null; 
    end if;
    
    if nvl(i_collect_only, com_api_type_pkg.FALSE) = com_api_type_pkg.TRUE then
        l_fin_rec.collect_only_flag := 'C';
        l_mask_emv_tag_error        := com_api_type_pkg.TRUE;
    end if;
    
    -- check reversal and set mti
    if i_auth_rec.is_reversal = com_api_type_pkg.TRUE then
        if nvl(i_collect_only, com_api_type_pkg.FALSE) = com_api_type_pkg.TRUE then
            l_fin_rec.tran_type := cmp_api_const_pkg.MTID_COLLECT_ONLY_REV;
        else    
            l_fin_rec.tran_type := cmp_api_const_pkg.MTID_PRESENTMENT_REV;
        end if;  

    else
        if nvl(i_collect_only, com_api_type_pkg.FALSE) = com_api_type_pkg.TRUE then
            l_fin_rec.tran_type := cmp_api_const_pkg.MTID_COLLECT_ONLY;
        else    
            l_fin_rec.tran_type := cmp_api_const_pkg.MTID_PRESENTMENT;
        end if;
    end if;
        
    if i_auth_rec.oper_type = opr_api_const_pkg.OPERATION_TYPE_PAYMENT then
        if i_auth_rec.terminal_type = acq_api_const_pkg.TERMINAL_TYPE_POS then
            l_fin_rec.tran_code := '142';
        end if;  
    
    elsif i_auth_rec.oper_type = opr_api_const_pkg.OPERATION_TYPE_PURCHASE then          
        if i_auth_rec.terminal_type = acq_api_const_pkg.TERMINAL_TYPE_POS then
            l_fin_rec.tran_code := '110';
        else
            l_fin_rec.tran_code := '113'; --internet, epos
        end if;  
    else        
        l_network_oper_type := net_api_map_pkg.get_network_type(
                                   i_oper_type         => i_auth_rec.oper_type
                                 , i_standard_id       => l_standard_id
                                 , i_mask_error        => com_api_type_pkg.FALSE
                               );
        if length(l_network_oper_type) > 4 then
            l_fin_rec.tran_code := substr(l_network_oper_type, 1, length(l_network_oper_type) - 4);
        else
            l_fin_rec.tran_code := l_network_oper_type;
        end if;           
    end if;
    
    l_fin_rec.term_zip          := i_auth_rec.merchant_postcode;
    l_fin_rec.term_country      := i_auth_rec.merchant_country;
    l_fin_rec.term_city         := i_auth_rec.merchant_city;
    l_fin_rec.term_inst_country := i_auth_rec.merchant_country;

    -- pos_entry_mode
    l_pos_data_code_2           := i_auth_rec.crdh_auth_cap;
    l_pos_data_code_7           := i_auth_rec.card_data_input_mode;
    
    l_fin_rec.pos_entry_mode    :=  
        case l_pos_data_code_7
            when 'F2270000' then '00'
            when 'F2270001' then '01'
            when 'F2270002' then '90'            
            when 'F2270003' then '04'
            when 'F2270005' then case when l_standard_version_id >= cmp_api_const_pkg.CMP_STANDARD_VERSION_ID_17R2
                                       and l_standard_version_id < cmp_api_const_pkg.CMP_STANDARD_VERSION_ID_18R1 then '81' else '00' 
                                 end
            when 'F2270006' then '01'
            when 'F2270007' then '00'
            when 'F2270008' then '91'  --contactless magnetic stripe data
            when 'F2270009' then '00'
            when 'F227000A' then '91'
            when 'F227000B' then '02'  --mag stripe read, CVV not reliable
            when 'F227000C' then '05'  --ICC, CVV reliable
            when 'F227000D' then '00'  --??
            when 'F227000F' then '05'
            when 'F227000M' then '07'
            when 'F227000N' then '07'
            when 'F227000P' then '91'
            when 'F227000R' then case
                                     when l_standard_version_id >= cmp_api_const_pkg.CMP_STANDARD_VERSION_ID_17R2
                                     then '09'
                                     else '05'
                                 end
            when 'F227000S' then case
                                     when l_standard_version_id >= cmp_api_const_pkg.CMP_STANDARD_VERSION_ID_17R2 
                                      and l_standard_version_id <  cmp_api_const_pkg.CMP_STANDARD_VERSION_ID_18R1
                                     then '81'
                                     else '00' 
                                 end
            else null
        end;   

    l_fin_rec.pos_entry_mode    := l_fin_rec.pos_entry_mode ||
        case l_pos_data_code_2
            when 'F2220000' then '2'
            when 'F2220001' then '1'            
            when 'F2220002' then '0'            
            when 'F2220005' then '2'            
            when 'F2220006' then '0'            
            else '0'
        end;   

    if i_auth_rec.pin_presence = 'PINP0001' then
        l_fin_rec.pin_presence  := 1;
    else
        l_fin_rec.pin_presence  := 0;
    end if;

    l_fin_rec.term_entry_caps   := 
        case i_auth_rec.card_data_input_cap
            when 'F2210000' then '0'                           -- Unknown; data not available.
            when 'F2210001' then '1'                           -- no terminal used.
            when 'F2210002' then '2'                           -- magnetic stripe reader.
            when 'F2210003' then '3'                           -- bar code.
            when 'F2210004' then '4'                           -- OCR.
            when 'F2210005' then '9'                           -- chip reader.
            when 'F2210006' then '6'                           -- key entry.
            when 'F221000A' then '11'                          -- contactless read capability. ??
            when 'F221000B' then '7'                           -- magnetic stripe reader and key entry.
            when 'F221000C' then '8'                           -- magnetic stripe and chip reader and key entry
            when 'F221000D' then '5'                           -- magnetic stripe and chip reader
            when 'F221000E' then '8'                           -- magnetic stripe and chip reader and key entry ???
            when 'F221000M' then '11'                         --  magnetic stripe and chip reader and key entry
            else null
        end;

    l_fin_rec.orig_time                := i_auth_rec.oper_date; 
    l_fin_rec.host_time                := i_auth_rec.host_date; 
    l_fin_rec.card_number              := i_auth_rec.card_number;
    l_fin_rec.exp_date                 := to_char(i_auth_rec.card_expir_date, 'YYMM'); 
    l_fin_rec.amount                   := i_auth_rec.oper_amount;
    l_fin_rec.currency                 := i_auth_rec.oper_currency;
  
    if l_fin_rec.network_id in (cmp_api_const_pkg.VISA_NETWORK, cmp_api_const_pkg.VISA_NETWORK_NSPK) then
        
        l_fin_rec.ext_ps_fields := 'VISAF62_2=' || l_tag_value;
            
    elsif l_fin_rec.network_id in (cmp_api_const_pkg.MC_NETWORK, cmp_api_const_pkg.MC_NETWORK_NSPK) then     
        
        l_fin_rec.ext_ps_fields := 'MC48_63=' || l_tag_value;
    else  
        l_fin_rec.ext_ps_fields := l_tag_value;   
    end if;
    
    l_fin_rec.term_contactless_capable := 
        case i_auth_rec.card_data_input_cap
            when 'F2210001' then '0'
            when 'F2210002' then '0'
            when 'F2210003' then '0'
            when 'F2210004' then '0'
            when 'F2210005' then '1'
            when 'F2210006' then '0'
            when 'F221000A' then '1'
            when 'F221000M' then '1'
            else
                 case l_pos_data_code_7
                     when 'F2270008' then '1'
                     when 'F227000A' then '1'
                     when 'F227000N' then '1'
                     when 'F227000M' then '1'
                     when 'F227000P' then '1'
                     else '0'
                  end
            end;
    l_fin_rec.ext_stan                 := substr(i_auth_rec.id, -6);
    l_fin_rec.mcc                      := i_auth_rec.mcc;
    l_fin_rec.term_class               := 
        case 
            when i_auth_rec.terminal_type = acq_api_const_pkg.TERMINAL_TYPE_POS then
                '2'
            when i_auth_rec.terminal_type = acq_api_const_pkg.TERMINAL_TYPE_ATM then
                '1'
            when i_auth_rec.terminal_type = acq_api_const_pkg.TERMINAL_TYPE_IMPRINTER then
                '3'
            else
                '4'    --mobile, internet, ePos
        end;
    l_fin_rec.tran_class := l_fin_rec.term_class;    

    if length(i_auth_rec.forw_inst_bin) > 11 then
        l_fin_rec.ext_fid                  := substr(i_auth_rec.forw_inst_bin, -11);
    else
        l_fin_rec.ext_fid                  := i_auth_rec.forw_inst_bin;
    end if;
                        
    l_fin_rec.tran_number              := i_auth_rec.originator_refnum;
    l_fin_rec.final_rrn                := i_auth_rec.originator_refnum;
    l_fin_rec.approval_code            := i_auth_rec.auth_code;
    l_fin_rec.term_name  :=
            case when length(i_auth_rec.terminal_number) >= 8 
               then substr(i_auth_rec.terminal_number, -8) 
               else i_auth_rec.terminal_number
            end;
    l_fin_rec.term_retailer_name       := i_auth_rec.merchant_number;
    l_fin_rec.term_location            := i_auth_rec.merchant_street;
    l_fin_rec.term_owner               := i_auth_rec.merchant_city || ', ' || i_auth_rec.merchant_street;
    l_fin_rec.from_acct_type           := '0';    
    
    if l_fin_rec.is_reversal = com_api_type_pkg.TRUE then
        trc_log_pkg.debug (
            i_text          => 'Reversal auth. Original_id [' || i_auth_rec.original_id || ']'
        );    
        -- find presentment 
        get_fin (
            i_id          => i_auth_rec.original_id
          , o_fin_rec     => l_original_rec
        );
        trc_log_pkg.debug (
            i_text          => 'ARN for original operation [' || l_original_rec.arn || ']'
        );    
        
        l_fin_rec.arn := l_original_rec.arn;
        
        update cmp_fin_message
           set status = case when status in (net_api_const_pkg.CLEARING_MSG_STATUS_READY, cmp_api_const_pkg.CLEARING_COLLECT_STATUS_READY)
                              and amount = i_auth_rec.oper_amount
                             then net_api_const_pkg.CLEARING_MSG_STATUS_PENDING
                             else status
                        end
         where id = l_original_rec.id
     returning case when status in (net_api_const_pkg.CLEARING_MSG_STATUS_PENDING)
                      or i_auth_rec.oper_amount = 0
                    then net_api_const_pkg.CLEARING_MSG_STATUS_PENDING
                    else nvl(i_status, net_api_const_pkg.CLEARING_MSG_STATUS_READY)
                    end
          into l_fin_rec.status;
        
    else    
        l_acquirer_bin := get_arn(l_fin_rec.tran_code);
        
        if l_acquirer_bin is null then
        
            l_acquirer_bin := nvl(
                cmn_api_standard_pkg.get_varchar_value (
                    i_inst_id     => l_fin_rec.inst_id
                  , i_standard_id => l_standard_id
                  , i_object_id   => l_host_id
                  , i_entity_type => net_api_const_pkg.ENTITY_TYPE_HOST
                  , i_param_name  => cmp_api_const_pkg.ACQUIRER_BIN
                  , i_param_tab   => l_param_tab
                )
              , i_auth_rec.acq_inst_bin
            );
        end if;

        l_fin_rec.arn  := acq_api_merchant_pkg.get_arn(
                             i_acquirer_bin          => l_acquirer_bin
                          );        
    end if;
                                                                
    l_fin_rec.aid                      := substr(l_fin_rec.arn, 2, 6);      
    
    l_fin_rec.orig_fi_name := cmn_api_standard_pkg.get_varchar_value(
         i_inst_id       => l_fin_rec.inst_id
       , i_standard_id   => l_standard_id
       , i_object_id     => l_host_id
       , i_entity_type   => net_api_const_pkg.ENTITY_TYPE_HOST
       , i_param_name    => cmp_api_const_pkg.COMPASS_ACQUIRER_NAME
       , i_param_tab     => l_param_tab
    );
    
    l_fin_rec.orig_fi_name := cmp_cst_fin_message_pkg.get_orig_fi_name(
        i_auth_rec      => i_auth_rec
      , i_collect_only  => i_collect_only
      , i_fin_message   => l_fin_rec
    );
    
    l_fin_rec.dest_fi_name := 
        case 
            when l_fin_rec.network_id = cmp_api_const_pkg.VISA_NETWORK then 
                'VISA'
            when l_fin_rec.network_id = cmp_api_const_pkg.VISA_NETWORK_NSPK then 
                'NSPV'
            when l_fin_rec.network_id = cmp_api_const_pkg.MC_NETWORK then 
                'MASTERCARD'
            when l_fin_rec.network_id = cmp_api_const_pkg.MC_NETWORK_NSPK then 
                'NSPM'
            else
                cmn_api_standard_pkg.get_varchar_value(
                     i_inst_id       => l_fin_rec.inst_id
                   , i_standard_id   => l_standard_id
                   , i_object_id     => l_host_id
                   , i_entity_type   => net_api_const_pkg.ENTITY_TYPE_HOST
                   , i_param_name    => cmp_api_const_pkg.COMPASS_DEST_NAME
                   , i_param_tab     => l_param_tab
                )
        end;

    l_fin_rec.dest_fi_name := cmp_cst_fin_message_pkg.get_dest_fi_name(
        i_auth_rec        => i_auth_rec
        , i_collect_only  => i_collect_only
        , i_fin_message   => l_fin_rec
    );
        
    l_fin_rec.clear_date       := get_sysdate;
    l_fin_rec.service_code     := nvl(i_auth_rec.card_service_code, i_auth_rec.service_code); 
         
    if i_auth_rec.emv_data is not null then
        l_is_binary := nvl(
                           set_ui_value_pkg.get_system_param_n(i_param_name => 'EMV_TAGS_IS_BINARY')
                         , com_api_type_pkg.FALSE
                       );
        trc_log_pkg.debug('process_auth: l_is_binary = ' || l_is_binary);

        emv_api_tag_pkg.parse_emv_data(
            i_emv_data          => i_auth_rec.emv_data
          , o_emv_tag_tab       => l_emv_tag_tab
          , i_is_binary         => l_is_binary
        );
        l_fin_rec.emv_data_exists := com_api_type_pkg.TRUE;
        l_fin_rec.icc_term_caps := emv_api_tag_pkg.get_tag_value(
            i_tag               => '9F33'
          , i_emv_tag_tab       => l_emv_tag_tab
          , i_mask_error        => com_api_type_pkg.TRUE --not mandatory tag
        );
        l_fin_rec.icc_tvr       := emv_api_tag_pkg.get_tag_value(
            i_tag               => '95'
          , i_emv_tag_tab       => l_emv_tag_tab
          , i_mask_error        => l_mask_emv_tag_error
        );
        l_fin_rec.icc_random    := emv_api_tag_pkg.get_tag_value(
            i_tag               => '9F37'
          , i_emv_tag_tab       => l_emv_tag_tab
          , i_mask_error        => l_mask_emv_tag_error
        );
        l_fin_rec.icc_term_sn   := emv_api_tag_pkg.get_tag_value(
            i_tag               => '9F1E'
          , i_emv_tag_tab       => l_emv_tag_tab
          , i_mask_error        => com_api_type_pkg.TRUE --not mandatory tag
        );
        l_fin_rec.icc_issuer_data := emv_api_tag_pkg.get_tag_value(
            i_tag               => '9F10'
          , i_emv_tag_tab       => l_emv_tag_tab
          , i_mask_error        => l_mask_emv_tag_error
        );        
        l_fin_rec.icc_cryptogram := emv_api_tag_pkg.get_tag_value(
            i_tag               => '9F26'
          , i_emv_tag_tab       => l_emv_tag_tab
          , i_mask_error        => l_mask_emv_tag_error
        );
        l_fin_rec.icc_app_tran_count := emv_api_tag_pkg.get_tag_value(
            i_tag               => '9F36'
          , i_emv_tag_tab       => l_emv_tag_tab
          , i_mask_error        => l_mask_emv_tag_error
        );
        l_fin_rec.icc_term_tran_count := emv_api_tag_pkg.get_tag_value(
            i_tag               => '9F41'
          , i_emv_tag_tab       => l_emv_tag_tab
          , i_mask_error        => com_api_type_pkg.TRUE --not mandatory tag
        );        
        l_fin_rec.icc_app_profile := emv_api_tag_pkg.get_tag_value(
            i_tag               => '82'
          , i_emv_tag_tab       => l_emv_tag_tab
          , i_mask_error        => l_mask_emv_tag_error
        );        
        l_fin_rec.icc_iad := emv_api_tag_pkg.get_tag_value(
            i_tag               => '91'
          , i_emv_tag_tab       => l_emv_tag_tab
          , i_mask_error        => com_api_type_pkg.TRUE --not mandatory tag
        );
        l_fin_rec.icc_tran_type := emv_api_tag_pkg.get_tag_value(
            i_tag               => '9C'
          , i_emv_tag_tab       => l_emv_tag_tab
          , i_mask_error        => l_mask_emv_tag_error
        );
        l_fin_rec.icc_term_country := emv_api_tag_pkg.get_tag_value(
            i_tag               => '9F1A'
          , i_emv_tag_tab       => l_emv_tag_tab
          , i_mask_error        => l_mask_emv_tag_error
        );
        l_fin_rec.icc_tran_date := to_date(emv_api_tag_pkg.get_tag_value(
            i_tag               => '9A'
          , i_emv_tag_tab       => l_emv_tag_tab
          , i_mask_error        => l_mask_emv_tag_error
        ), 'YYMMDD');
        l_fin_rec.icc_amount := emv_api_tag_pkg.get_tag_value(
            i_tag               => '9F02'
          , i_emv_tag_tab       => l_emv_tag_tab
          , i_mask_error        => l_mask_emv_tag_error
        );
        l_fin_rec.icc_currency := emv_api_tag_pkg.get_tag_value(
            i_tag               => '5F2A'
          , i_emv_tag_tab       => l_emv_tag_tab
          , i_mask_error        => l_mask_emv_tag_error
        );
        l_fin_rec.icc_cb_amount := '0';
        
        l_fin_rec.icc_crypt_inform_data := emv_api_tag_pkg.get_tag_value(
            i_tag               => '9F27'
          , i_emv_tag_tab       => l_emv_tag_tab
          , i_mask_error        => com_api_type_pkg.TRUE --not mandatory tag
        );
        l_fin_rec.icc_cvm_res := emv_api_tag_pkg.get_tag_value(
            i_tag               => '9F34'
          , i_emv_tag_tab       => l_emv_tag_tab
          , i_mask_error        => com_api_type_pkg.TRUE --not mandatory tag
        );
        l_fin_rec.icc_card_member := emv_api_tag_pkg.get_tag_value(
            i_tag               => '5F34'
          , i_emv_tag_tab       => l_emv_tag_tab
          , i_mask_error        => com_api_type_pkg.TRUE --not mandatory tag
        );                
        l_fin_rec.card_member := emv_api_tag_pkg.get_tag_value(
            i_tag               => '5F34'
          , i_emv_tag_tab       => l_emv_tag_tab
          , i_mask_error        => com_api_type_pkg.TRUE --not mandatory tag
        );                

        l_fin_rec.pos_condition   := '91'; --chip
        
    else
        l_fin_rec.card_member     := '0';
        l_fin_rec.emv_data_exists := com_api_type_pkg.FALSE;
        l_fin_rec.pos_condition   := '00'; --not chip
    end if;    
               
    l_fin_rec.icc_respcode    := i_auth_rec.native_resp_code;
      
    l_fin_rec.id := put_message (
                        i_fin_rec    => l_fin_rec
                    );
     
    trc_log_pkg.debug (
        i_text         => 'cmp_api_fin_message_pkg.process_auth end'
    );  
end;

function estimate_messages_for_upload (
    i_network_id   in     com_api_type_pkg.t_tiny_id
  , i_inst_id      in     com_api_type_pkg.t_inst_id
  , i_host_inst_id in     com_api_type_pkg.t_inst_id
  , i_collect_only in     com_api_type_pkg.t_dict_value
) return number is
    l_stmt                varchar2(4000);
    l_result              number;
    l_collect_only_flag   com_api_type_pkg.t_byte_char := 'C';
    l_status              com_api_type_pkg.t_dict_value;
    l_index_name          com_api_type_pkg.t_name;
begin
        
    if i_collect_only = cmp_api_const_pkg.UPLOAD_COLLECT_ONLY_CLC then

        l_status := cmp_api_const_pkg.CLEARING_COLLECT_STATUS_READY;
        l_index_name := '/*+ INDEX(f, cmp_fin_message_CLMS0160_ndx)*/';
        
    else
        l_status := net_api_const_pkg.CLEARING_MSG_STATUS_READY;    
        l_index_name := '/*+ INDEX(f, cmp_fin_message_CLMS0010_ndx)*/';
    end if;
     
    l_stmt := '
        select ' || l_index_name || 
         ' count(f.id) 
        from
            cmp_fin_message f
            , cmp_card c
        where
            decode(f.status, ''' || l_status || ''', ''' || l_status || ''' , null) = ''' || l_status || '''
            and f.is_incoming = :is_incoming
            and f.network_id = :i_network_id
            and f.inst_id = :i_inst_id
            and f.host_inst_id = :i_host_inst_id
            and c.id(+) = f.id ';

    l_stmt := l_stmt ||
        case when i_collect_only = cmp_api_const_pkg.UPLOAD_COLLECT_ONLY_CLC then ' and f.collect_only_flag = :l_collect_only_flag '
             when i_collect_only = cmp_api_const_pkg.UPLOAD_COLLECT_ONLY_NCLC then ' and f.collect_only_flag is null '
             else ''
        end;

    trc_log_pkg.debug(
        i_text          => 'l_stmt= [' || l_stmt || ']'
    );
                            
    if i_collect_only = cmp_api_const_pkg.UPLOAD_COLLECT_ONLY_CLC then
    
        execute immediate l_stmt into l_result using com_api_type_pkg.FALSE, i_network_id, i_inst_id, i_host_inst_id, l_collect_only_flag;
    else    
        execute immediate l_stmt into l_result using com_api_type_pkg.FALSE, i_network_id, i_inst_id, i_host_inst_id;
    end if;    
    
    return l_result;
end;

procedure enum_messages_for_upload (
    o_fin_cur               in out sys_refcursor
    , i_network_id          in com_api_type_pkg.t_tiny_id
    , i_inst_id             in com_api_type_pkg.t_inst_id
    , i_host_inst_id        in com_api_type_pkg.t_inst_id
    , i_collect_only        in com_api_type_pkg.t_dict_value
) is
    l_stmt                  varchar2(4000);
    l_collect_only_flag     com_api_type_pkg.t_byte_char := 'C';
    l_status                com_api_type_pkg.t_dict_value;
    l_index_name            com_api_type_pkg.t_name;
begin

    if i_collect_only = cmp_api_const_pkg.UPLOAD_COLLECT_ONLY_CLC then

        l_status := cmp_api_const_pkg.CLEARING_COLLECT_STATUS_READY;
        l_index_name := '/*+ INDEX(f, cmp_fin_message_CLMS0160_ndx)*/';
        
    else
        l_status := net_api_const_pkg.CLEARING_MSG_STATUS_READY;    
        l_index_name := '/*+ INDEX(f, cmp_fin_message_CLMS0010_ndx)*/';
    end if;

    l_stmt := '
        select '|| l_index_name ||' '
                || g_column_list||'
        from
            cmp_fin_message f
            , cmp_card c
        where
            decode(f.status, ''' || l_status || ''', ''' || l_status || ''' , null) = ''' || l_status || '''
            and f.is_incoming = :is_incoming
            and f.network_id = :i_network_id
            and f.inst_id = :i_inst_id
            and f.host_inst_id = :i_host_inst_id
            and c.id(+) = f.id ';

    l_stmt := l_stmt ||
        case when i_collect_only = cmp_api_const_pkg.UPLOAD_COLLECT_ONLY_CLC then ' and f.collect_only_flag = :l_collect_only_flag '
             when i_collect_only = cmp_api_const_pkg.UPLOAD_COLLECT_ONLY_NCLC then ' and f.collect_only_flag is null '
             else ''
        end;
                            
    l_stmt := l_stmt ||' order by f.id';
    
    trc_log_pkg.debug(
        i_text          => 'l_stmt= [' || l_stmt || ']'
    );

    if i_collect_only = cmp_api_const_pkg.UPLOAD_COLLECT_ONLY_CLC then
    
        open o_fin_cur for l_stmt using com_api_type_pkg.FALSE, i_network_id, i_inst_id, i_host_inst_id, l_collect_only_flag;
    else    
        open o_fin_cur for l_stmt using com_api_type_pkg.FALSE, i_network_id, i_inst_id, i_host_inst_id;
    end if;
end;

end;
/
