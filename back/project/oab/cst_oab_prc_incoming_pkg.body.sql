create or replace package body cst_oab_prc_incoming_pkg as
/*********************************************************
*  OAB custom incoming proceses <br />
*  Created by Gogolev I. (i.gogolev@bpcbt.com) at 04.09.2018 <br />
*  Module: CST_OAB_PRC_INCOMING_PKG <br />
*  @headcom
**********************************************************/
procedure register_auth_data(
    i_auth_data    in aut_api_type_pkg.t_auth_rec
)
is

    LOG_PREFIX constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.register_auth_data: ';
    
begin
    
    trc_log_pkg.debug(i_text => LOG_PREFIX || 'START for oper_id[' || i_auth_data.id || ']');
    
    insert into aut_auth (
        id
      , resp_code
      , proc_type
      , proc_mode
      , is_advice
      , is_repeat
      , bin_amount
      , bin_currency
      , bin_cnvt_rate
      , network_amount
      , network_currency
      , network_cnvt_date
      , network_cnvt_rate
      , account_cnvt_rate
      , parent_id
      , addr_verif_result
      , iss_network_device_id
      , acq_device_id
      , acq_resp_code
      , acq_device_proc_result
      , cat_level
      , card_data_input_cap
      , crdh_auth_cap
      , card_capture_cap
      , terminal_operating_env
      , crdh_presence
      , card_presence
      , card_data_input_mode
      , crdh_auth_method
      , crdh_auth_entity
      , card_data_output_cap
      , terminal_output_cap
      , pin_capture_cap
      , pin_presence
      , cvv2_presence
      , cvc_indicator
      , pos_entry_mode
      , pos_cond_code
      , emv_data
      , atc
      , tvr
      , cvr
      , addl_data
      , service_code
      , device_date
      , cvv2_result
      , certificate_method
      , certificate_type
      , merchant_certif
      , cardholder_certif
      , ucaf_indicator
      , is_early_emv
      , is_completed
      , amounts
      , cavv_presence
      , aav_presence
      , system_trace_audit_number
      , transaction_id
      , external_auth_id
      , external_orig_id
      , agent_unique_id
      , native_resp_code
      , trace_number
      , auth_purpose_id
     ) values (
        i_auth_data.id
      , i_auth_data.resp_code
      , i_auth_data.proc_type
      , i_auth_data.proc_mode
      , i_auth_data.is_advice
      , i_auth_data.is_repeat
      , i_auth_data.bin_amount
      , i_auth_data.bin_currency
      , i_auth_data.bin_cnvt_rate
      , i_auth_data.network_amount
      , i_auth_data.network_currency
      , i_auth_data.network_cnvt_date
      , i_auth_data.network_cnvt_rate
      , i_auth_data.account_cnvt_rate
      , i_auth_data.parent_id
      , i_auth_data.addr_verif_result
      , i_auth_data.iss_network_device_id
      , i_auth_data.acq_device_id
      , i_auth_data.acq_resp_code
      , i_auth_data.acq_device_proc_result
      , i_auth_data.cat_level
      , i_auth_data.card_data_input_cap
      , i_auth_data.crdh_auth_cap
      , i_auth_data.card_capture_cap
      , i_auth_data.terminal_operating_env
      , i_auth_data.crdh_presence
      , i_auth_data.card_presence
      , i_auth_data.card_data_input_mode
      , i_auth_data.crdh_auth_method
      , i_auth_data.crdh_auth_entity
      , i_auth_data.card_data_output_cap
      , i_auth_data.terminal_output_cap
      , i_auth_data.pin_capture_cap
      , i_auth_data.pin_presence
      , i_auth_data.cvv2_presence
      , i_auth_data.cvc_indicator
      , i_auth_data.pos_entry_mode
      , i_auth_data.pos_cond_code
      , i_auth_data.emv_data
      , i_auth_data.atc
      , i_auth_data.tvr
      , i_auth_data.cvr
      , i_auth_data.addl_data
      , i_auth_data.service_code
      , i_auth_data.device_date
      , i_auth_data.cvv2_result
      , i_auth_data.certificate_method
      , i_auth_data.certificate_type
      , i_auth_data.merchant_certif
      , i_auth_data.cardholder_certif
      , i_auth_data.ucaf_indicator
      , i_auth_data.is_early_emv
      , i_auth_data.is_completed
      , i_auth_data.amounts
      , i_auth_data.cavv_presence
      , i_auth_data.aav_presence
      , i_auth_data.system_trace_audit_number
      , i_auth_data.transaction_id
      , i_auth_data.external_auth_id
      , i_auth_data.external_orig_id
      , i_auth_data.agent_unique_id
      , i_auth_data.native_resp_code
      , i_auth_data.trace_number
      , i_auth_data.auth_purpose_id
    );
    
    trc_log_pkg.debug(i_text => LOG_PREFIX || 'FINISH for oper_id[' || i_auth_data.id || ']');
    
end register_auth_data;

procedure fin_message_operate_mapping(
    i_transaction_rec      in        cst_oab_api_type_pkg.t_omannet_file_in_rec
  , i_row_number           in        com_api_type_pkg.t_count
  , i_incom_sess_file_id   in        com_api_type_pkg.t_long_id
  , io_oper                in out    cst_oab_api_type_pkg.t_oper_rec
  , io_iss_part            in out    opr_api_type_pkg.t_oper_part_rec
  , io_acq_part            in out    opr_api_type_pkg.t_oper_part_rec
  , io_auth_data           in out    aut_api_type_pkg.t_auth_rec
) is
    
    LOG_PREFIX             constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.fin_message_operate_mapping: ';
    
    l_iss_inst_id          com_api_type_pkg.t_inst_id;
    l_card_inst_id         com_api_type_pkg.t_inst_id;
    l_iss_network_id       com_api_type_pkg.t_tiny_id;
    l_iss_host_id          com_api_type_pkg.t_tiny_id;
    l_pan_length           com_api_type_pkg.t_tiny_id;
    l_card_network_id      com_api_type_pkg.t_tiny_id;
    l_card_type_id         com_api_type_pkg.t_tiny_id;
    l_country_code         com_api_type_pkg.t_country_code;
    
    l_card_rec             iss_api_type_pkg.t_card_rec;
    
    l_terminal_rec         cst_oab_api_type_pkg.t_terminal_rec;
    
    l_merchant_address     com_api_type_pkg.t_address_rec;
    
    function response_code_map(
        i_resp_code_original   in com_api_type_pkg.t_tag
    ) return com_api_type_pkg.t_dict_value
    is
    begin
        
        return case
                   when i_resp_code_original in ('000', '003', '007', '087')
                       then aup_api_const_pkg.RESP_CODE_OK
                   when i_resp_code_original in ('100', '200')
                       then aup_api_const_pkg.RESP_CODE_DO_NOT_HONOR
                   when i_resp_code_original = '001'
                       then 'RESP0045'
                   when i_resp_code_original = '116'
                       then aup_api_const_pkg.RESP_CODE_UNSUFFICIENT_FUNDS
                   when i_resp_code_original = '101'
                       then aup_api_const_pkg.RESP_CODE_EXPIRED_CARD
                   else aup_api_const_pkg.RESP_CODE_ERROR
               end;
               
    end response_code_map;
    
    function status_code_map(
        i_status_code_original   in com_api_type_pkg.t_tag
    ) return com_api_type_pkg.t_dict_value
    is
    begin
        
        return case
                   when i_status_code_original in ('SUCCESS', 'CAPTURED', 'APPROVED', 'VOIDED')
                       then opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY
                   when i_status_code_original = 'PROCESSED'
                       then opr_api_const_pkg.OPERATION_STATUS_PROCESSED
                   else opr_api_const_pkg.OPERATION_STATUS_UNSUCCESSFUL
               end;
               
    end status_code_map;
    
    procedure action_code_map(
        i_action_code       in  com_api_type_pkg.t_byte_char
      , o_oper_type        out  com_api_type_pkg.t_dict_value
      , o_msgt_type        out  com_api_type_pkg.t_dict_value
      , o_is_reversal      out  com_api_type_pkg.t_sign
    )
    is
    begin
        case i_action_code
            when '01'
                then
                    o_oper_type   := opr_api_const_pkg.OPERATION_TYPE_PURCHASE;
                    o_msgt_type   := aut_api_const_pkg.MESSAGE_TYPE_AUTHORIZATION;
                    o_is_reversal := com_api_const_pkg.FALSE;
            when '02'
                then
                    o_oper_type   := opr_api_const_pkg.OPERATION_TYPE_REFUND;
                    o_msgt_type   := aut_api_const_pkg.MESSAGE_TYPE_AUTHORIZATION;
                    o_is_reversal := com_api_const_pkg.FALSE;
            when '03'
                then
                    o_oper_type   := opr_api_const_pkg.OPERATION_TYPE_PURCHASE;
                    o_msgt_type   := aut_api_const_pkg.MESSAGE_TYPE_AUTHORIZATION;
                    o_is_reversal := com_api_const_pkg.TRUE;
            when '04'
                then
                    o_oper_type   := opr_api_const_pkg.OPERATION_TYPE_PURCHASE;
                    o_msgt_type   := aut_api_const_pkg.MESSAGE_TYPE_PREATHORIZATION;
                    o_is_reversal := com_api_const_pkg.FALSE;
            when '05'
                then
                    o_oper_type   := opr_api_const_pkg.OPERATION_TYPE_PURCHASE;
                    o_msgt_type   := aut_api_const_pkg.MESSAGE_TYPE_COMPLETION;
                    o_is_reversal := com_api_const_pkg.FALSE;
            when '06'
                then 
                    o_oper_type   := opr_api_const_pkg.OPERATION_TYPE_REFUND;
                    o_msgt_type   := aut_api_const_pkg.MESSAGE_TYPE_AUTHORIZATION;
                    o_is_reversal := com_api_const_pkg.TRUE;
            when '08'
                then
                    o_oper_type   := opr_api_const_pkg.OPERATION_TYPE_BALANCE_INQUIRY;
                    o_msgt_type   := aut_api_const_pkg.MESSAGE_TYPE_AUTHORIZATION;
                    o_is_reversal := com_api_const_pkg.FALSE;
            when '09'
                then
                    o_oper_type   := opr_api_const_pkg.OPERATION_TYPE_PURCHASE;
                    o_msgt_type   := aut_api_const_pkg.MESSAGE_TYPE_PREATHORIZATION;
                    o_is_reversal := com_api_const_pkg.TRUE;
        end case;
    
    end action_code_map;
    
begin
    
    trc_log_pkg.debug(LOG_PREFIX || 'START with params - ' || cst_oab_api_const_pkg.CRLF
                                 || 'Row number: ' || i_row_number || cst_oab_api_const_pkg.CRLF
                                 || 'Serial number: ' || i_transaction_rec.serial_number
    );
    
    io_oper.oper_main_rec.oper_date    := sysdate;
    
    io_oper.oper_main_rec.host_date    := to_date(
                                              i_transaction_rec.request_datetime
                                            , cst_oab_api_const_pkg.REQUEST_DATE_FORMAT
                                          );
                              
    io_oper.oper_main_rec.id           := opr_api_create_pkg.get_id(i_host_date => io_oper.oper_main_rec.host_date);
    
    io_oper.oper_main_rec.status_reason := response_code_map(
                                               i_resp_code_original => i_transaction_rec.response_code_de39
                                           );
    
    io_oper.oper_main_rec.status        := status_code_map(
                                               i_status_code_original   => i_transaction_rec.result_code
                                           );
    
    action_code_map(
        i_action_code  => i_transaction_rec.action_code
      , o_oper_type    => io_oper.oper_main_rec.oper_type
      , o_msgt_type    => io_oper.oper_main_rec.msg_type
      , o_is_reversal  => io_oper.oper_main_rec.is_reversal
    );

    if io_oper.oper_main_rec.oper_type is null 
        or io_oper.oper_main_rec.msg_type is null 
        or io_oper.oper_main_rec.is_reversal is null
    then

        com_api_error_pkg.raise_error(
            i_error        => 'WRONG_STRUCTURE_FIN_MESSAGE'
          , i_env_param1   => 'WRONG VALUE ACTION CODE PARAMETER - ' || i_transaction_rec.action_code
          
        );

    end if;

    if io_iss_part.card_id is not null then
        
        iss_api_bin_pkg.get_bin_info(
            i_card_number      => io_iss_part.card_number
          , o_iss_inst_id      => l_iss_inst_id
          , o_iss_network_id   => l_iss_network_id
          , o_iss_host_id      => l_iss_host_id
          , o_card_type_id     => l_card_type_id
          , o_card_country     => l_country_code
          , o_card_inst_id     => l_card_inst_id
          , o_card_network_id  => l_card_network_id
          , o_pan_length       => l_pan_length
        );
    
        l_card_rec := 
            iss_api_card_pkg.get_card(
                i_card_id => io_iss_part.card_id
            );
        io_iss_part.card_type_id      := l_card_type_id;
        io_iss_part.customer_id       := l_card_rec.customer_id;
        io_iss_part.card_hash         := l_card_rec.card_hash;
        io_iss_part.split_hash        := l_card_rec.split_hash;
    
        io_iss_part.card_seq_number   := iss_api_card_pkg.get_seq_number(i_card_number => io_iss_part.card_number);
        
    else
    
        net_api_bin_pkg.get_bin_info(
            i_card_number      => io_iss_part.card_number
          , i_oper_type        => io_oper.oper_main_rec.oper_type
          , o_iss_inst_id      => l_iss_inst_id
          , o_iss_network_id   => l_iss_network_id
          , o_iss_host_id      => l_iss_host_id
          , o_card_type_id     => l_card_type_id
          , o_card_country     => l_country_code
          , o_card_inst_id     => l_card_inst_id
          , o_card_network_id  => l_card_network_id
          , o_pan_length       => l_pan_length
        );
        
    end if;
    
    io_oper.oper_main_rec.oper_amount   := to_number(i_transaction_rec.net_amount, cst_oab_api_const_pkg.AMOUNT_FORMAT_OMANNET_FILE);
    io_oper.oper_main_rec.oper_currency := i_transaction_rec.currency_code;
    
    
    io_oper.oper_main_rec.sttl_amount   := to_number(i_transaction_rec.transaction_amount_de4, cst_oab_api_const_pkg.AMOUNT_FORMAT_OMANNET_FILE);
    io_oper.oper_main_rec.sttl_currency := i_transaction_rec.currency_code;
    
    io_oper.total_amount                := to_number(i_transaction_rec.transaction_amount_de4, cst_oab_api_const_pkg.AMOUNT_FORMAT_OMANNET_FILE);
    io_oper.fee_amount                  := to_number(i_transaction_rec.service_charge_amount, cst_oab_api_const_pkg.AMOUNT_FORMAT_OMANNET_FILE);
    io_oper.fee_currency                := i_transaction_rec.currency_code;
    io_oper.oper_main_rec.mcc           := i_transaction_rec.mcc_code_de26;
    
    io_oper.oper_main_rec.originator_refnum  := i_transaction_rec.tran_rfrn_tx_de37;
    io_oper.oper_main_rec.network_refnum     := i_transaction_rec.tran_rfrn_tx_de37;
    
    begin
        select id
             , seqnum
             , is_template
             , terminal_number
             , terminal_type
             , merchant_id
             , mcc
             , plastic_number
             , card_data_input_cap
             , crdh_auth_cap
             , card_capture_cap
             , term_operating_env
             , crdh_data_present
             , card_data_present
             , card_data_input_mode
             , crdh_auth_method
             , crdh_auth_entity
             , card_data_output_cap
             , term_data_output_cap
             , pin_capture_cap
             , cat_level
             , gmt_offset
             , is_mac
             , device_id
             , status
             , contract_id
             , inst_id
             , split_hash
             , cash_dispenser_present
             , payment_possibility
             , use_card_possibility
             , cash_in_present
             , available_network
             , available_operation
             , available_currency
          into l_terminal_rec
          from acq_terminal a
         where a.id = io_acq_part.terminal_id;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error        => 'TERMINAL_NOT_FOUND'
              , i_env_param1   => io_acq_part.terminal_id
            );
        when others then
            raise;
    end;
    
    io_oper.oper_main_rec.terminal_type := l_terminal_rec.terminal_type;

    l_merchant_address :=
        com_api_address_pkg.get_address(
            i_object_id    => io_acq_part.merchant_id
          , i_entity_type  => acq_api_const_pkg.ENTITY_TYPE_MERCHANT
          , i_address_type => null
          , i_mask_error   => com_api_const_pkg.FALSE
        );
    
    io_oper.oper_main_rec.merchant_street    := l_merchant_address.street;
    io_oper.oper_main_rec.merchant_city      := l_merchant_address.city;
    io_oper.oper_main_rec.merchant_region    := l_merchant_address.region;
    io_oper.oper_main_rec.merchant_country   := l_merchant_address.country;
    io_oper.oper_main_rec.merchant_postcode  := l_merchant_address.postal_code;
    
    
    io_oper.oper_main_rec.incom_sess_file_id := i_incom_sess_file_id;
    
    --issuer participant
    io_iss_part.card_expir_date   := to_date(
                                         i_transaction_rec.expiry_date_de14
                                       , 'yymm'
                                     );
                                    
    io_iss_part.inst_id           := l_iss_inst_id;
    io_iss_part.network_id        := l_iss_network_id;
    
    io_iss_part.card_mask         := iss_api_card_pkg.get_card_mask(
                                        i_card_number => io_iss_part.card_number
                                    );
    
    io_iss_part.card_country      := l_country_code;
    io_iss_part.card_inst_id      := l_card_inst_id;
    io_iss_part.card_network_id   := l_card_network_id;
    
    io_iss_part.client_id_type    := opr_api_const_pkg.CLIENT_ID_TYPE_CARD;
    io_iss_part.client_id_value   := io_iss_part.card_number;
    io_iss_part.auth_code         := i_transaction_rec.auth_code_de38;

    --acquirer participant
    io_acq_part.participant_type  := com_api_const_pkg.PARTICIPANT_ACQUIRER;
    io_acq_part.client_id_type    := opr_api_const_pkg.CLIENT_ID_TYPE_TERMINAL;
    io_acq_part.client_id_value   := io_acq_part.terminal_id;
    io_acq_part.inst_id           := l_terminal_rec.inst_id;
    --io_acq_part.network_id        := ;
        
    --get auth data
    io_auth_data.resp_code                  := io_oper.oper_main_rec.status_reason;
    io_auth_data.proc_type                  := aut_api_const_pkg.DEFAULT_AUTH_PROC_TYPE;
    io_auth_data.proc_mode                  := case
                                                  when io_auth_data.resp_code = aup_api_const_pkg.RESP_CODE_OK
                                                      then aut_api_const_pkg.DEFAULT_AUTH_PROC_MODE
                                                  else aut_api_const_pkg.AUTH_PROC_MODE_DECLINED
                                              end;
    io_auth_data.is_advice                  := com_api_const_pkg.FALSE;
    io_auth_data.network_amount             := io_oper.oper_main_rec.oper_amount;
    io_auth_data.network_currency           := io_oper.oper_main_rec.oper_currency;
    --io_auth_data.addr_verif_result          := ;
    io_auth_data.card_data_input_cap        := l_terminal_rec.card_data_input_cap;
    io_auth_data.crdh_auth_cap              := l_terminal_rec.crdh_auth_cap;
    io_auth_data.card_capture_cap           := l_terminal_rec.card_capture_cap;
    io_auth_data.terminal_operating_env     := l_terminal_rec.term_operating_env;
    io_auth_data.crdh_presence              := l_terminal_rec.crdh_data_present;
    io_auth_data.card_presence              := l_terminal_rec.card_data_present;
    io_auth_data.card_data_input_mode       := l_terminal_rec.card_data_input_mode;
    io_auth_data.crdh_auth_method           := l_terminal_rec.crdh_auth_method;
    io_auth_data.pin_capture_cap            := l_terminal_rec.pin_capture_cap;
    --io_auth_data.pos_entry_mode             := ;
    --io_auth_data.pos_cond_code              := ;
    io_auth_data.system_trace_audit_number  := substr(lpad(to_char(i_transaction_rec.serial_number), 6, '0'), -6);
    --io_auth_data.cvv2_result                := ;
    --io_auth_data.is_completed               := aut_api_const_pkg.AUTH_NOT_COMPLETE_STAGE_CONF;
    
    io_auth_data.auth_code                  := io_iss_part.auth_code;
    
    io_auth_data.external_auth_id           := i_transaction_rec.tran_id;
    
    --io_auth_data.service_code               := ;
    
    trc_log_pkg.debug(LOG_PREFIX || 'END');

end fin_message_operate_mapping;

procedure process_record(
    i_inst_id              in com_api_type_pkg.t_inst_id
  , i_network_id           in com_api_type_pkg.t_network_id
  , i_rec                  in com_api_type_pkg.t_text
  , i_separate_char        in com_api_type_pkg.t_byte_char
  , i_row_number           in com_api_type_pkg.t_count
  , i_incom_sess_file_id   in com_api_type_pkg.t_long_id
  , o_processed           out com_api_type_pkg.t_sign
  , o_excepted            out com_api_type_pkg.t_sign
  , o_rejected            out com_api_type_pkg.t_sign
)
is
    LOG_PREFIX           constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.process_record: ';
    
    l_pos_begin          com_api_type_pkg.t_tiny_id;
    l_length             com_api_type_pkg.t_tiny_id;
    l_count_fields       binary_integer := cst_oab_api_const_pkg.NUM_FIELD_OMANNET_FILE_IN;
    l_count_separators   binary_integer := cst_oab_api_const_pkg.NUM_FIELD_OMANNET_FILE_IN - 1;
    
    l_transaction_data   cst_oab_api_type_pkg.t_omannet_file_in_rec;
    
    l_oper_rec           cst_oab_api_type_pkg.t_oper_rec;
    l_iss_part           opr_api_type_pkg.t_oper_part_rec;
    l_acq_part           opr_api_type_pkg.t_oper_part_rec;
    l_auth_data          aut_api_type_pkg.t_auth_rec;
begin
    
    for i in 1 .. l_count_fields
    loop
        l_pos_begin := case
                           when i = 1 
                               then 0
                           else instr(i_rec, i_separate_char, 1, i-1)
                       end + 1;
        l_length    := case
                           when i <= l_count_separators
                               then instr(i_rec, i_separate_char, 1, i) - l_pos_begin
                           else length(i_rec) - l_pos_begin + 1
                       end;
        if nvl(l_pos_begin, 0) <= 0 
            or nvl(l_length, 0) <= 0 
            or l_length > length(i_rec)
        then
            com_api_error_pkg.raise_error(
                i_error        => 'WRONG_STRUCTURE_FIN_MESSAGE'
              , i_env_param1   => 'WRONG COUNT OF THE RECORD FIELDS - ' || i || '; MUST BE - ' || l_count_fields
            );
        elsif i = l_count_fields and instr(substr(i_rec, l_pos_begin, l_length), i_separate_char, 1) > 0 then
            com_api_error_pkg.raise_error(
                i_error        => 'WRONG_STRUCTURE_FIN_MESSAGE'
              , i_env_param1   => 'COUNT OF THE RECORD FIELDS MORE THEN MUST BE (' || l_count_fields || ')'
            );
        end if;
        
        case i
            when 1 then  l_transaction_data.serial_number           := to_number(substr(i_rec, l_pos_begin, l_length));
            when 2 then  l_transaction_data.request_datetime        := substr(i_rec, l_pos_begin, l_length);
            when 3 then  l_transaction_data.action_code             := substr(i_rec, l_pos_begin, l_length);
            when 4 then  l_transaction_data.transaction_type        := substr(i_rec, l_pos_begin, l_length);
            when 5 then  l_transaction_data.currency_code           := substr(i_rec, l_pos_begin, l_length);
            when 6 then  l_transaction_data.transaction_amount_de4  := substr(i_rec, l_pos_begin, l_length);
            when 7 then  l_transaction_data.result_code             := substr(i_rec, l_pos_begin, l_length);
            when 8 then  l_transaction_data.response_code_de39      := substr(i_rec, l_pos_begin, l_length);
            when 9 then  l_transaction_data.merchant_track_id       := substr(i_rec, l_pos_begin, l_length);
            when 10 then l_transaction_data.tran_id                 := substr(i_rec, l_pos_begin, l_length);
            when 11 then l_transaction_data.tran_rfrn_tx_de37       := substr(i_rec, l_pos_begin, l_length);
            when 12 then l_transaction_data.auth_code_de38          := substr(i_rec, l_pos_begin, l_length);
            when 13 then l_transaction_data.trn_src_ip_tx           := substr(i_rec, l_pos_begin, l_length);
            when 14 then l_transaction_data.merchant_id_de42        := substr(i_rec, l_pos_begin, l_length);
            when 15 then l_transaction_data.terminal_id_de41        := substr(i_rec, l_pos_begin, l_length);
            when 16 then l_transaction_data.merchant_name           := substr(i_rec, l_pos_begin, l_length);
            when 17 then l_transaction_data.mcc_code_de26           := substr(i_rec, l_pos_begin, l_length);
            when 18 then l_transaction_data.card_number_de2         := substr(i_rec, l_pos_begin, l_length);
            when 19 then l_transaction_data.expiry_date_de14        := substr(i_rec, l_pos_begin, l_length);
            when 20 then l_transaction_data.service_charge_amount   := substr(i_rec, l_pos_begin, l_length);
            when 21 then l_transaction_data.net_amount              := substr(i_rec, l_pos_begin, l_length);
            when 22 then l_transaction_data.auth_model              := substr(i_rec, l_pos_begin, l_length);
            when 23 then l_transaction_data.payment_id              := substr(i_rec, l_pos_begin, l_length);
            when 24 then l_transaction_data.pos_code_de22           := substr(i_rec, l_pos_begin, l_length);
            when 25 then l_transaction_data.user_dfnd_1_tx          := substr(i_rec, l_pos_begin, l_length);
            when 26 then l_transaction_data.user_dfnd_2_tx          := substr(i_rec, l_pos_begin, l_length);
            when 27 then l_transaction_data.user_dfnd_3_tx          := substr(i_rec, l_pos_begin, l_length);
            when 28 then l_transaction_data.user_dfnd_4_tx          := substr(i_rec, l_pos_begin, l_length);
            when 29 then l_transaction_data.user_dfnd_5_tx          := substr(i_rec, l_pos_begin, l_length);
        end case;
        
    end loop;
    
    -- check settlement type
    l_iss_part.card_id := 
        iss_api_card_pkg.get_card_id(
            i_card_number => iss_api_token_pkg.decode_card_number(
                                 i_card_number => l_transaction_data.card_number_de2
                               , i_mask_error  => com_api_const_pkg.FALSE
                             )
        );
    if l_iss_part.card_id is null then
        l_iss_part.participant_type := com_api_const_pkg.PARTICIPANT_ISSUER;
        l_iss_part.card_number := l_transaction_data.card_number_de2;
        acq_api_terminal_pkg.get_terminal(
            i_inst_id         => i_inst_id
          , i_merchant_number => l_transaction_data.merchant_id_de42
          , i_terminal_number => l_transaction_data.terminal_id_de41
          , o_merchant_id     => l_acq_part.merchant_id
          , o_terminal_id     => l_acq_part.terminal_id
        );
        if l_acq_part.merchant_id is not null
            and l_acq_part.terminal_id is not null
        then
            l_acq_part.participant_type := com_api_const_pkg.PARTICIPANT_ACQUIRER;
            l_acq_part.network_id       := i_network_id;
            l_oper_rec.oper_main_rec.sttl_type := opr_api_const_pkg.SETTLEMENT_THEMONUS;
            l_oper_rec.oper_main_rec.merchant_number := l_transaction_data.merchant_id_de42;
            l_oper_rec.oper_main_rec.terminal_number := l_transaction_data.terminal_id_de41;
            l_oper_rec.oper_main_rec.merchant_name   := l_transaction_data.merchant_name;

            fin_message_operate_mapping(
                i_transaction_rec       => l_transaction_data
              , i_row_number            => i_row_number
              , i_incom_sess_file_id    => i_incom_sess_file_id
              , io_oper                 => l_oper_rec
              , io_iss_part             => l_iss_part
              , io_acq_part             => l_acq_part
              , io_auth_data            => l_auth_data
            );

            opr_api_create_pkg.create_operation(
                io_oper_id                  =>      l_oper_rec.oper_main_rec.id
              , i_session_id                =>      l_oper_rec.oper_main_rec.session_id
              , i_is_reversal               =>      l_oper_rec.oper_main_rec.is_reversal
              , i_original_id               =>      l_oper_rec.oper_main_rec.original_id
              , i_oper_type                 =>      l_oper_rec.oper_main_rec.oper_type
              , i_oper_reason               =>      l_oper_rec.oper_main_rec.oper_reason
              , i_msg_type                  =>      l_oper_rec.oper_main_rec.msg_type
              , i_status                    =>      l_oper_rec.oper_main_rec.status
              , i_status_reason             =>      l_oper_rec.oper_main_rec.status_reason
              , i_sttl_type                 =>      l_oper_rec.oper_main_rec.sttl_type
              , i_terminal_type             =>      l_oper_rec.oper_main_rec.terminal_type
              , i_merchant_number           =>      l_oper_rec.oper_main_rec.merchant_number
              , i_terminal_number           =>      l_oper_rec.oper_main_rec.terminal_number
              , i_merchant_name             =>      l_oper_rec.oper_main_rec.merchant_name
              , i_merchant_street           =>      l_oper_rec.oper_main_rec.merchant_street
              , i_merchant_city             =>      l_oper_rec.oper_main_rec.merchant_city
              , i_merchant_region           =>      l_oper_rec.oper_main_rec.merchant_region
              , i_merchant_country          =>      l_oper_rec.oper_main_rec.merchant_country
              , i_merchant_postcode         =>      l_oper_rec.oper_main_rec.merchant_postcode
              , i_mcc                       =>      l_oper_rec.oper_main_rec.mcc
              , i_originator_refnum         =>      l_oper_rec.oper_main_rec.originator_refnum
              , i_network_refnum            =>      l_oper_rec.oper_main_rec.network_refnum
              , i_oper_amount               =>      l_oper_rec.oper_main_rec.oper_amount
              , i_oper_currency             =>      l_oper_rec.oper_main_rec.oper_currency
              , i_oper_date                 =>      l_oper_rec.oper_main_rec.oper_date
              , i_host_date                 =>      l_oper_rec.oper_main_rec.host_date
              , i_match_status              =>      l_oper_rec.oper_main_rec.match_status
              , i_sttl_amount               =>      l_oper_rec.oper_main_rec.sttl_amount
              , i_sttl_currency             =>      l_oper_rec.oper_main_rec.sttl_currency
              , i_incom_sess_file_id        =>      l_oper_rec.oper_main_rec.incom_sess_file_id
              , i_fee_amount                =>      l_oper_rec.fee_amount
              , i_fee_currency              =>      l_oper_rec.fee_currency
            );
            
            update opr_operation o
                set o.total_amount = l_oper_rec.total_amount
              where o.id = l_oper_rec.oper_main_rec.id;
              
            l_auth_data.id    := l_oper_rec.oper_main_rec.id;
                    
            register_auth_data(
                i_auth_data    => l_auth_data
            );
            
            o_excepted  := 0;
            o_processed := 1;
            o_rejected  := 0;
        else
            o_excepted  := 1;
            o_processed := 0;
            o_rejected  := 0;
        end if;
    else
        o_excepted  := 1;
        o_processed := 0;
        o_rejected  := 0;
    end if;

exception
    when others then
        o_excepted  := 0;
        o_processed := 0;
        o_rejected  := 1;
        if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE then
            trc_log_pkg.debug(
                i_text       => LOG_PREFIX || 'Error - ' || sqlerrm || ' - on sess_file_id [#3] row_number [#1] for rec[#2]'
              , i_env_param1 => i_row_number
              , i_env_param2 => i_rec
              , i_env_param3 => i_incom_sess_file_id
            );
        elsif com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        else
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm
            );
        end if;
end process_record;

procedure process_load_operations(
    i_inst_id           in  com_api_type_pkg.t_inst_id
  , i_network_id        in  com_api_type_pkg.t_network_id
  , i_separate_char     in  com_api_type_pkg.t_byte_char
) is
    LOG_PREFIX           constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.process_load_operations: ';
    
    l_record_count_all_files      com_api_type_pkg.t_long_id := 0;
    l_record_count                com_api_type_pkg.t_long_id := 0;
    l_record_number               com_api_type_pkg.t_long_id := 0;
    l_processed_count             com_api_type_pkg.t_long_id := 0;
    l_excepted_count              com_api_type_pkg.t_long_id := 0;
    l_rejected_count              com_api_type_pkg.t_long_id := 0;
    l_rec                         com_api_type_pkg.t_text;
    l_separate_char               com_api_type_pkg.t_byte_char := nvl(i_separate_char, cst_oab_api_const_pkg.SEPARATE_CHAR_DEFAULT);
    
    l_processed                   com_api_type_pkg.t_sign;
    l_excepted                    com_api_type_pkg.t_sign;
    l_rejected                    com_api_type_pkg.t_sign;
    
    cursor cu_records_count is
        select count(1)
          from prc_file_raw_data a
             , prc_session_file b
         where b.session_id      = prc_api_session_pkg.get_session_id
           and a.session_file_id = b.id;
begin
    prc_api_stat_pkg.log_start;

    open cu_records_count;
    fetch cu_records_count into l_record_count_all_files;
    close cu_records_count;

    prc_api_stat_pkg.log_estimation(
        i_estimated_count     => l_record_count_all_files
    );

    for p in (
        select id session_file_id
             , record_count
             , file_name
          from prc_session_file
         where session_id = prc_api_session_pkg.get_session_id
         order by id
    ) 
    loop
        trc_log_pkg.debug(
            i_text => 'Processing session_file_id [' || p.session_file_id 
                   || '], record_count [' || p.record_count 
                   || '], file_name [' || p.file_name || ']'
        );
        
        begin
            
            for r in (
                select record_number
                     , raw_data
                     , count(*) over() cnt
                     , row_number() over(order by record_number) rn
                     , row_number() over(order by record_number desc) rn_desc
                  from prc_file_raw_data
                 where session_file_id = p.session_file_id
                 order by record_number
            )
            loop
                l_record_number := r.record_number;
                l_rec := r.raw_data;
                process_record(
                    i_inst_id            => i_inst_id
                  , i_network_id         => i_network_id
                  , i_rec                => r.raw_data
                  , i_separate_char      => l_separate_char
                  , i_row_number         => r.rn
                  , i_incom_sess_file_id => p.session_file_id
                  , o_processed          => l_processed
                  , o_excepted           => l_excepted
                  , o_rejected           => l_rejected
                );
                    
                l_processed_count := l_processed_count + l_processed;
                l_excepted_count  := l_excepted_count + l_excepted;
                l_rejected_count  := l_rejected_count + l_rejected;
                    
                if mod(r.rn, 100) = 0 then
                    prc_api_stat_pkg.log_current(
                        i_current_count  => l_record_count + r.rn
                      , i_excepted_count => l_excepted_count
                    );
                end if;
                    
                if r.rn_desc = 1 then
                    l_record_count := l_record_count + r.cnt;
                    prc_api_stat_pkg.log_current(
                        i_current_count  => l_record_count
                      , i_excepted_count => l_excepted_count
                    );
                end if;
                    
            end loop;
            
            prc_api_file_pkg.close_file(
                i_sess_file_id          => p.session_file_id
              , i_status                => prc_api_const_pkg.FILE_STATUS_ACCEPTED
            );
        exception
            when com_api_error_pkg.e_application_error then

                l_record_count := l_record_count + p.record_count;

                prc_api_stat_pkg.log_current(
                        i_current_count  => l_record_count
                      , i_excepted_count => l_excepted_count
                );
                prc_api_file_pkg.close_file(
                    i_sess_file_id          => p.session_file_id
                  , i_status                => prc_api_const_pkg.FILE_STATUS_REJECTED
                );
                raise;
        end;
    end loop;
    
    prc_api_stat_pkg.log_end(
        i_processed_total  => l_processed_count
      , i_excepted_total   => l_excepted_count
      , i_rejected_total   => l_rejected_count
      , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.debug(LOG_PREFIX || 'END');
exception
    when others then
        if cu_records_count%isopen then
            close cu_records_count;
        end if;

        prc_api_stat_pkg.log_end(
            i_result_code      => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        else
            trc_log_pkg.debug(
                i_text       => LOG_PREFIX || 'FAILED with l_record_number [#1] l_rec [#2]' 
              , i_env_param1 => l_record_number
              , i_env_param2 => l_rec
            );
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm
            );
        end if;
end process_load_operations;

end cst_oab_prc_incoming_pkg;
/
